class AddReceptionFieldsToWatchlists < ActiveRecord::Migration[7.1]
  def change
    add_column :watchlists, :reception_type, :integer, null: false, default: 0
    add_column :watchlists, :reception_detail, :string
  end
end
