class ShorturlForComment < ActiveRecord::Migration
  def self.up
    add_column :comments, :short_link, :string
  end

  def self.down
    remove_column :comments, :short_link
  end
end
