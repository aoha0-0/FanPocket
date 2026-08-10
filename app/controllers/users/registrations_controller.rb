# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
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
  end
end
