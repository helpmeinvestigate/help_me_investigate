class CreateChallenges < ActiveRecord::Migration
  def self.up
    create_table :challenges do |t|
      t.column :user_id, :integer
      t.column :investigation_id, :integer
      t.column :description, :string
      t.column :published_at, :datetime
      t.column :published_as, :string
      t.column :completed_when, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :challenges
  end
end
