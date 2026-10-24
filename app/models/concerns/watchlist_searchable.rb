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

    scope :in_year, lambda { |year|
      start_of_year = Time.zone.local(year.to_i, 1, 1)
      start_of_next_year = start_of_year.next_year

      where(
        'COALESCE(start_at, end_at) >= ? AND COALESCE(start_at, end_at) < ?',
        start_of_year,
        start_of_next_year
      )
    }
  end
end
