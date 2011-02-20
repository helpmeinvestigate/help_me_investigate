class ModerationRequest < ActiveRecord::Base
  belongs_to :user
  acts_as_activity :user
  acts_as_commentable  
end
