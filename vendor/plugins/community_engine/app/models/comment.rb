class Comment < ActiveRecord::Base
  acts_as_xapian :texts => [:comment]
  acts_as_publishable :live, :draft, :moderate, :trash
  
  belongs_to :commentable, :polymorphic => true
  belongs_to :user
  belongs_to :investigation
  belongs_to :recipient, :class_name => "User", :foreign_key => "recipient_id"
  
  validates_presence_of :comment
  # validates_presence_of :recipient
  
  validates_length_of :comment, :maximum => 20000, :message => "Updates must be less than 20000 characters long"
  
  before_save :whitelist_attributes 
  after_save :update_commentable
  #before_save :shorten_url #TODO this is killing comment posting
   
  validates_presence_of :user, :unless => Proc.new{|record| AppConfig.allow_anonymous_commenting }
  validates_presence_of :author_email, :unless => Proc.new{|record| record.user }  #require email unless logged in
  validates_presence_of :author_ip, :unless => Proc.new{|record| record.user} #log ip unless logged in
  validates_format_of :author_url, :with => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix, :unless => Proc.new{|record| record.user }

  acts_as_activity :user, :if => Proc.new{|record| record.user } #don't record an activity if there's no user

  # named_scopes
  named_scope :recent, :order => 'created_at DESC'

  def self.find_photo_comments_for(user)
    Comment.find(:all, :conditions => ["recipient_id = ? AND commentable_type = ?", user.id, 'Photo'], :order => 'created_at DESC')
  end
  
  # Helper class method to lookup all comments assigned
  # to all commentable types for a given user.
  def self.find_comments_by_user(user, *args)
    options = args.extract_options!
    find(:all,
      :conditions => ["user_id = ?", user.id],
      :order => "created_at DESC",
      :limit => options[:limit]  
    )
  end
    
  def previous_commenters_to_notify
    # only send a notification on recent comments
    # limit the number of emails we'll send (or posting will be slooowww)
    #TODO add these messages to an email queue
    User.find(:all, 
      :conditions => ["users.id NOT IN (?) AND users.notify_comments = ? 
                      AND commentable_id = ? AND commentable_type = ? 
                      AND comments.created_at > ?", [user_id, recipient_id.to_i], true, commentable_id, commentable_type, 2.weeks.ago], 
#      :include => :comments_as_author, :group => "users.id", :limit => 20)    
      :include => :comments_as_author, :limit => 20)
  end    
    
  def commentable_name
    type = self.commentable_type.underscore
    case type
      when 'user'
        commentable.login
      when 'post'
        commentable.title
      when 'clipping'
        commentable.description || "Clipping from #{commentable.user.login}"
      when 'photo'
        commentable.description || "Photo from #{commentable.user.login}"
      when 'blank'
        commentable.blank_type
      when 'investigation'
        commentable.question
      else 
        commentable.class.to_s.humanize
    end
  end

#  def investigation
#    return super unless super.blank?
#    
#    type = self.commentable_type.underscore
#    case type
#      when 'investigation'
#        commentable
#      when 'blank'
#        commentable.investigation #.find(:first)
#      when 'challenge'
#        commentable.investigation #.find(:first)
#    end
#  
#  end

  def title_for_rss
    "Comment from #{username}"
  end
  
  def username
    user ? user.login : (author_name.blank? ? 'Anonymous' : author_name)
  end
  
  def self.find_recent(options = {:limit => 5})
    find(:all, :conditions => "created_at > '#{14.days.ago.to_s :db}'", :order => "created_at DESC", :limit => options[:limit])
  end
  
  def can_be_deleted_by(person)
    person && (person.admin? || person.id.eql?(user_id) || person.id.eql?(recipient_id) )
  end
  
  def should_notify_recipient?
    return unless recipient
    return false if recipient.eql?(user)
    return false unless recipient.notify_comments?
    true    
  end
  
  def notify_previous_commenters
    previous_commenters_to_notify.each do |commenter|
      UserNotifier.deliver_follow_up_comment_notice(commenter, self)
    end    
  end
  
  def notify_previous_anonymous_commenters
    anonymous_commenters_emails = commentable.comments.map{|c|  c.author_email if ( !c.user && !c.author_email.eql?(self.author_email) && c.author_email) }.uniq.compact
    anonymous_commenters_emails.each do |email|
      UserNotifier.deliver_follow_up_comment_notice_anonymous(email, self)
    end    
  end  
  
  def send_notifications

    if self.commentable_type == "Challenge"
      self.notify_challengees
    else
      UserNotifier.deliver_comment_notice(self) if should_notify_recipient?
      self.notify_previous_commenters  
      self.notify_previous_anonymous_commenters if AppConfig.allow_anonymous_commenting
    end
  end
  
  def notify_challengees
    challengee_emails = commentable.users_to_email(self.user).map{|u|  u.email }.uniq.compact
    challengee_emails.each do |email|
      UserNotifier.deliver_follow_up_comment_investigator(email, self)
    end
  end
  
  def notify_investigators
    investigators_emails = commentable.investigation.users.map{|u|  u.email }.uniq.compact
    investigators_emails.each do |email|
      UserNotifier.deliver_follow_up_comment_investigator(email, self)
    end
  end
  
  def short_link_thumb
    
    "http://s.bit.ly/bitly/" + bitly_hash + "/thumbnail_small.png"
  end  
  
  

  
  def shorten_url
    
    #debugger
    
    if self.link == 'http://' || self.link == ''
      self.link = ''
      return
    end
    
    self.shorten_attempts = self.shorten_attempts + 1

    unless shorten_attempts > 5
      
      begin
        #if short_link.blank?
          mylink = self.link
    
          unless mylink.blank?
            #result = ActiveSupport::JSON.decode( open('http://api.bit.ly/shorten?version=2.0.1&login=hmi&apiKey=R_382280666140fcae6965b0b4a6017546&longUrl=' + CGI.escape(mylink), "UserAgent" => "HelpMeInvestigate").read)
            #debugger
            
            shorten_request = 'http://api.bit.ly/shorten?version=2.0.1&login=hmi&keyword=hmic' + self.id.to_s + '&apiKey=R_382280666140fcae6965b0b4a6017546&longUrl=' + CGI::escape(mylink) + '&history=1'
            result = ActiveSupport::JSON.decode( open(shorten_request, "UserAgent" => "HelpMeInvestigate").read)
        
            #debugger
            
            unless result.blank?
              if result["errorCode"] == 0
                self.short_link = result["results"][mylink]["shortUrl"]
                self.bitly_user_hash = result["results"][mylink]["hash"]
              
                #debugger
              
                resultb = ActiveSupport::JSON.decode( open('http://api.bit.ly/info?version=2.0.1&login=hmi&apiKey=R_382280666140fcae6965b0b4a6017546&hash=' + bitly_user_hash, "UserAgent" => "HelpMeInvestigate").read)
              
                #debugger
              
                unless resultb.blank?
                  if resultb["errorCode"] == 0
                    self.bitly_hash = resultb["results"][bitly_user_hash]["hash"]
                    self.link_title = resultb["results"][bitly_user_hash]["htmlTitle"]
                  end
                end
              
              
              end
            end
          end
        #end
      rescue
      end
      
      self.save!
    end
  end
  

  
  protected
  def whitelist_attributes
    self.comment = white_list(self.comment)
  end
  
  def update_commentable
    
    type = commentable_type.underscore
    case type
      when 'blank'
        the_commentable = Blank.find(commentable_id)
        the_commentable.update_attribute(:consensus, answer)
      when 'challenge'
        the_commentable = Challenge.find(commentable_id)
        the_commentable.update_attribute(:updated_at, Time.now)
    end
  end
  
end
