# Include hook code here
require 'acts_as_moderatable'
ActiveRecord::Base.send(:include, HMI::Acts::Moderatable)
