class CreateTooltips < ActiveRecord::Migration
  def self.up
    create_table :tooltips do |t|
      t.column :tip, :string
      t.column :identifier, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :tooltips
  end
end
