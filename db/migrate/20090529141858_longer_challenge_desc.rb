class LongerChallengeDesc < ActiveRecord::Migration
  def self.up
    change_column :challenges, :description, :text
  end

  def self.down
    change_column :challenges, :description, :string
  end
end
