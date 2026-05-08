class CreateWatchlists < ActiveRecord::Migration[7.1]
  def change
    create_table :watchlists do |t|
      t.string :title, null: false
      t.text :memo
      t.string :url
      t.datetime :start_at
      t.datetime :end_at
      t.boolean :is_done, default: false, null: false 
      t.string :image
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
