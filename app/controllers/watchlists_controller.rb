# app/controllers/watchlists_controller.rb
class WatchlistsController < ApplicationController
  before_action :authenticate_user! # Deviseを使っている場合、ログイン必須にする

  def index
    @watchlists = Watchlist.order(start_at: :asc, end_at: :asc)
  end

  def show
    @watchlist = Watchlist.find(params[:id])
  end

  def new
    @watchlist = current_user.watchlists.build
  end

  def create
    @watchlist = current_user.watchlists.build(watchlist_params)
    if @watchlist.save
      redirect_to watchlists_path, notice: "新しい予定を登録しました"
    else
      # 保存に失敗（バリデーションエラー）した時、new画面を再表示する
      render :new, status: :unprocessable_entity
    end
  end

  private

  def watchlist_params
    params.require(:watchlist).permit(:title, :memo, :url, :start_at, :end_at, :is_done, :image)
  end
end