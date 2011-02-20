class Consensus < ActiveRecord::Migration
  def self.up
    add_column :blanks, :consensus, :string
    
  end

  def self.down
    remove_column :blanks, :consensus
    
  end
end
