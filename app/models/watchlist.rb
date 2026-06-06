class Watchlist < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: { maximum: 255 }
  validate :start_at_or_end_at_must_be_present

  VALID_URL_REGEX = /\Ahttps?:\/\/[\S]+\z/
  validates :url, allow_blank: true, format: { with: VALID_URL_REGEX }

  validate :end_at_must_be_future
  
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

  # 開始時間または締切時間のどちらかは必須
  def start_at_or_end_at_must_be_present
    if start_at.blank? && end_at.blank?
      errors.add(:base, "開始日時または締切日時のどちらかは入力してください")
    end
  end

  # 両方入力されている場合のみ、日時の矛盾（開始日 < 締切日）をチェック
  def end_at_must_be_after_start_at
    if start_at.present? && end_at.present? && end_at <= start_at
      errors.add(:end_at, :must_be_after_start_at)
    end
  end

  def end_at_must_be_future
    if end_at.present? && end_at < Time.current
    errors.add(:end_at, "は未来の日時を選択してください")
    end
  end
end
