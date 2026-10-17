# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MorningNotificationService do
  include ActiveSupport::Testing::TimeHelpers

  describe '.call' do
    context '締切当日通知の設定がONで未送信の場合' do
      it 'メール通知を送信する' do
        travel_to Time.zone.local(2026, 9, 12, 12, 0) do
          user = create(:user)

          user.notification_setting.update!(
            email_deadline_same_day: true
          )

          watchlist = create(
            :watchlist,
            user: user,
            start_at: nil,
            end_at: Time.zone.now.end_of_day,
            end_type: :deadline
          )

          mail = instance_double(ActionMailer::MessageDelivery)

          allow(NotificationMailer)
            .to receive(:today_notice)
            .and_return(mail)

          allow(mail).to receive(:deliver_now)

          allow(described_class).to receive(:sleep)

          described_class.call

          expect(mail).to have_received(:deliver_now).once

          expect(
            watchlist.notification_deliveries.exists?(
              channel: :email,
              notification_type: :deadline_same_day
            )
          ).to be true
        end
      end
    end

    context '締切当日通知の設定がOFFの場合' do
      it 'メール通知を送信しない' do
        travel_to Time.zone.local(2026, 9, 12, 12, 0) do
          user = create(:user)

          user.notification_setting.update!(
            email_deadline_same_day: false
          )

          create(
            :watchlist,
            user: user,
            start_at: nil,
            end_at: Time.zone.now.end_of_day,
            end_type: :deadline
          )

          mail = instance_double(ActionMailer::MessageDelivery)

          allow(NotificationMailer)
            .to receive(:today_notice)
            .and_return(mail)

          allow(mail).to receive(:deliver_now)

          allow(described_class).to receive(:sleep)

          described_class.call

          expect(mail).not_to have_received(:deliver_now)
        end
      end
    end

    context '締切当日通知がすでに送信済みの場合' do
      it 'メール通知を再送信しない' do
        travel_to Time.zone.local(2026, 9, 12, 12, 0) do
          user = create(:user)

          user.notification_setting.update!(
            email_deadline_same_day: true
          )

          watchlist = create(
            :watchlist,
            user: user,
            start_at: nil,
            end_at: Time.zone.now.end_of_day,
            end_type: :deadline
          )

          NotificationDelivery.create!(
            watchlist: watchlist,
            channel: :email,
            notification_type: :deadline_same_day
          )

          mail = instance_double(ActionMailer::MessageDelivery)

          allow(NotificationMailer)
            .to receive(:today_notice)
            .and_return(mail)

          allow(mail).to receive(:deliver_now)

          allow(described_class).to receive(:sleep)

          described_class.call

          expect(NotificationMailer)
            .not_to have_received(:today_notice)
        end
      end
    end

    context '開始当日通知の設定がONで未送信の場合' do
      it 'メール通知を送信する' do
        travel_to Time.zone.local(2026, 9, 12, 12, 0) do
          user = create(:user)

          user.notification_setting.update!(
            email_start_same_day: true
          )

          watchlist = create(
            :watchlist,
            user: user,
            start_at: Time.current,
            end_at: 3.days.from_now
          )

          mail = instance_double(ActionMailer::MessageDelivery)

          allow(NotificationMailer)
            .to receive(:start_notice)
            .and_return(mail)

          allow(mail).to receive(:deliver_now)

          allow(described_class).to receive(:sleep)

          described_class.call

          expect(mail).to have_received(:deliver_now).once

          expect(
            watchlist.notification_deliveries.exists?(
              channel: :email,
              notification_type: :start_same_day
            )
          ).to be true
        end
      end
    end

    context '開始当日通知の設定がOFFの場合' do
      it 'メール通知を送信しない' do
        travel_to Time.zone.local(2026, 9, 12, 12, 0) do
          user = create(:user)

          user.notification_setting.update!(
            email_start_same_day: false
          )

          create(
            :watchlist,
            user: user,
            start_at: Time.current,
            end_at: 3.days.from_now
          )

          mail = instance_double(ActionMailer::MessageDelivery)

          allow(NotificationMailer)
            .to receive(:start_notice)
            .and_return(mail)

          allow(mail).to receive(:deliver_now)

          allow(described_class).to receive(:sleep)

          described_class.call

          expect(mail).not_to have_received(:deliver_now)
        end
      end
    end

    context '開始当日通知がすでに送信済みの場合' do
      it 'メール通知を再送信しない' do
        travel_to Time.zone.local(2026, 9, 12, 12, 0) do
          user = create(:user)

          user.notification_setting.update!(
            email_start_same_day: true
          )

          watchlist = create(
            :watchlist,
            user: user,
            start_at: Time.current,
            end_at: 3.days.from_now
          )

          NotificationDelivery.create!(
            watchlist: watchlist,
            channel: :email,
            notification_type: :start_same_day
          )

          mail = instance_double(ActionMailer::MessageDelivery)

          allow(NotificationMailer)
            .to receive(:start_notice)
            .and_return(mail)

          allow(mail).to receive(:deliver_now)

          allow(described_class).to receive(:sleep)

          described_class.call

          expect(NotificationMailer)
            .not_to have_received(:start_notice)
        end
      end
    end

    context '締切当日通知のメール送信に失敗した場合' do
      it '送信履歴を保存しない' do
        travel_to Time.zone.local(2026, 9, 12, 12, 0) do
          user = create(:user)

          user.notification_setting.update!(
            email_deadline_same_day: true
          )

          watchlist = create(
            :watchlist,
            user: user,
            start_at: nil,
            end_at: Time.zone.now.end_of_day,
            end_type: :deadline
          )

          mail = instance_double(ActionMailer::MessageDelivery)

          allow(NotificationMailer)
            .to receive(:today_notice)
            .and_return(mail)

          allow(mail)
            .to receive(:deliver_now)
            .and_raise(StandardError, 'メール送信失敗')

          allow(described_class).to receive(:sleep)

          described_class.call

          expect(mail).to have_received(:deliver_now).once

          expect(
            watchlist.notification_deliveries.exists?(
              channel: :email,
              notification_type: :deadline_same_day
            )
          ).to be false
        end
      end
    end

    context '開始当日通知のメール送信に失敗した場合' do
      it '送信履歴を保存しない' do
        travel_to Time.zone.local(2026, 9, 12, 12, 0) do
          user = create(:user)

          user.notification_setting.update!(
            email_start_same_day: true
          )

          watchlist = create(
            :watchlist,
            user: user,
            start_at: Time.current,
            end_at: 3.days.from_now
          )

          mail = instance_double(ActionMailer::MessageDelivery)

          allow(NotificationMailer)
            .to receive(:start_notice)
            .and_return(mail)

          allow(mail)
            .to receive(:deliver_now)
            .and_raise(StandardError, 'メール送信失敗')

          allow(described_class).to receive(:sleep)

          described_class.call

          expect(mail).to have_received(:deliver_now).once

          expect(
            watchlist.notification_deliveries.exists?(
              channel: :email,
              notification_type: :start_same_day
            )
          ).to be false
        end
      end
    end
  end
end
