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
      auth = request.env['omniauth.auth']

      if linking?
        handle_account_linking(auth, provider_name)
      else
        handle_login(auth, provider_name)
      end
    end

    def handle_login(auth, provider_name)
      @user = User.from_omniauth(auth)

      if @user.persisted?
        sign_in_and_redirect @user, event: :authentication
      else
        redirect_to new_user_registration_url,
                    alert: "#{provider_name}ログインに失敗しました。"
      end
    end

    def handle_account_linking(auth, provider_name)
      result = current_user.link_social_account(auth)

      redirect_to settings_path,
                  flash_type(result) => flash_message(result, provider_name)
    end

    def flash_type(result)
      result == :success ? :notice : :alert
    end

    def flash_message(result, provider_name)
      case result
      when :success
        "#{provider_name}アカウントを連携しました。"
      when :already_linked
        "#{provider_name}アカウントは既に連携済みです。"
      when :taken
        "この#{provider_name}アカウントは、別のユーザーに連携されています。"
      else
        "#{provider_name}アカウントの連携に失敗しました。"
      end
    end

    def linking?
      request.env.dig('omniauth.params', 'purpose') == 'link'
    end
  end
end
