class ModerationRequest < ActiveRecord::Migration
  def self.up
    create_table :moderation_requests do |t|
      t.column :user_id, :integer
      t.column :reason, :text
      t.column :moderatable_id, :integer
      t.column :moderatable_type, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :moderation_requests
  end
end
