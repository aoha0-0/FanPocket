# frozen_string_literal: true

# app/controllers/users/sessions_controller.rb
module Users
  class SessionsController < Devise::SessionsController
    def new
      # Deviseが設定する「ログインしてください」の文言と一致する場合のみ、初回アラートを消去
      flash.delete(:alert) if flash[:alert] == I18n.t('devise.failure.unauthenticated')
      super
    end
  end
end
