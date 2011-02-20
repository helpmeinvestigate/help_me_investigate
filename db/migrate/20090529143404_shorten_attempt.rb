class ShortenAttempt < ActiveRecord::Migration
  def self.up
    add_column :comments, :shorten_attempts, :integer, :default=>0
  end

  def self.down
    remove_column :comments, :shorten_attempts
  end
end
