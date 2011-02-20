class AddExtrasToInvestigations < ActiveRecord::Migration
  def self.up
    
    
    add_column :investigations, :category_id, :integer
    add_column :investigations, :view_count, :integer, :default => 0
    add_column :investigations, :favorited_count, :integer, :default => 0
    add_column :investigations, :published_as, :string, :limit=>16, :default=>"draft"
    add_column :investigations, :published_at, :datetime

    add_index "investigations", ["published_as"], :name => "index_investigations_on_published_as"
    add_index "investigations", ["published_at"], :name => "index_investigations_on_published_at"
    add_index "investigations", ["user_id"], :name => "index_investigations_on_user_id"
    
  end

  def self.down
    
    remove_column :investigations, :category_id
    remove_column :investigations, :view_count
    remove_column :investigations, :favorited_count
    remove_column :investigations, :published_as
    remove_column :investigations, :published_at
    
    remove_index "investigations", ["published_as"]
    remove_index "investigations", ["published_at"]
    remove_index "investigations", ["user_id"]
  end
end
