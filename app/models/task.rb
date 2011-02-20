class Task < ActiveRecord::Base
  belongs_to :user
  belongs_to :challenge
  acts_as_activity :user
  
  validates_uniqueness_of :user_id, :scope => [:challenge_id], :allow_nil => true, :message => 'is already doing this.'

  after_create :notify_accepted
  
  before_update :notify_completed
  
  def notify_accepted
    #challenge.investigation.users.each do |user|
      #InvestigationNotifier.deliver_challenge_accepted_notification(self.user,self.challenge.investigation,self.challenge)
    #end
    
  end
  
  def notify_completed
    
      if completed
        challenge.set_as_complete
      end
    #unless completed
      #debugger
      
      #resource.challenge.update_attribute(:completed, true) unless resource.challenge.blank?
    
     # challenge.investigation.users.each do |user|
     #   InvestigationNotifier.deliver_challenge_completed_notification(user,challenge.investigation,challenge)
     # end
    
    #end
    
  end

end
