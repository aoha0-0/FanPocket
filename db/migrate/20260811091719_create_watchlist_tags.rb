class CreateWatchlistTags < ActiveRecord::Migration[7.1]
  def change
    create_table :watchlist_tags do |t|
      t.references :watchlist, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end

    add_index :watchlist_tags, %i[watchlist_id tag_id], unique: true
  end
end