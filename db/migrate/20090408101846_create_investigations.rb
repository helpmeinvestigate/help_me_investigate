class CreateInvestigations < ActiveRecord::Migration
  def self.up
    create_table :investigations do |t|

      t.column :question, :string
      t.column :user_id, :integer
      t.column :description, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime

      t.timestamps
    end
  end

  def self.down
    drop_table :investigations
  end
end
