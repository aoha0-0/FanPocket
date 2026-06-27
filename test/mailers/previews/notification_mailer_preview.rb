# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/notification_mailer
class NotificationMailerPreview < ActionMailer::Preview

  def send_notice
    NotificationMailer.send_notice(
      "test@example.com",
      "ファンミーティング開催決定！",
      "来月、特別なファンミーティングを開催することが決定しました！詳細はアプリ内をご確認ください。"
    )
  end

  def three_days_ago_notice
    NotificationMailer.three_days_ago_notice(
      "test@example.com",
      "限定グッズの事前予約",
      "会員限定グッズの事前予約受付が、あと3日で締め切りとなります。"
    )
  end

  def day_before_notice
    NotificationMailer.day_before_notice(
      "test@example.com",
      "バースデーメッセージの募集",
      "大切な推しへのバースデーメッセージの締め切りは明日です！お忘れなきようご注意ください。"
    )
  end

  def today_notice
    NotificationMailer.today_notice(
      "test@example.com",
      "継続特典の申し込み",
      "早期継続特典の申し込み締め切りは本日23:59までとなっています。"
    )
  end

  def start_notice
    NotificationMailer.start_notice(
      "test@example.com",
      "夏のフォトコンテスト",
      "本日より、夏のフォトコンテストの投稿受付がスタートしました！"
    )
  end

end
