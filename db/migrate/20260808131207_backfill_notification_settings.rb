class BackfillNotificationSettings < ActiveRecord::Migration[7.1]
  def up
    execute <<~SQL.squish
      INSERT INTO notification_settings (user_id, created_at, updated_at)
      SELECT users.id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM users
      WHERE NOT EXISTS (
        SELECT 1
        FROM notification_settings
        WHERE notification_settings.user_id = users.id
      )
    SQL
  end

  def down
    # バックフィルした設定だけを安全に特定できないため削除しない
  end
end