Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("REDIS_URL") }
  config.average_scheduled_poll_interval = 300
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch("REDIS_URL") }
end