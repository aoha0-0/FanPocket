class StaticPagesController < ApplicationController
  # topアクションのみ、ログインなしでもアクセス可能にする
  skip_before_action :authenticate_user!, only: [:top]

  def top
  end
end
