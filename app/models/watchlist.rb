class Watchlist < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: { maximum: 255 }
  validate :start_at_or_end_at_must_be_present

  private

  def start_at_or_end_at_must_be_present
    if start_at.blank? && end_at.blank?
      errors.add(:base, "開始時間または締切時間のどちらかは入力してください")
    end
  end
end
