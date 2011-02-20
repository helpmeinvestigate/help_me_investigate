class Challenge < ActiveRecord::Base
  belongs_to :user
  belongs_to :investigation
  has_many :tasks
  has_many :users_to_notify, :source=>:user, :class_name=>'User', :through => :tasks, :conditions=>"tasks.receive_emails = true AND users.notify_comments = true"
  has_many :users, :through => :tasks
  acts_as_activity :user
  acts_as_commentable
  acts_as_moderatable
  acts_as_taggable
  acts_as_publishable :live, :draft, :moderate, :trash
  #acts_as_audited
  acts_as_xapian :texts => [:description]
  
  named_scope :recent, :order => 'challenges.published_at DESC'
  
  validates_presence_of :title
  validates_presence_of :investigation
  validates_presence_of :user
  
  after_create do |challenge|
    
    the_users = challenge.investigation.users - [challenge.user]
    the_users.each do |u|
      InvestigationNotifier.deliver_challenge_set_notification(u,challenge.investigation,challenge)
    end
  end
  
  def get_task_for_challenge(user)
    user.challenges.select {|t| t == self}.first
  end
  
  def undertaking_for(user)
    task = Task.find(:first, :conditions=>['challenge_id = ? AND user_id = ?', self.id, user.id])
    return task
  end
  
  def set_as_complete
    unless completed
      self.completed = 1
      if self.save
      
        self.investigation.users.each do |u| # change to self.users to just notify people in this challenge?
          #InvestigationNotifier.deliver_completed_notification(u,self)
        
          InvestigationNotifier.deliver_challenge_completed_notification(u,self.investigation,self)
        
        end
    
        return true
      else
        return false
      end
    end
  end
  
  def set_as_uncomplete
    if completed
      self.completed = 0
      if self.save
      
        self.investigation.users.each do |u| # change to self.users to just notify people in this challenge?
          #InvestigationNotifier.deliver_uncompleted_notification(u,self)
          InvestigationNotifier.deliver_challenge_uncompleted_notification(u,self.investigation,self)

        end
    
        return true
      else
        return false
      end
    end
  end
  
  def tasks_not_counting_creator
    return tasks - [self.task_by(user)]
  end
  
  def task_by(user)
    return Task.find(:first,:conditions=> ['user_id = ? AND challenge_id = ?', user.id, self.id])
  end
  
  def users_to_email(user)
    return users_to_notify - [user]
  end
  
  
  def owner
    self.user
  end
    
  def css_classes(user)
    classes = []
    #classes << published_as
    #classes << "locked" if locked
    #classes << "open" unless locked
    #TODO 'lonely' - only one person accepted, etc.?
    unless user.blank?
      classes << "accepted" if task_by(user)
    end
    classes << "completed" if completed
    classes << "ongoing" unless completed
    classes
  end
end
