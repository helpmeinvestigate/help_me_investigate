class ShorturlForInvestigation < ActiveRecord::Migration
  def self.up
    add_column :investigations, :short_link, :string
  end

  def self.down
    remove_column :investigations, :short_link
  end
end
