class AddBitlyInfoToComment < ActiveRecord::Migration
  def self.up
    add_column :comments, :link_title, :string
  end

  def self.down
    remove_column :comments, :link_title
  end
end
