# frozen_string_literal: true

class NotificationDelivery < ApplicationRecord
  belongs_to :watchlist

  enum :channel, {
    email: 0,
    line: 1
  }

  enum :notification_type, {
    deadline_three_days_before: 0,
    deadline_day_before: 1,
    deadline_same_day: 2,
    start_same_day: 3
  }

  validates :channel, presence: true
  validates :notification_type, presence: true
  validates :watchlist_id,
            uniqueness: {
              scope: %i[channel notification_type]
            }
end
