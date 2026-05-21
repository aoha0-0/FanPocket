class WatchlistsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_watchlist, only: [:show, :edit, :update]

 def index
    # 1. 「これからの予定」：まだ完了していなくて（is_done: false）、終了日時が未来、または未設定のもの
    @future_watchlists = current_user.watchlists
                                     .where(is_done: false)
                                     .where("end_at >= ? OR end_at IS NULL", Time.current)
                                     .order(start_at: :asc)

    # 2. 「これまでの足跡」：すでに完了している（is_done: true）か、または終了日時が過去のもの
    @past_watchlists = current_user.watchlists
                                   .where(is_done: true)
                                   .or(current_user.watchlists.where("end_at < ?", Time.current))
                                   .order(end_at: :desc)
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

  def test_mail
   # 即席でメールを送信するコマンド
    ActionMailer::Base.mail(
      from: "info@fanpocket.fun", 
      to: "aquarium.swing@gmail.com", 
      subject: "本番環境からの疎通テスト", 
      body: "Resendと独自ドメインの紐付けテストです。これが届いていれば成功です！"
    ).deliver_now

    render plain: "テストメールを送信しました！Gmailを確認してください。"
  end
 
  private

  def set_watchlist
    @watchlist = current_user.watchlists.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    # 他人のIDを指定して探せなかった場合、一覧へ戻す
    redirect_to watchlists_path, alert: "指定されたページは見つかりません"
  end

  def watchlist_params
    params.require(:watchlist).permit(:title, :memo, :url, :start_at, :end_at, :is_done)
  end
end