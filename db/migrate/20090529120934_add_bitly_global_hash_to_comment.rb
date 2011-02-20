class AddBitlyGlobalHashToComment < ActiveRecord::Migration
  def self.up
    add_column :comments, :bitly_hash, :string
  end

  def self.down
    remove_column :comments, :bitly_hash
  end
end
