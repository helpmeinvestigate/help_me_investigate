class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :investigation
  belongs_to :item, :polymorphic => true
  validates_presence_of :user_id
  
  after_save :update_counter_on_user
  after_save :update_counter_on_investigation
  
  named_scope :of_item_type, lambda {|type|
    {:conditions => ["activities.item_type = ?", type]}
  }
  named_scope :since, lambda { |time|
    {:conditions => ["activities.created_at > ?", time] }
  }
  named_scope :before, lambda {|time|
    {:conditions => ["activities.created_at < ?", time] }    
  }
  named_scope :seven_days_ago, 
    {:conditions => ["activities.created_at > ? AND activities.created_at <= ?", 7.days.ago, 6.days.ago] }
  named_scope :six_days_ago, 
    {:conditions => ["activities.created_at > ? AND activities.created_at <= ?", 6.days.ago, 5.days.ago] }
  named_scope :five_days_ago, 
    {:conditions => ["activities.created_at > ? AND activities.created_at <= ?", 5.days.ago, 4.days.ago] }
  named_scope :four_days_ago, 
    {:conditions => ["activities.created_at > ? AND activities.created_at <= ?", 4.days.ago, 3.days.ago] }
  named_scope :three_days_ago, 
    {:conditions => ["activities.created_at > ? AND activities.created_at <= ?", 3.days.ago, 2.days.ago] }
  named_scope :two_days_ago, 
    {:conditions => ["activities.created_at > ? AND activities.created_at <= ?", 2.days.ago, 1.days.ago] }
  named_scope :one_day_ago, 
    {:conditions => ["activities.created_at > ? AND activities.created_at <= ?", 1.days.ago, 0.days.ago] }
  named_scope :today, 
    {:conditions => ["activities.created_at > ?", 0.days.ago] }

  named_scope :recent, :order => "activities.created_at DESC"
  named_scope :by_users, lambda {|user_ids|
    {:conditions => ['activities.user_id in (?)', user_ids]}
  }
  named_scope :on_investigations, lambda {|investigation_ids|
    {:conditions => ['activities.investigation_id in (?)', investigation_ids]}
  }  
  
  def update_counter_on_user
    if user && user.class.column_names.include?('activities_count')
      user.update_attribute(:activities_count, Activity.by(user) )
    end
  end
  
  def update_counter_on_investigation
  #  unless investigation.blank? # && investigation.class.column_names.include?('activities_count')
  #    unless investigation.id.blank?
        #investigation.update_attribute(:activities_count, Activity.on_investigation(investigation) )
  #    end
  #  end
  end
  
  def self.by(user)
    Activity.count(:all, :conditions => ["user_id = ?", user.id])
  end
    
  def self.on_investigation(investigation)
    Activity.count(:all, :conditions => ["investigation_id = ?", investigation.id])
  end  
    
end
