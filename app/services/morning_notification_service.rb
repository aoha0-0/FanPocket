# frozen_string_literal: true

class MorningNotificationService
  class << self
    include NotificationDeliverySupport

    def call
      send_deadline_same_day
      send_start_same_day
    end

    private

    def send_deadline_same_day
      targets = Watchlist.alert_same_day.includes(:user)

      log_start('当日締切', targets.count)
      targets.find_each { |watchlist| send_deadline_same_day_notification(watchlist) }
      log_finish('当日締切')
    end

    def send_deadline_same_day_notification(watchlist)
      user = watchlist.user
      return unless user
      return if delivered?(watchlist, :email, :deadline_same_day)

      deliver_deadline_same_day_notification(watchlist, user)
    rescue StandardError => e
      log_error('当日締切', watchlist.id, e)
    end

    def deliver_deadline_same_day_notification(watchlist, user)
      content = deadline_same_day_content(watchlist)

      NotificationMailer.today_notice(
        user.email,
        watchlist.title,
        content
      ).deliver_now

      record_delivery(watchlist, :email, :deadline_same_day)

      log_success('当日締切', watchlist.id, user.email)
      sleep 1
    end

    def deadline_same_day_content(watchlist)
      "気になっている「#{watchlist.display_title}」の締め切りは本日です。" \
        '大切な予定を見逃さないようにご確認ください。'
    end

    def send_start_same_day
      targets = Watchlist.starting_today.includes(:user)

      log_start('当日開始', targets.count)
      targets.find_each { |watchlist| send_start_same_day_notification(watchlist) }
      log_finish('当日開始')
    end

    def send_start_same_day_notification(watchlist)
      user = watchlist.user
      return unless user
      return if delivered?(watchlist, :email, :start_same_day)

      deliver_start_same_day_notification(watchlist, user)
    rescue StandardError => e
      log_error('当日開始', watchlist.id, e)
    end

    def deliver_start_same_day_notification(watchlist, user)
      content = start_same_day_content(watchlist)

      NotificationMailer.start_notice(
        user.email,
        watchlist.title,
        content
      ).deliver_now

      record_delivery(watchlist, :email, :start_same_day)

      log_success('当日開始', watchlist.id, user.email)
      sleep 1
    end

    def start_same_day_content(watchlist)
      "気になっている「#{watchlist.display_title}」の開始は本日です。" \
        '詳細をチェックしてみませんか？'
    end
  end
end
