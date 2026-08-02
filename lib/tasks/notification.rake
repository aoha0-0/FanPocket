# frozen_string_literal: true

namespace :notification do
  desc '朝通知を送信する'
  task send_morning: :environment do
    NotificationService.send_morning_notifications
  end

  desc '夜通知を送信する'
  task send_night: :environment do
    NotificationService.send_night_notifications
  end
end
