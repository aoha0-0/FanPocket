class CreateTags < ActiveRecord::Migration[7.1]
  def change
    create_table :tags do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false

      t.timestamps
    end

    add_index :tags, %i[user_id name], unique: true
  end
end
