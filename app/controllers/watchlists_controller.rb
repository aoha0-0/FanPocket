class WatchlistsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_watchlist, only: [:show, :edit, :update]

  def index
    @watchlists =current_user.watchlists.order(start_at: :asc, end_at: :asc)
  end

  def show
  end

  def new
    @watchlist = current_user.watchlists.build
  end

  def create
    @watchlist = current_user.watchlists.build(watchlist_params)
    if @watchlist.save
      redirect_to watchlists_path, notice: "新しい予定を登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @watchlist.update(watchlist_params)
      redirect_to watchlist_path(@watchlist), notice: "更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    watchlist = current_user.watchlists.find(params[:id])
    watchlist.destroy!
    redirect_to watchlists_path, notice: 'これからの予定から削除しました', status: :see_other
end
 
  private

  def set_watchlist
    @watchlist = current_user.watchlists.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    # 他人のIDを指定して探せなかった場合、一覧へ戻す
    redirect_to watchlists_path, alert: "指定されたページは見つかりません"
  end

  def watchlist_params
    params.require(:watchlist).permit(:title, :memo, :url, :start_at, :end_at, :is_done, :image)
  end
end