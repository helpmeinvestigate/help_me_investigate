class AddInvestigatingsCount < ActiveRecord::Migration
  def self.up
    add_column :investigations, :investigatings_count, :integer
  end

  def self.down
    remove_column :investigations, :investigatings_count
  end
end
