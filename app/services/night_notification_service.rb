# frozen_string_literal: true

class NightNotificationService
  class << self
    include NotificationDeliverySupport

    def call
      send_three_days_prior
      send_day_before
    end

    private

    def send_three_days_prior
      targets = Watchlist.alert_three_days_prior.includes(:user)

      log_start('締切3日前', targets.count)
      targets.find_each { |watchlist| send_three_days_prior_notification(watchlist) }
      log_finish('締切3日前')
    end

    def send_three_days_prior_notification(watchlist)
      user = watchlist.user
      return unless user

      deliver_three_days_prior_notification(watchlist, user)
    rescue StandardError => e
      log_error('締切3日前', watchlist.id, e)
    end

    def deliver_three_days_prior_notification(watchlist, user)
      content = EndNotificationContent.three_days_prior_content(watchlist)

      create_three_days_prior_notification(watchlist, content)
      deliver_three_days_prior_email(watchlist, user, content)
    end

    def deliver_three_days_prior_email(watchlist, user, content)
      return unless user.notification_setting&.email_three_days_before?
      return if delivered?(watchlist, :email, :deadline_three_days_before)

      send_three_days_prior_email(watchlist, user, content)
      record_delivery(watchlist, :email, :deadline_three_days_before)

      log_success('締切3日前', watchlist.id, user.email)
      sleep 1
    end

    def create_three_days_prior_notification(watchlist, content)
      InAppNotificationService.create!(
        watchlist: watchlist,
        notification_type: :deadline_three_days_before,
        title: EndNotificationContent.three_days_prior_title(watchlist),
        message: content
      )
    end

    def send_three_days_prior_email(watchlist, user, content)
      NotificationMailer.three_days_ago_notice(
        user.email,
        watchlist.title,
        content
      ).deliver_now
    end

    def send_day_before
      targets = Watchlist.alert_day_before.includes(:user)

      log_start('締切前日', targets.count)
      targets.find_each { |watchlist| send_day_before_notification(watchlist) }
      log_finish('締切前日')
    end

    def send_day_before_notification(watchlist)
      user = watchlist.user
      return unless user

      deliver_day_before_notification(watchlist, user)
    rescue StandardError => e
      log_error('締切前日', watchlist.id, e)
    end

    def deliver_day_before_notification(watchlist, user)
      content = EndNotificationContent.day_before_content(watchlist)

      create_day_before_notification(watchlist, content)
      deliver_day_before_email(watchlist, user, content)
    end

    def deliver_day_before_email(watchlist, user, content)
      return unless user.notification_setting&.email_day_before?
      return if delivered?(watchlist, :email, :deadline_day_before)

      send_day_before_email(watchlist, user, content)
      record_delivery(watchlist, :email, :deadline_day_before)

      log_success('締切前日', watchlist.id, user.email)
      sleep 1
    end

    def create_day_before_notification(watchlist, content)
      InAppNotificationService.create!(
        watchlist: watchlist,
        notification_type: :deadline_day_before,
        title: EndNotificationContent.day_before_title(watchlist),
        message: content
      )
    end

    def send_day_before_email(watchlist, user, content)
      NotificationMailer.day_before_notice(
        user.email,
        watchlist.title,
        content
      ).deliver_now
    end
  end
end
