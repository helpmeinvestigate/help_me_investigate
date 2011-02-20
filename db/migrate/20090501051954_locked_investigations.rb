class LockedInvestigations < ActiveRecord::Migration
  def self.up
    add_column :investigations, :locked, :boolean
  end

  def self.down
    remove_column :investigations, :locked
  end
end
