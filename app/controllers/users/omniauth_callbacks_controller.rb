# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def google_oauth2
      handle_omniauth('Google')
    end

    def line
      handle_omniauth('LINE')
    end

    def failure
      redirect_with_alert('SNS認証に失敗しました。もう一度お試しください。')
    end

    private

    def handle_omniauth(provider_name)
      @user = User.from_omniauth(request.env['omniauth.auth'])

      if @user.persisted?
        sign_in_and_redirect @user, event: :authentication
      else
        redirect_to new_user_registration_url,
                    alert: "#{provider_name}ログインに失敗しました。"
      end
    end

    def redirect_with_alert(message)
      redirect_to new_user_session_path, alert: message
    end
  end
end
