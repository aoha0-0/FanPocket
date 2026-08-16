class AddOnboardingCompletedAtToUsers < ActiveRecord::Migration[7.1]
  class MigrationUser < ActiveRecord::Base
    self.table_name = 'users'
  end

  def up
    add_column :users, :onboarding_completed_at, :datetime

    MigrationUser.reset_column_information
    MigrationUser.update_all(onboarding_completed_at: Time.current)
  end

  def down
    remove_column :users, :onboarding_completed_at
  end
end