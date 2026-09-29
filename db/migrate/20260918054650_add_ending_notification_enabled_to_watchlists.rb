class AddEndingNotificationEnabledToWatchlists < ActiveRecord::Migration[7.1]
  def change
    add_column :watchlists, :ending_notification_enabled, :boolean, default: false, null: false
  end
end
