class <%= class_name %> < ActiveRecord::Migration
  def self.up
    change_column :simple_cms_items, :data, :text, :limit => 10000000
  end

  def self.down
    change_column :simple_cms_items, :data, :text
  end
end
