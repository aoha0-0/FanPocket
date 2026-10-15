# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NightNotificationService do
  include ActiveSupport::Testing::TimeHelpers

  describe '.call' do
    context '3日前通知の設定がONで未送信の場合' do
      it 'メール通知を送信する' do
        travel_to Time.zone.local(2026, 9, 12, 12, 0) do
          user = create(:user)

          user.notification_setting.update!(
            email_three_days_before: true
          )

          create(
            :watchlist,
            user: user,
            end_at: 3.days.from_now,
            end_type: :deadline
          )

          mail = instance_double(ActionMailer::MessageDelivery)

          allow(NotificationMailer)
            .to receive(:three_days_ago_notice)
            .and_return(mail)

          allow(mail).to receive(:deliver_now)

          allow(described_class).to receive(:sleep)

          described_class.call

          expect(mail).to have_received(:deliver_now).once
        end
      end
    end

    context '3日前通知の設定がOFFの場合' do
      it 'メール通知を送信しない' do
        travel_to Time.zone.local(2026, 9, 12, 12, 0) do
          user = create(:user)

          user.notification_setting.update!(
            email_three_days_before: false
          )

          create(
            :watchlist,
            user: user,
            end_at: 3.days.from_now,
            end_type: :deadline
          )

          mail = instance_double(ActionMailer::MessageDelivery)

          allow(NotificationMailer)
            .to receive(:three_days_ago_notice)
            .and_return(mail)

          allow(mail).to receive(:deliver_now)
          allow(described_class).to receive(:sleep)

          described_class.call

          expect(NotificationMailer)
            .not_to have_received(:three_days_ago_notice)
        end
      end
    end

    context '前日通知の設定がONで未送信の場合' do
      it 'メール通知を送信する' do
        travel_to Time.zone.local(2026, 9, 12, 12, 0) do
          user = create(:user)

          user.notification_setting.update!(
            email_day_before: true
          )

          create(
            :watchlist,
            user: user,
            start_at: nil,
            end_at: 1.day.from_now,
            end_type: :deadline
          )

          mail = instance_double(ActionMailer::MessageDelivery)

          allow(NotificationMailer)
            .to receive(:day_before_notice)
            .and_return(mail)

          allow(mail).to receive(:deliver_now)

          allow(described_class).to receive(:sleep)

          described_class.call

          expect(mail).to have_received(:deliver_now).once
        end
      end
    end

    context '前日通知の設定がOFFの場合' do
      it 'メール通知を送信しない' do
        travel_to Time.zone.local(2026, 9, 12, 12, 0) do
          user = create(:user)

          user.notification_setting.update!(
            email_day_before: false
          )

          create(
            :watchlist,
            user: user,
            start_at: nil,
            end_at: 1.day.from_now,
            end_type: :deadline
          )

          mail = instance_double(ActionMailer::MessageDelivery)

          allow(NotificationMailer)
            .to receive(:day_before_notice)
            .and_return(mail)

          allow(mail).to receive(:deliver_now)

          allow(described_class).to receive(:sleep)

          described_class.call

          expect(NotificationMailer)
            .not_to have_received(:day_before_notice)
        end
      end
    end

    context '3日前通知が送信済みの場合' do
      it 'メール通知を再送信しない' do
        travel_to Time.zone.local(2026, 9, 12, 12, 0) do
          user = create(:user)

          user.notification_setting.update!(
            email_three_days_before: true
          )

          watchlist = create(
            :watchlist,
            user: user,
            end_at: 3.days.from_now,
            end_type: :deadline
          )

          NotificationDelivery.create!(
            watchlist: watchlist,
            channel: :email,
            notification_type: :deadline_three_days_before
          )

          mail = instance_double(ActionMailer::MessageDelivery)

          allow(NotificationMailer)
            .to receive(:three_days_ago_notice)
            .and_return(mail)

          allow(mail).to receive(:deliver_now)

          allow(described_class).to receive(:sleep)

          described_class.call

          expect(NotificationMailer)
            .not_to have_received(:three_days_ago_notice)
        end
      end
    end

    context '前日通知が送信済みの場合' do
      it 'メール通知を再送信しない' do
        travel_to Time.zone.local(2026, 9, 12, 12, 0) do
          user = create(:user)

          user.notification_setting.update!(
            email_day_before: true
          )

          watchlist = create(
            :watchlist,
            user: user,
            start_at: nil,
            end_at: 1.day.from_now,
            end_type: :deadline
          )

          NotificationDelivery.create!(
            watchlist: watchlist,
            channel: :email,
            notification_type: :deadline_day_before
          )

          mail = instance_double(ActionMailer::MessageDelivery)

          allow(NotificationMailer)
            .to receive(:day_before_notice)
            .and_return(mail)

          allow(mail).to receive(:deliver_now)

          allow(described_class).to receive(:sleep)

          described_class.call

          expect(NotificationMailer)
            .not_to have_received(:day_before_notice)
        end
      end
    end
  end
end
