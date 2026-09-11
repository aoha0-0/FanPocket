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

  def watchlist_share_text(watchlist)
    [
      watchlist.title,
      share_dates(watchlist),
      share_reception(watchlist),
      watchlist.url.presence
    ].compact.join("\n\n")
  end

  def share_dates(watchlist)
    dates = []
    dates << "開始：#{watchlist.start_at.strftime('%Y/%m/%d %H:%M')}" if watchlist.start_at.present?
    dates << "締切：#{watchlist.end_at.strftime('%Y/%m/%d %H:%M')}" if watchlist.end_at.present?

    dates.presence&.join("\n")
  end

  def share_reception(watchlist)
    reception = []
    reception << "受付種別：#{watchlist.reception_type_label}" if watchlist.reception_type != 'not_set'
    reception << "受付種別詳細：#{watchlist.reception_detail}" if watchlist.reception_detail.present?

    reception.presence&.join("\n")
  end
end
