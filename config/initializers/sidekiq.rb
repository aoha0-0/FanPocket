Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL') }
  
  # 予定ジョブ（Scheduled Job）のチェック間隔を5分に広げ、通信回数を激減させる
  config.options[:scheduled_poll_interval] = 300
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL') }
end