class CreateFaqs < ActiveRecord::Migration
  def self.up
    create_table :faqs do |t|
      t.column :question, :string
      t.column :answer, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :faqs
  end
end
