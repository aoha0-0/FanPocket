# frozen_string_literal: true

module RealtimeLineNotificationConfig
  CONFIGS = {
    start_ten_minutes_before: {
      log_type: '開始10分前LINE',
      notification_type: :start_ten_minutes_before,
      setting_key: :line_start_ten_minutes_before,
      title: '開始まであと10分です',
      message: "開始まであと10分です。\n\nまもなく始まります。\n詳細をご確認ください。"
    },
    deadline_three_hours_before: {
      log_type: '締切3時間前LINE',
      notification_type: :deadline_three_hours_before,
      setting_key: :line_deadline_three_hours_before,
      title: '締め切りまであと3時間です',
      message: "締め切りまであと3時間です。\n\n大切な予定を見逃さないようご確認ください。"
    }
  }.freeze
end
