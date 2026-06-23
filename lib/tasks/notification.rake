# frozen_string_literal: true

namespace :notification do
  desc '締切3日前の未対応タスクがあるユーザーに通知を送る'
  task send_3days_prior: :environment do
    targets = Watchlist.alert_three_days_prior.includes(:user)

    puts "--- 3日前通知バッチ処理 開始 (対象: #{targets.count}件) ---"

    targets.find_each do |watchlist|
      user = watchlist.user
      next unless user

      begin
        user_email = user.email
        title      = watchlist.title
        content    = "気になっている「#{watchlist.title}」の締め切りまであと3日です。忘れないうちにチェックしてみませんか？"

        NotificationMailer.three_days_ago_notice(user_email, title, content).deliver_now
        puts "通知送信完了: [Watchlist ID: #{watchlist.id}] to [User: #{user_email}]"

        # 1秒待つ（Resendのレートリミット対策）
        sleep 1
      rescue StandardError => e
        puts "【エラー発生】3日前通知失敗 [Watchlist ID: #{watchlist.id}]: #{e.message}"
      end
    end

    puts '--- 3日前通知バッチ処理 終了 ---'
  end

  desc '締切前日（20時実行想定）の未対応タスクがあるユーザーに通知を送る'
  task send_day_before: :environment do
    targets = Watchlist.alert_day_before.includes(:user)

    puts "--- 前日通知バッチ処理 開始 (対象: #{targets.count}件) ---"

    targets.find_each do |watchlist|
      user = watchlist.user
      next unless user

      begin
        user_email = user.email
        title      = watchlist.title
        content    = "気になっている「#{watchlist.title}」の締め切りは明日です。大切な予定を見逃さないようにご確認ください。"

        NotificationMailer.day_before_notice(user_email, title, content).deliver_now
        puts "前日通知送信完了: [Watchlist ID: #{watchlist.id}] to [User: #{user_email}]"

        # 1秒待つ（Resendのレートリミット対策）
        sleep 1
      rescue StandardError => e
        puts "【エラー発生】前日通知失敗 [Watchlist ID: #{watchlist.id}]: #{e.message}"
      end
    end

    puts '--- 前日通知バッチ処理 終了 ---'
  end

  desc '締切当日（7時実行想定）および【開始日当日（7時）】の未対応タスクがあるユーザーに通知を送る'
  task send_same_day: :environment do
    # --------------------------------------------------
    # 1. 締切当日のリマインド処理（既存の処理）
    # --------------------------------------------------
    deadline_targets = Watchlist.alert_same_day.includes(:user)

    puts "--- 当日締切通知バッチ処理 開始 (対象: #{deadline_targets.count}件) ---"

    deadline_targets.find_each do |watchlist|
      user = watchlist.user
      next unless user

      begin
        user_email = user.email
        title      = watchlist.title
        content    = "気になっている「#{watchlist.title}」の締め切りは本日です。大切な予定を見逃さないようにご確認ください。"

        NotificationMailer.today_notice(user_email, title, content).deliver_now
        puts "当日締切通知送信完了: [Watchlist ID: #{watchlist.id}] to [User: #{user_email}]"

        # 1秒待つ（Resendのレートリミット対策）
        sleep 1
      rescue StandardError => e
        puts "【エラー発生】当日締切通知失敗 [Watchlist ID: #{watchlist.id}]: #{e.message}"
      end
    end

    puts '--- 当日締切通知バッチ処理 終了 ---'

    # --------------------------------------------------
    # 2. 開始日当日のリマインド処理（新しく追加する相乗り処理）
    # --------------------------------------------------
    start_targets = Watchlist.starting_today.includes(:user)

    puts "--- 当日開始通知バッチ処理 開始 (対象: #{start_targets.count}件) ---"

    start_targets.find_each do |watchlist|
      user = watchlist.user
      next unless user

      begin
        user_email = user.email
        title      = watchlist.title
        content    = "気になっている「#{watchlist.title}」の開始は本日です。詳細をチェックしてみませんか？"

        NotificationMailer.start_notice(user_email, title, content).deliver_now
        puts "当日開始通知送信完了: [Watchlist ID: #{watchlist.id}] to [User: #{user_email}]"

        # 1秒待つ（Resendのレートリミット対策）
        sleep 1
      rescue StandardError => e
        puts "【エラー発生】当日開始通知失敗 [Watchlist ID: #{watchlist.id}]: #{e.message}"
      end
    end

    puts '--- 当日開始通知バッチ処理 終了 ---'
  end
end
