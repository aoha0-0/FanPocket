# frozen_string_literal: true

class Tag < ApplicationRecord
  belongs_to :user

  has_many :watchlist_tags, dependent: :destroy
  has_many :watchlists, through: :watchlist_tags

  validates :name, presence: true, uniqueness: { scope: :user_id }
end
