class InvestigationActivity < ActiveRecord::Migration
  def self.up
    add_column :activities, :investigation_id, :integer
  end

  def self.down
    remove_column :activities, :investigation_id
  end
end
