class TaskCompletion < ActiveRecord::Migration
  def self.up
    #add_column :tasks, :completed, :boolean, :default=>false
  end

  def self.down
    #remove_column :tasks, :completed
  end
end
