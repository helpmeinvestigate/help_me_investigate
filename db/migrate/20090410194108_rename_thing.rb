class RenameThing < ActiveRecord::Migration
  def self.up
    rename_column :blanks, :type, :blank_type
  end

  def self.down
    rename_column :blanks, :blank_type, :type
  end
end
