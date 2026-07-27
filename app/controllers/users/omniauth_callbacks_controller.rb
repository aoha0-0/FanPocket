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
      redirect_to new_user_session_path,
                  alert: 'SNS認証に失敗しました。もう一度お試しください。'
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
      result = User.from_omniauth(auth)
      user = result[:user]

      flash[:notice] = login_message(result[:created], provider_name)

      sign_in_and_redirect user, event: :authentication
    rescue ActiveRecord::RecordInvalid
      redirect_to new_user_registration_path,
                  alert: "#{provider_name}アカウントでの登録に失敗しました。"
    end

    def login_message(created, provider_name)
      if created
        "#{provider_name}アカウントで新規登録しました。"
      else
        "#{provider_name}アカウントでログインしました。"
      end
    end

    def handle_account_linking(auth, provider_name)
      result = current_user.link_social_account(auth)

      send_line_linked_message(auth) if line_linked_successfully?(auth, result)

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

    def line_linked_successfully?(auth, result)
      result == :success && auth.provider == 'line'
    end

    def send_line_linked_message(auth)
      LineMessagingService.push_text(
        auth.uid,
        <<~MESSAGE.strip
          LINE連携が完了しました！🎉

          FanPocketをご利用いただきありがとうございます。
          大切な予定を見逃さないよう、LINEでお知らせします。
        MESSAGE
      )
    end
  end
end
