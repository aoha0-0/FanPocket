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
end
