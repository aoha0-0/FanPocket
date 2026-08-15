# frozen_string_literal: true

module WatchlistsHelper
  BORDER_CLASSES = {
    starting_soon: 'border-[#C0F3B4]',
    deadline_soon: 'border-[#FCF98B]',
    deadline_very_soon: 'border-[#FCC2EC]',
    finished: 'border-gray-300',
    normal: 'border-[#B6E0F3]'
  }.freeze

  BADGE_CLASSES = {
    starting_soon: 'bg-[#C0F3B4]/50',
    deadline_soon: 'bg-[#FCF98B]/50',
    deadline_very_soon: 'bg-[#FCC2EC]/50',
    normal: 'bg-[#B6E0F3]/50'
  }.freeze

  PIN_CLASSES = {
    starting_soon: 'text-[#C0F3B4]',
    deadline_soon: 'text-[#FCF98B]',
    deadline_very_soon: 'text-[#FCC2EC]',
    finished: 'text-gray-300',
    normal: 'text-[#B6E0F3]'
  }.freeze

  def watchlist_border_class(watchlist)
    BORDER_CLASSES.fetch(watchlist.schedule_status)
  end

  def watchlist_badge_class(watchlist)
    BADGE_CLASSES.fetch(watchlist.schedule_status)
  end

  def watchlist_pin_class(watchlist)
    PIN_CLASSES.fetch(watchlist.schedule_status)
  end
end
