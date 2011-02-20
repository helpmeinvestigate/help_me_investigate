class AddTitleToChallenge < ActiveRecord::Migration
  def self.up
    add_column :investigations, :title, :string
  end

  def self.down
    remove_column :investigations, :title
  end
end
