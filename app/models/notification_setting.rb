# frozen_string_literal: true

class NotificationSetting < ApplicationRecord
  belongs_to :user
  has_one :notification_setting, dependent: :destroy
end
