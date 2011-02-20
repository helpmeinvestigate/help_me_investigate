class Investigating < ActiveRecord::Base
  belongs_to :user
  belongs_to :investigation, :counter_cache => true
  acts_as_activity :user
  
  
  #TODO make sure that you can't sign up multiple times for an investigation
  validates_uniqueness_of :user_id, :scope=>:investigation_id
end
