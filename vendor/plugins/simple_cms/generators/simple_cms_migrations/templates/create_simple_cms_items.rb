class <%= class_name %> < ActiveRecord::Migration
  def self.up
    create_table :simple_cms_items do |t|
			t.column :params,     :string
			t.column :data,       :text
			t.column :position,   :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :created_by, :string
      t.column :updated_by, :string
    end
    SimpleCmsItem.create_versioned_table
  end

  def self.down
    SimpleCmsItem.drop_versioned_table
    drop_table :simple_cms_items
  end
end
