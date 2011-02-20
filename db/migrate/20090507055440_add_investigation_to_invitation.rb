class AddInvestigationToInvitation < ActiveRecord::Migration
  def self.up
    add_column :invitations, :investigation_id, :integer
  end

  def self.down
    remove_column :invitations, :investigation_id
  end
end
