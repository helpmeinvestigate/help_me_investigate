class ExtraUserInfo < ActiveRecord::Migration
  def self.up
    add_column :users, :website, :string
    add_column :users, :blog, :string
    add_column :users, :twitter_username, :string
    
  end

  def self.down
    remove_column :users, :website
    remove_column :users, :blog
    remove_column :users, :twitter_username
  end
end
