# frozen_string_literal: true

module NotificationDeliverySupport
  private

  def delivered?(watchlist, channel, notification_type)
    watchlist.notification_deliveries.exists?(
      channel: channel,
      notification_type: notification_type
    )
  end

  def record_delivery(watchlist, channel, notification_type)
    watchlist.notification_deliveries.create!(
      channel: channel,
      notification_type: notification_type,
      sent_at: Time.current
    )
  end

  def log_start(type, count)
    Rails.logger.info("#{type}通知処理を開始します（対象: #{count}件）")
  end

  def log_finish(type)
    Rails.logger.info("#{type}通知処理を終了しました")
  end

  def log_success(type, watchlist_id, email)
    Rails.logger.info(
      "#{type}通知を送信しました " \
      "[Watchlist ID: #{watchlist_id}] [User: #{email}]"
    )
  end

  def log_error(type, watchlist_id, error)
    Rails.logger.error(
      "#{type}通知に失敗しました " \
      "[Watchlist ID: #{watchlist_id}] [Error: #{error.message}]"
    )
  end
end
