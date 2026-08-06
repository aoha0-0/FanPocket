# frozen_string_literal: true

module Internal
  class NotificationsController < ApplicationController
    skip_before_action :authenticate_user!
    skip_forgery_protection

    before_action :authenticate_gas!

    def create
      NotificationService.send_morning_notifications if morning_time?
      NotificationService.send_night_notifications if night_time?
      NotificationService.send_realtime_line_notifications

      head :ok
    end

    private

    def authenticate_gas!
      return if valid_gas_token?

      head :unauthorized
    end

    def valid_gas_token?
      ActiveSupport::SecurityUtils.secure_compare(
        request.headers['X-Notification-Token'].to_s,
        ENV.fetch('GAS_NOTIFICATION_TOKEN')
      )
    end

    def morning_time?
      Time.current.hour == 7
    end

    def night_time?
      Time.current.hour == 20
    end
  end
end
