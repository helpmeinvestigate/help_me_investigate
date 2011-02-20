# ActsAsModeratable
# Based on Juxie's Acts As Commentable
module HMI
  module Acts #:nodoc:
    module Moderatable #:nodoc:

      def self.included(base)
        base.extend ClassMethods  
      end

      module ClassMethods
        def acts_as_moderatable
          has_many :modration_requests, :as => :moderatable, :dependent => :destroy
          has_one :moderation_request, :as => :moderatable, :dependent => :destroy, :order => "created_at desc"
          include HMI::Acts::Moderatable::InstanceMethods
          extend HMI::Acts::Moderatable::SingletonMethods
        end
      end
      
      # This module contains class methods
      module SingletonMethods
        # Helper method to lookup for moderation_requests for a given object.
        # This method is equivalent to obj.moderation_requests.
        def find_moderation_requests_for(obj)
          moderatable = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
         
          ModerationRequest.find(:all,
            :conditions => ["moderatable_id = ? and moderatable_type = ?", obj.id, moderatable],
            :order => "created_at DESC"
          )
        end
        
        # Helper class method to lookup moderation_requests for
        # the mixin moderatable type written by a given user.  
        # This method is NOT equivalent to ModerationRequest.find_moderation_requests_for_user
        def find_moderation_requests_by_user(user) 
          moderatable = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
          
          ModerationRequest.find(:all,
            :conditions => ["user_id = ? and moderatable_type = ?", user.id, moderatable],
            :order => "created_at DESC"
          )
        end
      end
      
      # This module contains instance methods
      module InstanceMethods
        # Helper method to sort moderation requests by date
        def moderation_requests_ordered_by_submitted
          ModerationRequest.find(:all,
            :conditions => ["moderatable_id = ? and moderatable_type = ?", id, self.type.name],
            :order => "created_at DESC"
          )
        end
        
        # Helper method that defaults the submitted time.
        def add_moderation_request(moderation_request)
          moderation_requests << moderation_request
        end
      end
      
    end
  end
end
