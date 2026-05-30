class Watchlist < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: { maximum: 255 }
  validate :start_at_or_end_at_must_be_present
  
  #3日前通知用
  scope :alert_three_days_prior, -> {
    start_of_day = 3.days.from_now.beginning_of_day
    end_of_day   = 3.days.from_now.end_of_day

    where(is_done: false, end_at: start_of_day..end_of_day)
  }

  # 前日通知用：締め切り（end_at）が「明日」の未完了タスク
  scope :alert_day_before, -> {
    start_of_day = 1.day.from_now.beginning_of_day
    end_of_day   = 1.day.from_now.end_of_day

    where(is_done: false, end_at: start_of_day..end_of_day)
  }

  # 当日通知用：締め切り（end_at）が「今日」の未完了タスク
  scope :alert_same_day, -> {
    start_of_day = Time.zone.now.beginning_of_day
    end_of_day   = Time.zone.now.end_of_day

    where(is_done: false, end_at: start_of_day..end_of_day)
  }

  # 今日が開始日かつ未完了のデータを取得
  scope :starting_today, -> {
    where(
      start_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day,
      is_done: false
    )
  }

  private

  def start_at_or_end_at_must_be_present
    if start_at.blank? && end_at.blank?
      errors.add(:base, "開始時間または締切時間のどちらかは入力してください")
    end
  end
end
