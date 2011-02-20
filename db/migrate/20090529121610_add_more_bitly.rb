class AddMoreBitly < ActiveRecord::Migration
  def self.up
    add_column :comments, :bitly_user_hash, :string
  end

  def self.down
    remove_column :comments, :bitly_user_hash
  end
end
