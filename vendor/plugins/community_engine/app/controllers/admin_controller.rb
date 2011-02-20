class AdminController < BaseController
  before_filter :admin_required
  
  def contests
    @contests = Contest.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @contests.to_xml }
    end    
  end
  
  def index
    @approve_investigations_count = Investigation.count(:conditions=>"published_as = 'draft'")
    @moderate_investigations_count = Investigation.count(:conditions=>"published_as = 'moderate'")
    @moderate_blanks_count =Blank.count(:conditions=>"published_as = 'moderate'")
    @moderate_comments_count =Comment.count(:conditions=>"published_as = 'moderate'")
    @moderate_challenges_count =Challenge.count(:conditions=>"published_as = 'moderate'")
    @activities = User.recent_activity(:size => 10, :current => params[:page], :limit => 1000)
    @new_users = find_new_users(1.day.ago.midnight, Time.today.tomorrow.midnight)  
    
  end
  
  def activities
    @activities = User.recent_activity(:size => 30, :current => params[:page], :limit => 1000)
    
  end
  
  def messages
    @user = current_user
    @messages = Message.find(:all, :page => {:current => params[:page], :size => 50}, :order => 'created_at DESC')
  end
  
  def users
    cond = Caboose::EZ::Condition.new
    if params['login']    
      cond.login =~ "%#{params['login']}%"
    end
    if params['email']
      cond.email =~ "%#{params['email']}%"
    end        
    
    @users = User.recent.find(:all, :page => {:current => params[:page], :size => 100}, :conditions => cond.to_sql)      
  end
  
  def comments
    @comments = Comment.find_without_published_as(:all, :page => {:current => params[:page], :size => 100}, :order => 'created_at DESC', :conditions => "published_as = 'draft' or published_as = 'moderate'")
  end
  
  def investigations
      @investigations = Investigation.find_without_published_as(:all, :page => {:current => params[:page], :size => 100}, :order => 'created_at DESC', :conditions => "published_as = 'draft' or published_as = 'moderate'")
  end
  
  def challenges
      @challenges= Challenge.find_without_published_as(:all, :page => {:current => params[:page], :size => 100}, :order => 'created_at DESC', :conditions => "published_as = 'draft' or published_as = 'moderate'")
  end
  
  def blanks
      @blanks= Blank.find_without_published_as(:all, :page => {:current => params[:page], :size => 100}, :order => 'created_at DESC', :conditions => "published_as = 'draft' or published_as = 'moderate'")
  end
  
  def features
    
  end
  
  def activate_user
    user = User.find(params[:id])
    user.activate
    flash[:notice] = :the_user_was_activated.l
    redirect_to :action => :users
  end
  
  def deactivate_user
    user = User.find(params[:id])
    user.deactivate
    flash[:notice] = "The user was deactivated".l
    redirect_to :action => :users
  end  
  
  protected
  
  def find_new_users(from, to, limit= nil)
    new_user_cond = Caboose::EZ::Condition.new
    new_user_cond << ["activated_at IS NOT NULL"]
    new_user_cond.created_at >= from
    new_user_cond.created_at <= to    
    return User.find(:all, :conditions => new_user_cond.to_sql, :limit => limit)
  end
  
  
end