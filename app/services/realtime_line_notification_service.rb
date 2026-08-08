# frozen_string_literal: true

class RealtimeLineNotificationService
  class << self
    include NotificationDeliverySupport

    def call
      send_start_ten_minutes_before
      send_deadline_three_hours_before
    end

    private

    def line_notification_enabled?(user, setting_key)
      user.notification_setting&.public_send("#{setting_key}?")
    end

    def send_start_ten_minutes_before
      send_notifications(
        Watchlist.starting_within_ten_minutes,
        RealtimeLineNotificationConfig::CONFIGS[:start_ten_minutes_before]
      )
    end

    def send_deadline_three_hours_before
      send_notifications(
        Watchlist.deadline_three_hours_before,
        RealtimeLineNotificationConfig::CONFIGS[:deadline_three_hours_before]
      )
    end

    def send_notifications(targets, config)
      targets = targets.includes(user: :social_accounts)

      log_start(config[:log_type], targets.count)

      targets.find_each do |watchlist|
        send_notification(watchlist, config)
      end

      log_finish(config[:log_type])
    end

    def send_notification(watchlist, config)
      create_in_app_notification(
        watchlist,
        config[:notification_type],
        config[:title],
        config[:message]
      )

      deliver_line_notification(watchlist, config)
    rescue StandardError => e
      log_error(config[:log_type], watchlist.id, e)
    end

    def deliver_line_notification(watchlist, config)
      user = watchlist.user
      line_account = line_account_for(user)

      return unless line_deliverable?(watchlist, user, line_account, config)

      deliver_notification(
        watchlist,
        line_account,
        log_type: config[:log_type],
        notification_type: config[:notification_type],
        message: config[:message]
      )
    end

    def line_deliverable?(watchlist, user, line_account, config)
      line_account &&
        line_notification_enabled?(user, config[:setting_key]) &&
        !delivered?(watchlist, :line, config[:notification_type])
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

    def create_in_app_notification(watchlist, notification_type, title, message)
      InAppNotificationService.create!(
        watchlist: watchlist,
        notification_type: notification_type,
        title: title,
        message: message
      )
    end

    def notification_title(watchlist)
      "🌟 #{watchlist.display_title}"
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
