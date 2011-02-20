class CreateInvestigatings < ActiveRecord::Migration
  def self.up
    create_table :investigatings do |t|
      t.column :user_id, :integer
      t.column :investigation_id, :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :investigatings
  end
end
