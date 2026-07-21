# frozen_string_literal: true

class AllowNullEmailForUsers < ActiveRecord::Migration[7.1]
  def change
    change_column_default :users, :email, from: "", to: nil
    change_column_null :users, :email, true
  end
end