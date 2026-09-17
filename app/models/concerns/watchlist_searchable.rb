# frozen_string_literal: true

module WatchlistSearchable
  extend ActiveSupport::Concern

  included do
    scope :tagged_with, lambda { |keyword|
      sanitized_keyword = sanitize_sql_like(keyword)

      where(
        id: WatchlistTag
            .joins(:tag)
            .where('tags.name ILIKE ?', "%#{sanitized_keyword}%")
            .select(:watchlist_id)
      )
    }

    scope :title_containing, lambda { |keyword|
      sanitized_keyword = sanitize_sql_like(keyword)

      where('title ILIKE ?', "%#{sanitized_keyword}%")
    }
  end
end
