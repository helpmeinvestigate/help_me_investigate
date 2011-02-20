class DefaultInvCount < ActiveRecord::Migration
  def self.up
    remove_column :investigations, :investigatings_count
    add_column :investigations, :investigatings_count, :integer, :default => 0
  end

  def self.down
  end
end
