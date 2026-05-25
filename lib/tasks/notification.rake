namespace :notification do
  desc "締切3日前の未対応タスクがあるユーザーに通知を送る"
  task send_3days_prior: :environment do
    targets = Watchlist.alert_three_days_prior

    puts "--- 3日前通知バッチ処理 開始 (対象: #{targets.count}件) ---"

    targets.each do |watchlist|
      user = watchlist.user
      
      user_email = user.email
      title      = watchlist.title
      content    = "「#{watchlist.title}」の締め切りまであと3日です。大切な予定を見逃さないようにご確認ください。" 

      NotificationMailer.three_days_ago_notice(user_email, title, content).deliver_now
      
      puts "通知送信完了: [Watchlist ID: #{watchlist.id}] to [User: #{user_email}]"
    end

    puts "--- 3日前通知バッチ処理 終了 ---"
  end
end