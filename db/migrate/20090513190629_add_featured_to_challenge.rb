class AddFeaturedToChallenge < ActiveRecord::Migration
  def self.up
    add_column :challenges, :featured, :boolean, :default=>false
  end

  def self.down
    remove_column :challenges, :featured
  end
end
