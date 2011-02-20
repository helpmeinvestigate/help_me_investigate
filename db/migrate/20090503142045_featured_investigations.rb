class FeaturedInvestigations < ActiveRecord::Migration
  def self.up
    add_column :investigations, :featured, :boolean, :default => false
  end

  def self.down
    remove_column :investigations, :featured
  end
end
