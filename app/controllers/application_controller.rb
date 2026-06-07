class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :set_cache_buster

  private

  # ログイン後のリダイレクト先を指定
  def after_sign_in_path_for(resource)
    root_path 
  end

  # サインアップ後のリダイレクト先を指定
  def after_sign_up_path_for(resource)
    root_path
  end

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end