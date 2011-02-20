class AddLinkToComment < ActiveRecord::Migration
  def self.up
    add_column :comments, :link, :string
  end

  def self.down
    remove_column :comments, :link
  end
end
