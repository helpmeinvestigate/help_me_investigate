class BulkMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :bulk, :boolean, :default => false
  end

  def self.down
    remove_column :messages, :bulk
  end
end
