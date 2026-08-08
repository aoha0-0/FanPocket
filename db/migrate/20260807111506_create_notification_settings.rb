class CreateNotificationSettings < ActiveRecord::Migration[7.1]
  def change
    create_table :notification_settings do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.boolean :email_three_days_before, null: false, default: true
      t.boolean :email_day_before, null: false, default: true
      t.boolean :email_deadline_same_day, null: false, default: true
      t.boolean :email_start_same_day, null: false, default: true
      t.boolean :line_start_ten_minutes_before, null: false, default: true
      t.boolean :line_deadline_three_hours_before, null: false, default: true

      t.timestamps
    end
  end
end