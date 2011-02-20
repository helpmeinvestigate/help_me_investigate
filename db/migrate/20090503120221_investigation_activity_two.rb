class InvestigationActivityTwo < ActiveRecord::Migration
  def self.up
    add_column :investigations, :activities_count, :integer
  end

  def self.down
    remove_column :investigations, :activities_count
  end
end
