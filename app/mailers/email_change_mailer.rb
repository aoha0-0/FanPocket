# frozen_string_literal: true

class EmailChangeMailer < ApplicationMailer
  def email_changed(user)
    @user = user

    mail(
      to: @user.email,
      subject: '【FanPocket】メールアドレスを変更しました'
    )
  end
end
