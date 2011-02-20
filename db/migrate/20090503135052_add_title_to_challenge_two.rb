class AddTitleToChallengeTwo < ActiveRecord::Migration
  def self.up
    add_column :challenges, :title, :string
  end

  def self.down
    remove_column :challenges, :title
  end
end
