class CreateSolutions < ActiveRecord::Migration
  def self.up
    create_table :solutions do |t|
      t.column :user_id, :integer
      t.column :title, :string
      t.column :description, :text
      t.column :investigation_id, :integer
      t.column :published_as, :string, :limit=>16, :default=>"live"
      t.column :published_at, :datetime
      t.timestamps
    end
  end

  def self.down
    drop_table :solutions
  end
end
