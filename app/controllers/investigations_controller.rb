require 'sparklines'


class InvestigationsController < BaseController
  
  include Viewable
  
  session :off, :only => :spark
  
  resources_controller_for :investigations, :load_enclosing => false
  before_filter :login_required, :except => [:index, :show, :recent, :featured, :popular, :all, :completed, :spark]
  skip_before_filter :beta_login_required, :only => [:index, :show, :recent, :featured, :popular, :all, :completed, :spark]
  
  
  cache_sweeper :investigation_sweeper, :only => [:create, :update, :destroy]
  cache_sweeper :taggable_sweeper, :only => [:create, :update, :destroy]    
  #caches_action :show, :if => Proc.new{|c| c.cache_action? }
  
  #before_filter :find_user, :only => [:new, :edit, :index, :show, :update_views, :manage]
  before_filter :require_ownership_or_moderator, :except => [:new, :create, :show, :index, :recent, :featured, :popular, :all, :completed, :spark]
  after_filter :retag, :only => [:update]
  
  def manage
    @investigations = @user.investigations.find_without_published_as(:all, 
      :page => {:current => params[:page], :size => 10}, 
      :order => 'created_at DESC')
  end
  
  def cache_action?
    !logged_in? && controller_name.eql?('investigations')
  end
  
  def update_views
    @investigation = Investigation.find(params[:id])
    updated = update_view_count(@investigation)
    render :text => updated ? 'updated' : 'duplicate'
  end
  
  def create
      self.resource = new_resource
      resource.user = current_user
      self.resource.tag_list = params[:tag_list] || ''
      if save_resource
        redirect_to investigation_path(resource)
      else
        render :action => "new"
      end
  end 
  
  def index

    if params[:user_id]
      @user = User.find_by_login(params[:user_id])
      @investigatings = Investigating.find(:all, :conditions => ["user_id = ?", @user.id])
                  
      @investigations = @investigatings.collect{|i| i.investigation}
      
      @rss_title = "#{AppConfig.community_name}: #{@user.login}'s Investigations"
      @rss_url = formatted_user_investigations_path(@user,:rss)
      @rss_source_url = user_investigations_path(@user)
      
    else
      
      @investigations = Investigation.recent.find :all, :page => {:size => 10, :current => params[:page]}, :include => :investigatings
      @popular = Investigation.popular.find :all, :page => {:size => 10, :current => params[:page]}, :include => :investigatings
      @featured = Investigation.feature.find :all, :page => {:size => 2, :current => params[:page]}, :include => :investigatings
      @tags = popular_tags(100, ' count DESC')
    
      @recent_activity = current_user.recent_investigation_activity(:size => 15, :current => 1) if logged_in?
      #@active_users = User.find_by_activity({:since => 1.month.ago})
      @active_users = User.find_by_sql(['SELECT activities.user_id, users.*, count(*) as count FROM `activities` LEFT JOIN users ON users.id = activities.user_id WHERE ( users.role_id <> 1) AND (activities.created_at > ?) GROUP BY activities.user_id ORDER BY count DESC LIMIT 10', 1.month.ago])
       
      @rss_title = "#{AppConfig.community_name}: Investigations"
      @rss_url = formatted_investigations_path(:rss)
      @rss_source_url = investigations_path
        
    end
    respond_to do |format|
      format.html do
        if params[:user_id]
          render :template=>"investigations/mine"
        else
          render
        end
      end # index.rhtml
      format.xml do
        render :xml => @investigations
      end
      format.rss {
        render_rss_feed_for(@investigations,
           { :feed => {:title => @rss_title, :link => @rss_source_url },
             :item => {:title => :question,
                       :description => :description,
                       :link => Proc.new {|investigation| investigation_url(investigation)},
                       :pub_date => :published_at} })
      }
    end
  end
  
  def recent

    @investigations = Investigation.find :all, :order=>'investigations.published_at desc', :page => {:size => 10, :current => params[:page]}
    
       
    @rss_title = "#{AppConfig.community_name}: Investigations"
    @rss_url = formatted_recent_investigations_path(:rss)
        
    respond_to do |format|
      format.html # index.rhtml
      format.xml do
        render :xml => @investigations
      end
      format.rss {
        render_rss_feed_for(@investigations,
           { :feed => {:title => @rss_title, :link => url_for(:controller => 'investigations', :action => 'index') },
             :item => {:title => :question,
                       :description => :description,
                       :link => Proc.new {|investigation| investigation_url(investigation)},
                       :pub_date => :published_at} })
      }
    end
  end
  
  
  
  def completed

    @investigations = Investigation.find :all, :order=>'investigations.published_at desc', :conditions => 'completed = 1', :page => {:size => 10, :current => params[:page]}
    
       
    @rss_title = "#{AppConfig.community_name}: Completed Investigations"
    @rss_url = formatted_completed_investigations_path(:rss)
        
    respond_to do |format|
      format.html # index.rhtml
      format.xml do
        render :xml => @investigations
      end
      format.rss {
        render_rss_feed_for(@investigations,
           { :feed => {:title => @rss_title, :link => url_for(:controller => 'investigations', :action => 'index') },
             :item => {:title => :question,
                       :description => :description,
                       :link => Proc.new {|investigation| investigation_url(investigation)},
                       :pub_date => :published_at} })
      }
    end
  end
  
  
  def nearby

    @investigations = Investigation.find :all, :page => {:size => 10, :current => params[:page]}
    
       
    @rss_title = "#{AppConfig.community_name}: Nearby Investigations"
    @rss_url = formatted_investigations_path(:rss)
        
    respond_to do |format|
      format.html # index.rhtml
      format.xml do
        render :xml => @investigations
      end
      format.rss {
        render_rss_feed_for(@investigations,
           { :feed => {:title => @rss_title, :link => url_for(:controller => 'investigations', :action => 'index') },
             :item => {:title => :question,
                       :description => :description,
                       :link => Proc.new {|investigation| investigation_url(investigation)},
                       :pub_date => :published_at} })
      }
    end
  end
  
  def popular

    @investigations = Investigation.popular.find :all, :page => {:size => 10, :current => params[:page]}
    
       
    @rss_title = "#{AppConfig.community_name}: Popular Investigations"
    @rss_url = formatted_popular_investigations_path(:rss)
        
    respond_to do |format|
      format.html # index.rhtml
      format.xml do
        render :xml => @investigations
      end
      format.rss {
        render_rss_feed_for(@investigations,
           { :feed => {:title => @rss_title, :link => url_for(:controller => 'investigations', :action => 'index') },
             :item => {:title => :question,
                       :description => :description,
                       :link => Proc.new {|investigation| investigation_url(investigation)},
                       :pub_date => :published_at} })
      }
    end
  end

  def featured

    @investigations = Investigation.feature.find :all, :page => {:size => 10, :current => params[:page]}
    
       
    @rss_title = "#{AppConfig.community_name}: Featured Investigations"
    @rss_url = formatted_featured_investigations_path(:rss)
        
    respond_to do |format|
      format.html # index.rhtml
      format.xml do
        render :xml => @investigations
      end
      format.rss {
        render_rss_feed_for(@investigations,
           { :feed => {:title => @rss_title, :link => url_for(:controller => 'investigations', :action => 'index') },
             :item => {:title => :question,
                       :description => :description,
                       :link => Proc.new {|investigation| investigation_url(investigation)},
                       :pub_date => :published_at} })
      }
    end
  end
  

  def mine

    if @user == current_user
      @investigatings = Investigating.find(:all, :conditions => ["user_id = ?", current_user.id])
      
      @investigations = @investigatings.collect{|i| i.investigation}
      
      @investigations = Investigation.find_without_published_as(:all, :conditions => ["user_id = ?", current_user.id]) + @investigations
      
      @investigations.uniq!
      
      
    else
      
      @investigatings = Investigating.find(:all, :conditions => ["user_id = ?", current_user.id])
            
      #@investigations = Investigation.find_investigations_by_user(@user) + @investigatings.collect{|i| i.investigation}
      
      @investigations = @investigatings.collect{|i| i.investigation}
      
    end
    
    @investigations = @investigations.sort_by { |inv| inv.created_at }.reverse
    
        
    respond_to do |format|
      format.html # index.rhtml
      format.xml do
        render :xml => @investigations
      end
    end
  end

  def show
     
    
    
    begin
      @investigation = Investigation.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      render(:nothing => true, :status => 404) and return
    end
      
    
    @user = @investigation.user
    @is_current_user = @user.eql?(current_user)
    
    if current_user
      
      render :nothing => true, :status => 404 and return unless(@is_current_user or (@investigation.is_live? or current_user.admin?))
    else
      render :nothing => true, :status => 404 and return unless(@investigation.is_live?)
    end
    
    @previous = @investigation.previous_investigation
    @next = @investigation.next_investigation  
   # @popular_investigations = @user.investigations.find(:all, :limit => 10, :order => "view_count DESC")    
   #TODO - change this to actually popular
    @popular_investigations = Investigation.popular.find(:all, :limit => 10, :order => "view_count DESC")  
    @related = Investigation.find_related_to(@investigation)
    
    respond_to do |format|
      format.html
      format.xml do
      
       render :xml => @investigation 
      end
    end
  end

  def destroy
    self.resource = find_resource
    resource.destroy
    respond_to do |format|
      format.html do
        flash[:notice] = "You have deleted that investigation"
        redirect_to investigations_path
      end
      format.js
      format.xml  { head :ok }
    end
  end
  
  def moderate
    self.resource = find_resource
    resource.save_as_moderate
    respond_to do |format|
      format.html do
        flash[:notice] = "You have set this investigation as requiring moderation"
        redirect_to investigation_path(resource)
      end
      format.js
      format.xml  { head :ok }
    end
  end
  
  def trash
    self.resource = find_resource
    resource.save_as_trash
    respond_to do |format|
      format.html do
        flash[:notice] = "The investigation has been put in the trash"
        redirect_to investigation_path(resource)
      end
      format.js
      format.xml  { head :ok }
    end
  end
  
  def publish
    self.resource = find_resource
    resource.save_as_live
    respond_to do |format|
      format.html do
        flash[:notice] = "The investigation has been published"
        redirect_to investigation_path(resource)
      end
      format.js
      format.xml  { head :ok }
    end
  end
  
  def lock
    self.resource = find_resource
    resource.locked = true
    resource.save
    respond_to do |format|
      format.html do
        flash[:notice] = "The investigation has been locked"
        redirect_to investigation_path(resource)
      end
      format.js
      format.xml  { head :ok }
    end
  end
  
  def unlock
    self.resource = find_resource
    resource.locked = false
    resource.save
    respond_to do |format|
      format.html do
        flash[:notice] = "The investigation has been unlocked"
        redirect_to investigation_path(resource)
      end
      format.js
      format.xml  { head :ok }
    end
  end
  
  def feature
    self.resource = find_resource
    resource.featured = true
    resource.save
    respond_to do |format|
      format.html do
        flash[:notice] = "The investigation has been featured"
        redirect_to investigation_path(resource)
      end
      format.js
      format.xml  { head :ok }
    end
  end
  
  def unfeature
    self.resource = find_resource
    resource.featured = false
    resource.save
    respond_to do |format|
      format.html do
        flash[:notice] = "The investigation has been unfeatured"
        redirect_to investigation_path(resource)
      end
      format.js
      format.xml  { head :ok }
    end
  end
  
  def complete
    self.resource = find_resource
    resource.set_as_complete

    respond_to do |format|
      format.html do
        

        flash[:notice] = "Well done! The investigation has been marked as complete and a notification sent to all the investigators"
        redirect_to investigation_path(resource)
      end
      format.js
      format.xml  { head :ok }
    end
  end
  
  def uncomplete
    self.resource = find_resource
    resource.set_as_uncomplete
    respond_to do |format|
      format.html do
        flash[:notice] = "The investigation has been marked as in progress"
        redirect_to investigation_path(resource)
      end
      format.js
      format.xml  { head :ok }
    end
  end
  
  
  # Renders a sparkline of activity of the last 7 days
  def spark
    @investigation = Investigation.find(params[:id])
    @data = []
    @data << resource.activities.seven_days_ago.count
    @data << resource.activities.six_days_ago.count
    @data << resource.activities.five_days_ago.count
    @data << resource.activities.four_days_ago.count
    @data << resource.activities.three_days_ago.count
    @data << resource.activities.two_days_ago.count
    @data << resource.activities.one_day_ago.count
    #@data << Activity.today.count(:conditions=>['investigation_id = ?', id])
    
    #render :partial=>'spark', :locals=>{:data => @data}
    
    session[:return_to] = '/investigations/' +@investigation.to_param.to_s
    
    #debugger
    send_data(Sparklines.plot(
                    @data,
                    :type => 'smooth',
                    :height=>20,
                    :line_color=>'lightgrey',
                    :underneath_color  => 'lightgrey',
                    :min => 0,
                    :dot_values => true,
                    :step => 10                    
                    
                  ), 
                  :disposition => 'inline', 
                  :type => 'image/png', 
                  :filename => Date.today.to_s + "-investigation-" + @investigation.object_id.to_s + "-sparkline.png")
                  
    
    
  end
  
  private
  
  def require_ownership_or_moderator
    @user = current_user
    unless admin? || moderator? || (@user && (@user.eql?(current_user)))
      redirect_to :controller => 'sessions', :action => 'new' and return false
    end
    return @user
  end
  
  def retag
    if params[:tag_list]
      @investigation.tag_list = params[:tag_list]
      @investigation.save
    end
  end
  
end
