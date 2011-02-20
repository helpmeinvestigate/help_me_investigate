class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.column :user_id, :integer
      t.column :challenge_id, :integer
      t.column :completed, :boolean
      t.timestamps
    end
  end

  def self.down
    drop_table :tasks
  end
end
