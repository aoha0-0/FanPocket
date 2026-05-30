class NotificationMailer < ApplicationMailer
  default from: 'noreply@fanpocket.fun'

  def send_notice(user_email, title, content)
    @title = title
    @content = content

    mail(
      to: user_email,
      subject: "【FanPocket】新しいお知らせ: #{@title}"
    )
  end

  # 3日前通知
  def three_days_ago_notice(user_email, title, content)
    @title = title
    @content = content
    mail(to: user_email, subject: "【FanPocket】あと3日で締切：#{@title}")
  end

  # 前日20時通知
  def day_before_notice(user_email, title, content)
    @title = title
    @content = content
    mail(to: user_email, subject: "【重要】明日締切：#{@title}")
  end

  # 当日7時通知
  def today_notice(user_email, title, content)
    @title = title
    @content = content
    mail(to: user_email, subject: "【本日締切】お忘れではありませんか？：#{@title}")
  end

  def start_notice(user_email, title, content) # メソッド名をファイル名に合わせる
  @title = title
  @content = content

  mail(to: user_email,subject: "【FanPocket】今日開始です：#{@title}"
  )
end
end
