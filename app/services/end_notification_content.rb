# frozen_string_literal: true

class EndNotificationContent
  class << self
    def three_days_prior_title(watchlist)
      watchlist.deadline? ? '締め切りの3日前です' : '終了まであと3日です'
    end

    def three_days_prior_content(watchlist)
      if watchlist.deadline?
        "気になっている「#{watchlist.display_title}」の締め切りまであと3日です。" \
          '忘れないうちにチェックしてみませんか？'
      else
        "気になっている「#{watchlist.display_title}」の終了まであと3日です。" \
          '終了前に、もう一度チェックしてみませんか？'
      end
    end

    def day_before_title(watchlist)
      watchlist.deadline? ? '明日締め切りです' : '終了は明日です'
    end

    def day_before_content(watchlist)
      if watchlist.deadline?
        "気になっている「#{watchlist.display_title}」の締め切りは明日です。" \
          '大切な予定を見逃さないようにご確認ください。'
      else
        "気になっている「#{watchlist.display_title}」の終了は明日です。" \
          '終了前に、もう一度チェックしてみませんか？'
      end
    end

    def deadline_same_day_title(watchlist)
      watchlist.deadline? ? '締め切りは本日です' : '終了は本日です'
    end

    def deadline_same_day_content(watchlist)
      if watchlist.deadline?
        "気になっている「#{watchlist.display_title}」の締め切りは本日です。" \
          '大切な予定を見逃さないようにご確認ください。'
      else
        "気になっている「#{watchlist.display_title}」の終了は本日です。" \
          '終了前に、もう一度チェックしてみませんか？'
      end
    end

    def notification_title_for(watchlist, config)
      return config[:title] unless config[:ending_title]

      watchlist.deadline? ? config[:title] : config[:ending_title]
    end

    def notification_message_for(watchlist, config)
      return config[:message] unless config[:ending_message]

      watchlist.deadline? ? config[:message] : config[:ending_message]
    end

    def three_days_prior_email_subject(watchlist)
      label = watchlist.deadline? ? 'あと3日で締切です' : 'あと3日で終了です'

      "【FanPocket】📅#{label}：#{watchlist.title}"
    end

    def day_before_email_subject(watchlist)
      label = watchlist.deadline? ? '明日締切です' : '明日終了です'

      "【FanPocket】🌟#{label}：#{watchlist.title}"
    end

    def deadline_same_day_email_subject(watchlist)
      label = watchlist.deadline? ? '本日締切です' : '本日終了です'

      "【FanPocket】⏰#{label}：#{watchlist.title}"
    end
  end
end
