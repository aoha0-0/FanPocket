# frozen_string_literal: true

module WatchlistSchedulable
  extend ActiveSupport::Concern

  def schedule_status
    return :finished if finished?
    return :starting_soon if starting_soon?
    return :deadline_very_soon if deadline_very_soon?
    return :deadline_soon if deadline_soon?

    :normal
  end

  private

  def finished?
    is_done? || (end_at.present? && end_at < Time.current)
  end

  def starting_soon?
    start_at.present? &&
      start_at > Time.current &&
      days_until_start&.between?(0, 3)
  end

  def deadline_very_soon?
    days_until_end&.between?(0, 1)
  end

  def deadline_soon?
    days_until_end&.between?(2, 3)
  end

  def days_until_end
    return if end_at.blank?

    (end_at.to_date - Date.current).to_i
  end

  def days_until_start
    return if start_at.blank?

    (start_at.to_date - Date.current).to_i
  end
end
