class WelcomeMailer < ApplicationMailer
  default from: 'no-reply@fanpocket.fun'

  def send_welcome_email(user)
    @user = user
    # メールの添付データとしてロゴ画像を登録（インライン配置用）
    attachments.inline['logo.png'] = File.read(Rails.root.join('app/assets/images/logo.png'))

    mail(
      to: @user.email,
      subject: '【FanPocket】ご登録ありがとうございます！通知の設定が完了しました'
    )
  end
end