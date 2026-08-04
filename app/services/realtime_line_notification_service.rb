# frozen_string_literal: true

class RealtimeLineNotificationService
  class << self
    include NotificationDeliverySupport

    def call
      send_start_ten_minutes_before
      send_deadline_three_hours_before
    end

    private

    def send_start_ten_minutes_before
      send_notifications(
        Watchlist.starting_within_ten_minutes,
        log_type: '開始10分前LINE',
        notification_type: :start_ten_minutes_before,
        message: start_ten_minutes_before_message
      )
    end

    def send_deadline_three_hours_before
      send_notifications(
        Watchlist.deadline_three_hours_before,
        log_type: '締切3時間前LINE',
        notification_type: :deadline_three_hours_before,
        message: deadline_three_hours_before_message
      )
    end

    def send_notifications(targets, log_type:, notification_type:, message:)
      targets = targets.includes(user: :social_accounts)

      log_start(log_type, targets.count)

      targets.find_each do |watchlist|
        send_notification(watchlist, log_type:, notification_type:, message:)
      end

      log_finish(log_type)
    end

    def send_notification(watchlist, log_type:, notification_type:, message:)
      line_account = line_account_for(watchlist.user)

      return unless line_account
      return if delivered?(watchlist, :line, notification_type)

      deliver_notification(watchlist, line_account, log_type:, notification_type:, message:)
    rescue StandardError => e
      log_error(log_type, watchlist.id, e)
    end

    def deliver_notification(
      watchlist,
      line_account,
      notification_type:,
      message:,
      log_type:
    )
      sent = LineMessagingService.push_flex(
        line_account.uid,
        notification_title(watchlist),
        message,
        watchlist_url(watchlist)
      )

      return unless sent

      record_delivery(watchlist, :line, notification_type)
      log_success(log_type, watchlist.id, line_account.uid)
    end

    def notification_title(watchlist)
      "🌟 #{watchlist.display_title}"
    end

    def start_ten_minutes_before_message
      "開始まであと10分です。\n\nまもなく始まります。\n詳細をご確認ください。"
    end

    def deadline_three_hours_before_message
      "締め切りまであと3時間です。\n\n大切な予定を見逃さないようご確認ください。"
    end

    def watchlist_url(watchlist)
      Rails.application.routes.url_helpers.watchlist_url(
        watchlist,
        Rails.application.config.action_mailer.default_url_options
      )
    end

    def line_account_for(user)
      user&.social_accounts&.find do |account|
        account.provider == 'line'
      end
    end
  end
end
