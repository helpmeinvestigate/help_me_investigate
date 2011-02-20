class NotNullBooleanChallenge < ActiveRecord::Migration
  def self.up
    change_column_default :challenges, :completed, 0
    change_column_null :challenges, :completed, false
  end

  def self.down
    change_column_default :challenges, :completed, nil
    change_column_null :challenges, :completed, true
  end
end
