class CreateBlanks < ActiveRecord::Migration
  def self.up
    create_table :blanks do |t|
      t.column :user_id, :integer
      t.column :investigation_id, :integer
      t.column :type, :string, :limit=>16, :default=>"thing"
      t.column :view_count, :integer, :default => 0
      t.column :favorited_count, :integer, :default => 0
      t.column :published_as, :string, :limit=>16, :default=>"draft"
      t.column :published_at, :datetime
      t.timestamps
    end
  end

  def self.down
    drop_table :blanks
  end
end
