class WatchlistsController < ApplicationController
  def new
    @watchlist = current_user.watchlists.build
  end

  def create
    @watchlist = current_user.watchlists.build(watchlist_params)
    if @watchlist.save
      redirect_to root_path, notice: "予定を登録しました" 
      render :new, status: :unprocessable_entity
    end
  end

  private

  def watchlist_params
    params.require(:watchlist).permit(:title, :memo, :url, :start_at, :end_at, :is_done, :image)
  end
end