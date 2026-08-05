# frozen_string_literal: true

class InAppNotificationService
  class << self
    def create!(watchlist:, notification_type:, title:, message:)
      Notification.find_or_create_by!(
        user: watchlist.user,
        watchlist: watchlist,
        notification_type: notification_type
      ) do |notification|
        notification.title = title
        notification.message = message
      end
    end
  end
end
