class EmailSettings < ActiveRecord::Migration
  def self.up
    add_column :users, :notify_investigations, :boolean, :default=>true
    add_column :users, :weekly_digest, :boolean, :default=>true
    add_column :users, :daily_digest, :boolean, :default=>true

    
  end

  def self.down
    remove_column :users, :notify_investigations
    remove_column :users, :weekly_digest
    remove_column :users, :daily_digest
  end
end
