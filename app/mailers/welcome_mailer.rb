class WelcomeMailer < ApplicationMailer
  default from: 'no-reply@fanpocket.fun'

  def send_welcome_email(user)
    @user = user

    mail(
      to: @user.email,
      subject: '【FanPocket】ご登録ありがとうございます！通知の設定が完了しました'
    )
  end
end