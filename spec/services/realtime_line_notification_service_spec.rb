# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RealtimeLineNotificationService do
  include ActiveSupport::Testing::TimeHelpers

  describe '.call' do
    context '開始10分前通知の対象で、LINE連携済み・通知ON・未送信の場合' do
      it 'LINE通知を送信する' do
        travel_to Time.zone.local(2026, 9, 12, 12, 0) do
          user = create(:user)
          create(:social_account, user: user, provider: 'line', uid: 'line-user-id')

          user.notification_setting.update!(
            line_start_ten_minutes_before: true
          )

          create(
            :watchlist,
            user: user,
            start_at: 5.minutes.from_now,
            end_at: 1.day.from_now
          )

          allow(LineMessagingService)
            .to receive(:push_flex)
            .and_return(true)

          described_class.call

          expect(LineMessagingService)
            .to have_received(:push_flex)
        end
      end
    end

    context 'LINE未連携の場合' do
      it 'LINE通知を送信しない' do
        travel_to Time.zone.local(2026, 9, 12, 12, 0) do
          user = create(:user)

          user.notification_setting.update!(
            line_start_ten_minutes_before: true
          )

          create(
            :watchlist,
            user: user,
            start_at: 5.minutes.from_now,
            end_at: 1.day.from_now
          )

          allow(LineMessagingService)
            .to receive(:push_flex)
            .and_return(true)

          described_class.call

          expect(LineMessagingService)
            .not_to have_received(:push_flex)
        end
      end
    end

    context '開始10分前通知の設定がOFFの場合' do
      it 'LINE通知を送信しない' do
        travel_to Time.zone.local(2026, 9, 12, 12, 0) do
          user = create(:user)
          create(:social_account, user: user, provider: 'line', uid: 'line-user-id')

          user.notification_setting.update!(
            line_start_ten_minutes_before: false
          )

          create(
            :watchlist,
            user: user,
            start_at: 5.minutes.from_now,
            end_at: 1.day.from_now
          )

          allow(LineMessagingService)
            .to receive(:push_flex)
            .and_return(true)

          described_class.call

          expect(LineMessagingService)
            .not_to have_received(:push_flex)
        end
      end
    end

    context '同じ通知が送信済みの場合' do
      it 'LINE通知を再送しない' do
        travel_to Time.zone.local(2026, 9, 12, 12, 0) do
          user = create(:user)
          create(:social_account, user: user, provider: 'line', uid: 'line-user-id')

          user.notification_setting.update!(
            line_start_ten_minutes_before: true
          )

          watchlist = create(
            :watchlist,
            user: user,
            start_at: 5.minutes.from_now,
            end_at: 1.day.from_now
          )

          NotificationDelivery.create!(
            watchlist: watchlist,
            channel: :line,
            notification_type: :start_ten_minutes_before,
            sent_at: Time.current
          )

          allow(LineMessagingService)
            .to receive(:push_flex)
            .and_return(true)

          described_class.call

          expect(LineMessagingService)
            .not_to have_received(:push_flex)
        end
      end
    end

    context 'LINE送信に成功した場合' do
      it '送信履歴を記録する' do
        travel_to Time.zone.local(2026, 9, 12, 12, 0) do
          user = create(:user)
          create(:social_account, user: user, provider: 'line', uid: 'line-user-id')

          user.notification_setting.update!(
            line_start_ten_minutes_before: true
          )

          watchlist = create(
            :watchlist,
            user: user,
            start_at: 5.minutes.from_now,
            end_at: 1.day.from_now
          )

          allow(LineMessagingService)
            .to receive(:push_flex)
            .and_return(true)

          expect do
            described_class.call
          end.to change(NotificationDelivery, :count).by(1)

          delivery = watchlist.notification_deliveries.find_by(
            channel: :line,
            notification_type: :start_ten_minutes_before
          )

          expect(delivery).to be_present
        end
      end
    end

    context 'LINE送信に失敗した場合' do
      it '送信履歴を記録しない' do
        travel_to Time.zone.local(2026, 9, 12, 12, 0) do
          user = create(:user)
          create(:social_account, user: user, provider: 'line', uid: 'line-user-id')

          user.notification_setting.update!(
            line_start_ten_minutes_before: true
          )

          create(
            :watchlist,
            user: user,
            start_at: 5.minutes.from_now,
            end_at: 1.day.from_now
          )

          allow(LineMessagingService)
            .to receive(:push_flex)
            .and_return(false)

          expect do
            described_class.call
          end.not_to change(NotificationDelivery, :count)
        end
      end
    end

    context 'LINE通知を送信できない場合' do
      it 'アプリ内通知は作成する' do
        travel_to Time.zone.local(2026, 9, 12, 12, 0) do
          user = create(:user)

          watchlist = create(
            :watchlist,
            user: user,
            start_at: 5.minutes.from_now,
            end_at: 1.day.from_now
          )

          allow(LineMessagingService)
            .to receive(:push_flex)
            .and_return(true)

          expect do
            described_class.call
          end.to change(Notification, :count).by(1)

          notification = Notification.find_by(
            watchlist: watchlist,
            notification_type: :start_ten_minutes_before
          )

          expect(notification).to be_present
        end
      end
    end

    context '締切3時間前通知の対象で、LINE連携済み・通知ON・未送信の場合' do
      it 'LINE通知を送信する' do
        travel_to Time.zone.local(2026, 9, 12, 12, 0) do
          user = create(:user)
          create(:social_account, user: user, provider: 'line', uid: 'line-user-id')

          user.notification_setting.update!(
            line_deadline_three_hours_before: true
          )

          create(
            :watchlist,
            user: user,
            start_at: 1.day.ago,
            end_at: 175.minutes.from_now
          )

          allow(LineMessagingService)
            .to receive(:push_flex)
            .and_return(true)

          described_class.call

          expect(LineMessagingService)
            .to have_received(:push_flex)
        end
      end
    end
  end
end
