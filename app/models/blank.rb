class Blank < ActiveRecord::Base
  include Viewable
  
  acts_as_activity :user
  belongs_to :user
  belongs_to :investigation
  acts_as_commentable
  acts_as_publishable :live, :draft, :moderate, :trash
  #acts_as_audited
  #acts_as_paranoid
  acts_as_xapian :texts => [:consensus, :before_text, :after_text, :blank_type]
  

  def owner
    self.user
  end
end
