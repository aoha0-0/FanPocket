# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :watchlist

  enum :notification_type, {
    deadline_three_days_before: 0,
    deadline_day_before: 1,
    deadline_same_day: 2,
    start_same_day: 3,
    start_ten_minutes_before: 4,
    deadline_three_hours_before: 5
  }

  validates :notification_type, presence: true
  validates :title, presence: true
  validates :message, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }

  def read?
    read_at.present?
  end

  def mark_as_read!
    update!(read_at: Time.current) unless read?
  end
end
