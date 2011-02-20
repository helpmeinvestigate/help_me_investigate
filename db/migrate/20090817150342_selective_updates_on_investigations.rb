class SelectiveUpdatesOnInvestigations < ActiveRecord::Migration
  def self.up
    add_column :investigatings, :receive_emails, :boolean, :default=>true
    add_column :tasks, :receive_emails, :boolean, :default=>true
    
  end

  def self.down
    remove_column :investigatings, :receive_emails
    remove_column :tasks, :receive_emails
  end
end
