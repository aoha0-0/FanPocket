class AddEndAtAutoFilledToWatchlists < ActiveRecord::Migration[7.1]
  def change
    add_column :watchlists, :end_at_auto_filled, :boolean, default: false, null: false
  end
end
