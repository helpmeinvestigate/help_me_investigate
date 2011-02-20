module Acts
  module As
    module Publishable

      def self.included(base)
        base.extend(ClassMethods)
        
        # All ActiveRecords will now respond to publishable? with false
        def publishable?; false; end
      end

      module ClassMethods
        def acts_as_publishable(*args)
          unless args.include?(:draft) && args.include?(:live)
            raise "you must specify :draft and :live in list of publish_states for acts_as_publishable"
          end

          cattr_accessor :publish_states
          self.publish_states = args.collect{|state| state.to_s.downcase.to_sym }
          include InstanceMethods
          
          named_scope :live, :conditions => self.table_name.to_s + ".published_as = 'live'"
          named_scope :draft, :conditions => self.table_name.to_s + ".published_as = 'draft'"
          named_scope :moderate, :conditions => self.table_name.to_s + ".published_as = 'moderate'"
          named_scope :trash, :conditions => self.table_name.to_s + ".published_as = 'trash'"
          named_scope :awaiting, :conditions => self.table_name.to_s + ".published_as = 'draft' or " + self.table_name.to_s + ".published_as = 'moderate'"


          class << self
            alias_method_chain :find, :published_as
          end

          # create methods for each publish state
          self.publish_states.each do |status|

            define_method("is_#{status}?") do
              self.published_as == status.to_s
            end

            define_method("save_as_#{status}") do
              self.published_as = status.to_s
              save
            end

          end
        end

        def find_with_published_as(*args)
          # hacked to filter out unpublished items by default, when using find(:all)
          # to really find all items, use Class.find_without_published_as
          state = args.first
          state = state.eql?(:all) ? :live : state
          
          if self.publish_states.include?(state)
            args.shift
            # find_all_by_published_as(state.to_s.downcase, *args)
            # again, hacked

            with_scope(:find => {:conditions => [self.table_name.to_s + ".published_as = ?", state.to_s.downcase] }) do
              find_without_published_as(:all, *args)
            end            
          else
            find_without_published_as(*args)
          end  
        end

      end

      module InstanceMethods

        # All ActiveRecords using this plugin will now respond to publishable? with true
        def publishable?; true; end

        def publish(should_raise = false)
          if defined?(:save_as_live)
            save_as_live 
          else
            raise "Add 'live' to list of acts_as_published for publish method" if should_raise
          end
        end

      end
    end
  end
end
