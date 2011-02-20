class Solution < ActiveRecord::Base
  belongs_to :user
  belongs_to :investigation
  acts_as_publishable :live, :draft, :moderate, :trash
  acts_as_activity :user
  acts_as_xapian :texts => [:title, :description]
  
end
