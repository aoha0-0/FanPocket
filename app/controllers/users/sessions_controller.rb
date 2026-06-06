# app/controllers/users/sessions_controller.rb
class Users::SessionsController < Devise::SessionsController
  def new
    # Deviseが設定する「ログインしてください」の文言と一致する場合のみ、初回アラートを消去
    if flash[:alert] == I18n.t('devise.failure.unauthenticated')
      flash.delete(:alert)
    end
    super
  end
end