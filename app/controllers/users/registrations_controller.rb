# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    def edit_email
      self.resource = current_user
    end

    def update_email
      self.resource = current_user

      if resource.update_with_password(email_update_params)
        EmailChangeMailer.email_changed(resource).deliver_now
        bypass_sign_in(resource)
        redirect_to settings_path, notice: 'メールアドレスを更新しました'
      else
        render :edit_email, status: :unprocessable_entity
      end
    end

    protected

    def update_resource(resource, params)
      if params[:password].blank?
        resource.errors.add(:password, :blank)
        false
      else
        resource.update_with_password(params)
      end
    end

    def after_update_path_for(_resource)
      settings_path
    end

    def email_update_params
      params.require(:user).permit(:email, :current_password)
    end
  end
end
