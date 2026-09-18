# frozen_string_literal: true

module WatchlistNotifiable
  extend ActiveSupport::Concern

  included do
    scope :end_at_notification_targets, lambda {
      where(end_type: :deadline)
        .or(where(end_type: :ending, ending_notification_enabled: true))
    }

    scope :alert_three_days_prior, lambda {
      end_at_notification_targets
        .where(is_done: false, end_at: 3.days.from_now.all_day, end_at_auto_filled: false)
    }
    scope :alert_day_before, lambda {
      end_at_notification_targets.where(is_done: false, end_at: 1.day.from_now.all_day, end_at_auto_filled: false)
    }
    scope :alert_same_day, lambda {
      end_at_notification_targets.where(is_done: false, end_at: Time.current.all_day, end_at_auto_filled: false)
    }
    scope :starting_today, -> { where(start_at: Time.current.all_day, is_done: false) }

    scope :starting_within_ten_minutes, lambda { |current_time = Time.current|
      where(is_done: false)
        .where('start_at > ? AND start_at <= ?', current_time, current_time + 10.minutes)
    }

    scope :deadline_three_hours_before, lambda { |current_time = Time.current|
      notification_limit = current_time + 3.hours

      end_at_notification_targets
        .where(is_done: false, end_at_auto_filled: false)
        .where('end_at > ? AND end_at <= ?', notification_limit - 10.minutes, notification_limit)
    }
  end
end
