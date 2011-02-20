class LockedChallenges < ActiveRecord::Migration
  def self.up
    add_column :challenges, :locked, :boolean
  end

  def self.down
    remove_column :challenges, :locked
  end
end
