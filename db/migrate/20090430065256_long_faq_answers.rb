class LongFaqAnswers < ActiveRecord::Migration
  def self.up
    change_column :faqs, :answer, :text
  end

  def self.down
    change_column :faqs, :answer, :string
  end
end
