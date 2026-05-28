class NotificationTestsController < ApplicationController
  def run_test
    # 悪意のあるアクセスを防ぐ合言葉
    if params[:secret] != "my_test_secret_123"
      render plain: "Unauthorized", status: :unauthorized and return
    end

    results = []

    # --- Step 1: タイムゾーン確認 ---
    results << "=== 1. TimeZone Check ==="
    results << "Rails TimeZone: #{Time.zone.name}"
    results << "Rails Current Time: #{Time.zone.now}"
    results << "DB Current Time: #{ActiveRecord::Base.connection.select_value('SELECT NOW()')}"

    # 古いテストデータがあれば一旦綺麗に消す
    Watchlist.where("title LIKE ?", "【対象%】").destroy_all

    # テスト用ユーザーの準備
    # ユーザーA, BがすでにDBにいれば取得、いなければ新しく作成する（!を外して安全に処理）
    user_a = User.find_by(email: 'your_email+userA@example.com')
    unless user_a
      user_a = User.new(email: 'your_email+userA@example.com', password: 'password123')
      user_a.save(validate: false) # テスト用なので他のバリデーションをスキップして強制保存
    end

    user_b = User.find_by(email: 'your_email+userB@example.com')
    unless user_b
      user_b = User.new(email: 'your_email+userB@example.com', password: 'password123')
      user_b.save(validate: false) # テスト用なので強制保存
    end

    results << "\n=== 2. Creating Data & Running Extraction ==="

    # =========================================================================
    # パターン①: 【3日前】のテスト
    # =========================================================================
    results << "\n--- [Pattern 1] 3日前通知の検証 ---"
    target_3_days = 3.days.from_now
    
    # 送信対象を作成
    Watchlist.create!(user: user_a, title: "【対象】ユーザーAの3日前タスク", end_at: target_3_days.beginning_of_day + 12.hours, is_done: false)
    
    targets_3_days = Watchlist.alert_three_days_prior
    results << "3日前・抽出件数: #{targets_3_days.count}件 (期待値: 1件)"
    
    targets_3_days.each do |watchlist|
      results << "- ジョブ投入: #{watchlist.title}"
      content = "「#{watchlist.title}」の締め切りまであと3日です。大切な予定を見逃さないようにご確認ください。"
      NotificationMailer.three_days_ago_notice(watchlist.user.email, watchlist.title, content).deliver_later
    end

    # =========================================================================
    # パターン②: 【前日20時】のテスト
    # =========================================================================
    results << "\n--- [Pattern 2] 前日20時通知の検証 ---"
    target_tomorrow = 1.day.from_now
    
    # 送信対象を作成
    Watchlist.create!(user: user_b, title: "【対象】ユーザーBの前日20時タスク", end_at: target_tomorrow.beginning_of_day + 20.hours, is_done: false)
    
    # 抽出ロジックの実行 
    targets_tomorrow = Watchlist.alert_day_before
    results << "前日20時・抽出件数: #{targets_tomorrow.count}件 (期待値: 1件)"
    
    targets_tomorrow.each do |watchlist|
      results << "- ジョブ投入: #{watchlist.title}"
      content = "「#{watchlist.title}」の締め切りが明日に迫っています。大切な予定を見逃さないようにご確認ください。"
      NotificationMailer.three_days_ago_notice(watchlist.user.email, watchlist.title, content).deliver_later
    end

    # =========================================================================
    # パターン③: 【当日7時】のテスト
    # =========================================================================
    results << "\n--- [Pattern 3] 当日7時通知の検証 ---"
    target_today = Time.zone.now
    
    # 送信対象を作成
    Watchlist.create!(user: user_a, title: "【対象】ユーザーAの当日7時タスク", end_at: target_today.beginning_of_day + 7.hours, is_done: false)
    
    # 抽出ロジックの実行 
    targets_today = Watchlist.alert_same_day
    results << "当日7時・抽出件数: #{targets_today.count}件 (期待値: 1件)"
    
    targets_today.each do |watchlist|
      results << "- ジョブ投入: #{watchlist.title}"
      content = "「#{watchlist.title}」の締め切りは本日です。大切な予定を見逃さないようにご確認ください。"
      NotificationMailer.three_days_ago_notice(watchlist.user.email, watchlist.title, content).deliver_later
    end

    render plain: results.join("\n")
  rescue => e
    render plain: "Error: #{e.message}\n#{e.backtrace.join("\n")}", status: :internal_server_error
  end

  # クリーンアップ用URL
  def cleanup
    if params[:secret] != "my_test_secret_123"
      render plain: "Unauthorized", status: :unauthorized and return
    end
    Watchlist.where("title LIKE ?", "【対象%】").destroy_all
    User.where(email: ['your_email+userA@example.com', 'your_email+userB@example.com']).destroy_all
    render plain: "Cleanup completed."
  end
end