class AddBeforeAndAfterBlankText < ActiveRecord::Migration
  def self.up
    add_column :blanks, :before_text, :string
    add_column :blanks, :after_text, :string
    
  end

  def self.down
    remove_column :blanks, :before_text
    remove_column :blanks, :after_text
  end
end
