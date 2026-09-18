class AddEndTypeToWatchlists < ActiveRecord::Migration[7.1]
  def change
    add_column :watchlists, :end_type, :integer, default: 0, null: false
  end
end
