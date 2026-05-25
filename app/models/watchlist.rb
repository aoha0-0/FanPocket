class Watchlist < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: { maximum: 255 }
  validate :start_at_or_end_at_must_be_present

  scope :alert_three_days_prior, -> {
    start_of_day = 3.days.from_now.beginning_of_day
    end_of_day   = 3.days.from_now.end_of_day

    where(is_done: false, end_at: start_of_day..end_of_day)
  }

  private

  def start_at_or_end_at_must_be_present
    if start_at.blank? && end_at.blank?
      errors.add(:base, "開始時間または締切時間のどちらかは入力してください")
    end
  end
end
