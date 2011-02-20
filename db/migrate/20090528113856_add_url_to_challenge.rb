class AddUrlToChallenge < ActiveRecord::Migration
  def self.up
    add_column :challenges, :url, :string
    add_column :challenges, :url_description, :string
    change_column :investigations, :description, :text
  end

  def self.down
    remove_column :challenges, :url
    remove_column :challenges, :url_description
    change_column :investigations, :description, :string
  end
end
