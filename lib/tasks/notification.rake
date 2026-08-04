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

  desc '直前LINE通知を送信する'
  task send_realtime_line: :environment do
    NotificationService.send_realtime_line_notifications
  end
end
