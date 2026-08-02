class CreateNotificationDeliveries < ActiveRecord::Migration[7.1]
  def change
    create_table :notification_deliveries do |t|
      t.references :watchlist, null: false, foreign_key: true
      t.integer :channel, null: false
      t.integer :notification_type, null: false
      t.datetime :sent_at

      t.timestamps
    end

    add_index :notification_deliveries,
          %i[watchlist_id channel notification_type],
          unique: true
  end
end
