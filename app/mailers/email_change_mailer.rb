# frozen_string_literal: true

class EmailChangeMailer < ApplicationMailer
  default from: 'no-reply@fanpocket.fun'

  def email_changed(user)
    @user = user

    mail(
      to: @user.email,
      subject: '【FanPocket】メールアドレスを変更しました'
    )
  end
end
