class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :watchlist, null: false, foreign_key: true

      t.integer :notification_type, null: false
      t.string :title, null: false
      t.text :message, null: false
      t.datetime :read_at

      t.timestamps
    end
  end
end