class CompletedInvestigations < ActiveRecord::Migration
  def self.up
    add_column :investigations, :completed, :boolean
  end

  def self.down
    remove_column :investigations, :completed
  end
end
