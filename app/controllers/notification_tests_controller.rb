class NotificationTestsController < ApplicationController
  def run_test
    if params[:secret] != "my_test_secret_123"
      render plain: "Unauthorized", status: :unauthorized and return
    end

    results = []

    # --- Step 1: タイムゾーン確認 ---
    results << "=== 1. TimeZone Check ==="
    results << "Rails TimeZone: #{Time.zone.name}"
    results << "Rails Current Time: #{Time.zone.now}"
    results << "DB Current Time: #{ActiveRecord::Base.connection.select_value('SELECT NOW()')}"

    # --- Step 2: テストデータ作成 ---
    results << "\n=== 2. Create Test Data ==="
    my_email = "aoha@example.com"
    user = User.find_by(email: my_email)

    if user.nil?
      render plain: "Error: ユーザー(#{my_email})が見つかりません。先に本番環境でユーザー登録するか、存在するメールアドレスを指定してください。" and return
    end
    
    # すでに古いテストデータがあれば一旦消す
    Watchlist.where("title LIKE ?", "【開始日テスト%】").destroy_all

    # パターン1: 今日が開始日（対象）
    Watchlist.create!(
      user: user, 
      title: "【開始日テスト】本日開始の推し活タスク", 
      start_at: Time.zone.now, 
      end_at: 3.days.from_now, 
      is_done: false
    )
    # パターン2: 今日が開始日だが完了済み（対象外）
    Watchlist.create!(
      user: user, 
      title: "【開始日テスト対象外】完了済みの予定", 
      start_at: Time.zone.now, 
      end_at: 3.days.from_now, 
      is_done: true
    )
    # パターン3: 明日が開始日（対象外）
    Watchlist.create!(
      user: user, 
      title: "【開始日テスト対象外】明日からの予定", 
      start_at: 1.day.from_now, 
      end_at: 5.days.from_now, 
      is_done: false
    )

    results << "Test data created successfully."

    # --- Step 3: 抽出ロジック＆メール送信（Rakeタスクの相乗り処理の再現） ---
    results << "\n=== 3. Target Extraction ==="
    targets = Watchlist.starting_today.includes(:user) 
    results << "Extracted count: #{targets.count} (Expected: 1)"
    
    targets.each do |watchlist|
      results << "- #{watchlist.title} (User: #{watchlist.user.email})"
      
      user_email = watchlist.user.email
      title      = watchlist.title
      content    = "「気になっている#{watchlist.title}」の購入・申込開始は本日です。忘れないうちにチェックしてみませんか？"

      NotificationMailer.start_notice(user_email, title, content).deliver_now
      results << "  -> Mail delivered to #{user_email}"
    end

    render plain: results.join("\n")
  rescue => e
    render plain: "Error occurred: #{e.message}\n#{e.backtrace.join("\n")}", status: :internal_server_error
  end

  # テストデータのクリーンアップ用URL
  def cleanup
    if params[:secret] != "my_test_secret_123"
      render plain: "Unauthorized", status: :unauthorized and return
    end

    Watchlist.where("title LIKE ?", "【開始日テスト%】").destroy_all
    render plain: "Cleanup completed."
  end
end