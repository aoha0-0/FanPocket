# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def google_oauth2
      @user = User.from_omniauth(request.env['omniauth.auth'])

      return handle_success if @user.persisted?

      handle_failure
    end

    def failure
      redirect_with_alert('Googleでの認証に失敗しました。もう一度お試しください。')
    end

    private

    def handle_success
      flash[:notice] = I18n.t(
        'devise.omniauth_callbacks.success',
        kind: 'Google'
      )
      sign_in_and_redirect @user, event: :authentication
    end

    def handle_failure
      redirect_with_alert('Googleでのログインに失敗しました。もう一度お試しください。')
    end

    def redirect_with_alert(message)
      redirect_to new_user_session_path, alert: message
    end
  end
end
