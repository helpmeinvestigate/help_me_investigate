class CommentAnswer < ActiveRecord::Migration
  def self.up
    add_column :comments, :answer, :string
    add_column :comments, :published_as, :string, :default => "live"
    add_column :comments, :published_at, :datetime
  end

  def self.down
    remove_column :comments, :answer
    remove_column :comments, :published_as
    remove_column :comments, :published_at
    
  end
end
