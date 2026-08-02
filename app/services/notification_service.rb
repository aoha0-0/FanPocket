# frozen_string_literal: true

class NotificationService
  class << self
    def send_morning_notifications
      MorningNotificationService.call
    end

    def send_night_notifications
      NightNotificationService.call
    end
  end
end
