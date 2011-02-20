class TooltipTextTooShort < ActiveRecord::Migration
  def self.up
    remove_column :tooltips, :tip
    add_column :tooltips, :tip, :text
  end

  def self.down
    remove_column :tooltips, :tip
    add_column :tooltips, :tip, :string
  end
end
