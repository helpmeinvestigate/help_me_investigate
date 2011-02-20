require "shorturl"

class Investigation < ActiveRecord::Base
  include Viewable

  acts_as_xapian :texts => [:question, :description]
  #acts_as_mappable
  acts_as_taggable
  acts_as_moderatable
  has_many :comments
  acts_as_activity :user, :if => Proc.new{|r| r.is_live?}
  acts_as_publishable :live, :draft, :moderate, :trash
  belongs_to :user
  has_many :blanks, :dependent => :destroy
  has_many :favorites, :as => :favoritable, :dependent => :destroy

  has_many :investigatings, :include => :user, :dependent => :destroy
  has_many :users, :as => :investigators, :through => :investigatings, :include => :tags
  has_many :challenges
  has_many :activities
  has_many :invitations
  has_many :solutions
  
  
  validates_presence_of :question
  validates_length_of :question, :minimum => 5
  validates_length_of :question, :maximum => 255
  
  validates_presence_of :user
  validates_presence_of :published_at, :if => Proc.new{|r| r.is_live? }

  before_save :transform_investigation
  after_create :insert_investigating
  before_validation :set_published_at
  #before_save :shorten_url
  
  after_save do |investigation|
    activity = Activity.find_by_item_type_and_item_id('Investigation', investigation.id)
    if investigation.is_live? && !activity
      investigation.create_activity_from_self 
      InvestigationNotifier.deliver_approval_notification(investigation)
    elsif investigation.is_draft? && activity
      activity.destroy
    end
    
  end
   
  after_create do |investigation| 
    
    InvestigationNotifier.deliver_moderation_notification(investigation) 
    challenge = Challenge.new({:user => investigation.user, :investigation => investigation, :title=>'Add background information', :published_at=>Time.now, :published_as=>'live',:description=>'Find anything related to this investigation elsewhere on the web and add links to it here.'})
    challenge.save
  end
  
  #Named scopes
  named_scope :by_featured_writers, :conditions => ["users.featured_writer = ?", true], :include => :user
  named_scope :recent, :order => 'investigations.published_at DESC'
  named_scope :feature, :conditions => ["featured = ?", true], :order => 'investigations.published_at DESC'
  named_scope :popular, :order => 'investigations.investigatings_count DESC'
  named_scope :since, lambda { |days|
    {:conditions => "investigations.published_at > '#{days.ago.to_s :db}'" }
  }
  named_scope :tagged_with, lambda {|tag_name|
    {:conditions => ["tags.name = ?", tag_name], :include => :tags}
  }
  
  def set_as_complete
    self.completed = 1
    if self.save
      
      self.users.each do |u|
        InvestigationNotifier.deliver_completed_notification(u,self)
      end
    
      return true
    else
      return false
    end
  end
  
  def set_as_uncomplete
    self.completed = 0
    if self.save
      
      self.users.each do |u|
        InvestigationNotifier.deliver_uncompleted_notification(u,self)
      end
    
      return true
    else
      return false
    end
  end
  
  def self.find_related_to(investigation, options = {})
    merged_options = options.merge({:limit => 8, 
        :order => 'published_at DESC', 
        :conditions => [ 'investigations.id != ? AND published_as = ?', investigation.id, 'live' ]
    })

    find_tagged_with(investigation.tag_list, merged_options).uniq
  end
  
  def self.find_recommended_for(user, options = {})
    
    
    investigation_ids = Investigating.find(:all, :conditions=>['user_id = ?', user.id]).collect {|x| x[:investigation_id] }
    
    investigation_ids = investigation_ids + Investigation.find(:all, :conditions=>['user_id = ?', user.id]).collect {|x| x[:id] }
    
    investigation_ids.uniq!
    
    merged_options = options.merge({:limit => 8, 
        :order => 'investigations.published_at DESC', 
        #:conditions => [ 'investigations.id != ? AND published_as = ?', investigation.id, 'live' ]
        
        :conditions=>['investigations.id NOT IN (?) AND investigations.published_as = ?', investigation_ids, 'live'] #.find(:all)
    })
    
    find_tagged_with(user.tag_list, merged_options).uniq
  end

  def to_param
    id.to_s << "-" << (question ? question.parameterize : '' )
  end

  def self.find_recent(options = {:limit => 5})
    self.recent.find :all, :limit => options[:limit]
  end
  
  def self.find_popular(options = {} )
    options.reverse_merge! :limit => 5, :since => 7.days
    
    self.popular.since(options[:since]).find :all, :limit => options[:limit]
  end

  def self.find_featured(options = {:limit => 10})
    self.recent.by_featured_writers.find(:all, :limit => options[:limit] )    
  end
  
  def self.find_investigations_by_user(user)
    self.recent.find(:all, :conditions=>['user_id = ?', user.id])    
  end

  def display_title
    t = self.title
    if self.category
      t = self.category.name.upcase << ": " << t
    end
    t
  end
  
  def previous_investigation
    self.user.investigations.find(:first, :conditions => ['published_at < ? and published_as = ?', published_at, 'live'], :order => 'published_at DESC')
  end
  def next_investigation
    self.user.investigations.find(:first, :conditions => ['published_at > ? and published_as = ?', published_at, 'live'], :order => 'published_at ASC')
  end 
  
  ## transform the text and title into valid html
  def transform_investigation
   self.question  = white_list(self.question)
   self.description = white_list(self.description)
  end
  
  def set_published_at
    if self.is_live? && !self.published_at
      self.published_at = Time.now
    end
  end
  
  def has_been_favorited_by(user = nil, remote_ip = nil)
    f = Favorite.find_by_user_or_ip_address(self, user, remote_ip)
    return f
  end  

  def published_at_display(format = 'published_date')
    is_live? ? I18n.l(published_at, :format => format) : 'Draft'
  end
  
  def investigating_by(user)
    return Investigating.find(:first,:conditions=> ['user_id = ? AND investigation_id = ?', user.id, self.id])
  end
  
  def investigators_not_counting_creator
    return investigatings - [self.investigating_by(user)]
  end
  
  def is_being_investigated_by(user)
    return users.include?(user) || self.user == user
  end  
  
  def insert_investigating
    owner.investigatings << Investigating.new({:investigation_id => self.id, :user_id => self.user_id})
  end
  
  def owner
    self.user
  end
  
  def investigator_tags
    inv_tags = []
    these_users = self.users.find(:all, :include=>:tags)
    these_users << self.user
    these_users.uniq!
    these_users.each do |inv|
      logger.info "User:" + inv.login
      User.find_by_id(inv.id, :include=>:tags).tags.each do |t|
        inv_tags << t
        logger.info "Tag:" + t.name
      end
    end
    inv_tags
  end
  
  def incomplete_challenges
    Challenge.find(:all, :conditions => ['(challenges.completed != 1) AND (investigation_id = ?) AND challenges.created_at = challenges.updated_at', id])
  end
  
  def updated_challenges
    Challenge.find(:all, :conditions => ['challenges.completed != 1 AND challenges.created_at <> challenges.updated_at AND (investigation_id = ?) ', id])
  end
  
  def completed_challenges
    Challenge.find(:all, :conditions => ['(challenges.completed = 1) AND (investigation_id = ?)', id])
  end
  

  
  def css_classes(user)
    classes = []
    classes << published_as
    classes << "locked" if locked
    classes << "open" unless locked
    classes << "completed" if completed
    classes << "ongoing" unless completed
    if user
      classes << "accepted" if is_being_investigated_by(user)
    end
    classes
  end
  
  def is_live?
    return true if published_as == "live"
  end
  
  def allows_contributions_from?(user)
    false
    unless user.blank?
      return true if user.admin?
      return false if locked
      
      is_being_investigated_by(user)
      
    end
  end
  
  def allows_viewing_by?(user)
    false
    unless user.blank?
      return true if user.admin?
      return true if completed
      
      is_being_investigated_by(user)
      
    end
  end
  
  def shorten_url
    begin
      if short_link.blank?
        mylink = 'http://helpmeinvestigate.com/investigations/' + self.to_param
    
        result = ActiveSupport::JSON.decode( open('http://api.bit.ly/shorten?version=2.0.1&login=hmi&keyword=hmi' + self.id.to_s + '&apiKey=R_382280666140fcae6965b0b4a6017546&longUrl=' + CGI::escape(mylink) + '&history=1', "UserAgent" => "HelpMeInvestigate").read)
        unless result.blank?
          if result["errorCode"] == 0
            self.short_link = result["results"][mylink]["shortUrl"]
          end
        end
      end
    rescue
      #There was a bitly error - not the end of the world. It will get set again if the user edits the investigation
  end
  end
  
  def self.popular_tags(limit = nil, order = ' tags.name ASC', type = 'Investigation')
    sql = "SELECT tags.id, tags.name, count(*) AS count 
      FROM taggings, tags 
      WHERE tags.id = taggings.tag_id "
    sql += " AND taggings.taggable_type = '#{type}'" unless type.nil?      
    sql += " GROUP BY tags.id, tags.name"
    sql += " ORDER BY #{order}"
    sql += " LIMIT #{limit}" if limit
    Tag.find_by_sql(sql).sort{ |a,b| a.name.downcase <=> b.name.downcase}
  end
end
