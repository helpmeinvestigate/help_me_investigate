class AddCompletedToChallenges < ActiveRecord::Migration
  def self.up
    add_column :challenges, :completed, :boolean
    add_column :challenges, :completed_at, :datetime
  end

  def self.down
    remove_column :challenges, :completed
    remove_column :challenges, :completed_at
  end
end
