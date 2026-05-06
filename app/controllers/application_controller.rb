class ApplicationController < ActionController::Base
  # ログイン済ユーザーのみにアクセスを許可する
  before_action :authenticate_user!
end
