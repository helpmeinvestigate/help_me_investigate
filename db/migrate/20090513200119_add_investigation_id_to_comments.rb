class AddInvestigationIdToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :investigation_id, :integer
  end

  def self.down
    remove_column :comments, :investigation_id
  end
end
