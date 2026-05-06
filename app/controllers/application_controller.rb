class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  private

  # ログイン後のリダイレクト先を指定
  def after_sign_in_path_for(resource)
    root_path 
  end

  # サインアップ後のリダイレクト先を指定
  def after_sign_up_path_for(resource)
    root_path
  end
end