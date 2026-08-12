# frozen_string_literal: true

class WatchlistTag < ApplicationRecord
  belongs_to :watchlist
  belongs_to :tag

  validates :tag_id, uniqueness: { scope: :watchlist_id }
end
