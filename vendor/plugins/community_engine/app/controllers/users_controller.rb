require "RMagick"

class UsersController < BaseController
  include Viewable
  cache_sweeper :taggable_sweeper, :only => [:activate, :update, :destroy]  

  
  if AppConfig.closed_beta_mode
    skip_before_filter :beta_login_required, :only => [:new, :create, :activate, :show, :signup_completed, :welcome_complete, :forgot_username, :forgot_password, :resend_activation]
    before_filter :require_invitation, :only => [:new, :create]
    
    def require_invitation
      redirect_to home_path and return false unless params[:inviter_id] && params[:inviter_code]
      redirect_to home_path and return false unless User.find_by_id(params[:inviter_id]).valid_invite_code?(params[:inviter_code])
    end
  end    

  uses_tiny_mce(:options => AppConfig.default_mce_options.merge({:editor_selector => "rich_text_editor"}), 
    :only => [:new, :create, :update, :edit, :welcome_about])
  uses_tiny_mce(:options => AppConfig.simple_mce_options, :only => [:show])

  # Filters
  before_filter :login_required, :only => [:edit, :edit_account, :update, :welcome_photo, :welcome_about, 
                                          :welcome_invite, :return_admin, :assume, :featured,
                                          :toggle_featured, :edit_pro_details, :update_pro_details, :dashboard, :deactivate, 
                                          :crop_profile_photo, :upload_profile_photo]
  before_filter :find_user, :only => [:edit, :edit_pro_details, :show, :update, :destroy, :statistics, :deactivate, 
                                      :crop_profile_photo, :upload_profile_photo ]
  before_filter :require_current_user, :only => [:edit, :update, :update_account,
                                                :edit_pro_details, :update_pro_details,
                                                :welcome_photo, :welcome_about, :welcome_invite, :deactivate, 
                                                :crop_profile_photo, :upload_profile_photo]
  before_filter :admin_required, :only => [:assume, :destroy, :featured, :toggle_featured, :toggle_moderator]
  before_filter :admin_or_current_user_required, :only => [:statistics]  

  def activate
    redirect_to signup_path and return if params[:id].blank?
    @user = User.find_by_activation_code(params[:id]) 
    if @user and @user.activate
      self.current_user = @user
      current_user.track_activity(:joined_the_site)      
      redirect_to welcome_photo_user_path(@user)
      flash[:notice] = :thanks_for_activating_your_account.l 
      return
    end
    flash[:error] = :account_activation_error.l_with_args(:email => AppConfig.support_email) 
    redirect_to signup_path     
  end
  
  def deactivate
    @user.deactivate
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = :deactivate_completed.l
    redirect_to login_path
  end

  def index
    cond, @search = User.paginated_users_conditions_with_search(params)    
    
    @users = User.recent.find(:all,
      :conditions => cond.to_sql, 
      :include => [:tags], 
      :page => {:current => params[:page], :size => 20}
      )
    
    @tags = User.tag_counts :limit => 10
    
  end
  
  def dashboard
    @user = current_user
    @recommended_investigations = @user.recommended_investigations
    @recent_activity = @user.recent_investigation_activity(:size => 30, :current => 1)
    
  end
  
  def show  
    @friend_count               = @user.accepted_friendships.count
    @accepted_friendships       = @user.accepted_friendships.find(:all, :limit => 5).collect{|f| f.friend }
    @pending_friendships_count  = @user.pending_friendships.count()
    @recommendations = Investigation.find_recommended_for(@user)
    @completed_investigations = @user.completed_investigations
    
    #@comments       = @user.comments.find(:all, :limit => 10, :order => 'created_at DESC')
    #@photo_comments = Comment.find_photo_comments_for(@user)    
    @comments = Comment.find_comments_by_user(@user, :limit => 5)

    #@recent_posts   = @user.posts.find(:all, :limit => 2, :order => "published_at DESC")
    #@investigatings = Investigating.find(:all, :conditions => ["user_id = ?", @user.id])
    @tasks=Task.find(:all, :conditions => ["user_id = ?", @user.id])
    
    if @user == current_user
      @investigatings = Investigating.find(:all, :conditions => ["user_id = ?", @user.id])
      
      @investigations = @investigatings.collect{|i| i.investigation}
      
      @investigations = Investigation.find_without_published_as(:all, :conditions => ["user_id = ?", @user.id]) + @investigations
      
      @investigations.uniq!
      
      
    else
      
      @investigatings = Investigating.find(:all, :conditions => ["user_id = ?", @user.id])
            
      #@investigations = Investigation.find_investigations_by_user(@user) + @investigatings.collect{|i| i.investigation}
      
      @investigations = @investigatings.collect{|i| i.investigation}
      
    end
    
    @investigations = @investigations.sort_by { |inv| inv.created_at }.reverse
    
    #@investigaions.uniq!
    #TODO sort them
    
    #@investigations = @user.instigations
    #@investigations = @user.all_investigations
    #@investigations = @user.instigations.find_without_pagination(:all)
    #@clippings      = @user.clippings.find(:all, :limit => 5)
    #@photos         = @user.photos.find(:all, :limit => 5)
    #@comment        = Comment.new(params[:comment])
    
    @my_activity = Activity.recent.by_users([@user.id]).find(:all, :limit => 10) 

    update_view_count(@user) unless current_user && current_user.eql?(@user)
  end
  
  def new
    @user         = User.new( {:birthday => Date.parse((Time.now - 25.years).to_s) }.merge(params[:user] || {}) )
    @inviter_id   = params[:id]
    @inviter_code = params[:code]

    render :action => 'new', :layout => 'beta' and return if AppConfig.closed_beta_mode    
  end

  def create
    @user       = User.new(params[:user])
    @user.role  = Role[:member]

    if (!AppConfig.require_captcha_on_signup || verify_recaptcha(@user)) && @user.save
      create_friendship_with_inviter(@user, params)
      join_investigation_from_invitation(@user, params)
      flash[:notice] = :email_signup_thanks.l_with_args(:email => @user.email) 
      redirect_to signup_completed_user_path(@user.activation_code)
    else
      render :action => 'new'
    end
  end
    
  def edit 
    @skills               = Skill.find(:all)
    @offering             = Offering.new
    @avatar               = Photo.new
  end
  
  def update
    @user.attributes      = params[:user]
  
    @avatar       = Photo.new(params[:avatar])

    @avatar.user  = @user

    @user.avatar  = @avatar if @avatar.save
    
    debugger
    
    @user.tag_list = params[:tag_list] || ''

    if @user.save!
      @user.track_activity(:updated_profile)
      
      flash[:notice] = :your_changes_were_saved.l
      unless params[:welcome] 
        redirect_to user_path(@user)
      else
        redirect_to :action => "welcome_#{params[:welcome]}", :id => @user
      end
    end
  rescue ActiveRecord::RecordInvalid
    render :action => 'edit'
  end
  
  def destroy
    unless @user.admin? || @user.featured_writer?
      @user.destroy
      flash[:notice] = :the_user_was_deleted.l
    else
      flash[:error] = :you_cant_delete_that_user.l
    end
    respond_to do |format|
      format.html { redirect_to users_url }
    end
  end
  
  def change_profile_photo
    @user   = User.find(params[:id])
    @photo  = Photo.find(params[:photo_id])
    @user.avatar = @photo

    if @user.save!
      flash[:notice] = :your_changes_were_saved.l
      redirect_to user_photo_path(@user, @photo)
    end
  rescue ActiveRecord::RecordInvalid
    render :action => 'edit'
  end
  
  def crop_profile_photo    
    @photo = @user.avatar    
    return unless request.put?
    
    if @photo
      if params[:x1]
        img = Magick::Image::read(@photo.s3_url).first.crop(params[:x1].to_i, params[:y1].to_i,params[:width].to_i, params[:height].to_i, true)
        img.format = @photo.content_type.split('/').last
        crop = {'tempfile' => StringIO.new(img.to_blob), 'content_type' => @photo.content_type, 'filename' => "custom_#{@photo.filename}"}
        @photo.uploaded_data = crop
        @photo.save!
      end
    end

    redirect_to user_path(@user)
  end
  
  def upload_profile_photo
    @avatar       = Photo.new(params[:avatar])
    return unless request.put?
    
    @avatar.user  = @user
    if @avatar.save
      @user.avatar  = @avatar 
      @user.save
      redirect_to crop_profile_photo_user_path(@user)
    end
  end
    
  def edit_account
    @user             = current_user
    @is_current_user  = true
  end
  
  def update_account
    @user             = current_user
    @user.attributes  = params[:user]

    if @user.save
      flash[:notice] = :your_changes_were_saved.l
      respond_to do |format|
        format.html {redirect_to user_path(@user)}
        format.js
      end      
    else
      respond_to do |format|
        format.html {render :action => 'edit_account'}
        format.js
      end
    end
  end

  def edit_pro_details
    @user = User.find(params[:id])
  end

  def update_pro_details
    @user = User.find(params[:id])
    @user.add_offerings(params[:offerings]) if params[:offerings]
    
    @user.attributes = params[:user]

    if @user.save!
      respond_to do |format|
        format.html { 
          flash[:notice] = :your_changes_were_saved.l
          redirect_to edit_pro_details_user_path(@user)   
        }
        format.js {
          render :text => 'success'
        }
      end

    end
  rescue ActiveRecord::RecordInvalid
    render :action => 'edit_pro_details'
  end
    
  def create_friendship_with_inviter(user, options = {})
    unless options[:inviter_code].blank? or options[:inviter_id].blank?
      friend = User.find(options[:inviter_id])

      if friend && friend.valid_invite_code?(options[:inviter_code])
        accepted    = FriendshipStatus[:accepted]
        @friendship = Friendship.new(:user_id => friend.id, 
          :friend_id => user.id,
          :friendship_status => accepted, 
          :initiator => true)

        reverse_friendship = Friendship.new(:user_id => user.id, 
          :friend_id => friend.id, 
          :friendship_status => accepted )
          
        @friendship.save
        reverse_friendship.save
      end
    end
  end
  
  def join_investigation_from_invitation(user, options = {})
    unless options[:inviter_code].blank? or options[:investigation_id].blank?
      investigation = Investigation.find(options[:investigation_id])
      friend = User.find(options[:inviter_id])

      if friend && friend.valid_invite_code?(options[:inviter_code]) && investigation
        user.investigations << investigation
        
      end
    end
  end
  
  def signup_completed
    @user = User.find_by_activation_code(params[:id])
    redirect_to home_path and return unless @user
    render :action => 'signup_completed', :layout => 'beta' if AppConfig.closed_beta_mode    
  end
  
  def welcome_photo
    @user = User.find(params[:id])
  end

  def welcome_about
    @user = User.find(params[:id])
  end
    
  def welcome_invite
    @user = User.find(params[:id])    
  end
  
  def invite
    @user = User.find(params[:id])    
  end
  
  def welcome_complete
    flash[:notice] = :walkthrough_complete.l_with_args(:site => AppConfig.community_name) 
    redirect_to user_path
  end
  
  def forgot_password  
    return unless request.post?   

    @user = User.find_by_email(params[:email])  
    if @user && @user.reset_password
      UserNotifier.deliver_reset_password(@user)
      @user.save
      redirect_to login_url
      flash[:info] = :your_password_has_been_reset_and_emailed_to_you.l      
    else
      flash[:error] = :sorry_we_dont_recognize_that_email_address.l
    end 
  end

  def forgot_username  
    return unless request.post?   
    
    if @user = User.find_by_email(params[:email])
      UserNotifier.deliver_forgot_username(@user)
      redirect_to login_url
      flash[:info] = :your_username_was_emailed_to_you.l      
    else
      flash[:error] = :sorry_we_dont_recognize_that_email_address.l
    end 
  end

  def resend_activation
    return unless request.post?       

    @user = User.find_by_email(params[:email])    
    if @user && !@user.active?
      flash[:notice] = :activation_email_resent_message.l :admin_email => AppConfig.support_email
      UserNotifier.deliver_signup_notification(@user)    
      redirect_to login_path and return
    else
      flash[:notice] = :activation_email_not_sent_message.l
    end
  end
  
  def assume
    self.current_user = User.find(params[:id])
    redirect_to user_path(current_user)
  end

  def return_admin
    unless session[:admin_id].nil? or current_user.admin?
      admin = User.find(session[:admin_id])
      if admin.admin?
        self.current_user = admin
        redirect_to user_path(admin)
      end
    else
      redirect_to login_path
    end
  end
  
  def toggle_featured
    @user = User.find(params[:id])
    @user.toggle!(:featured_writer)
    redirect_to user_path(@user)
  end

  def toggle_moderator
    @user = User.find(params[:id])
    @user.role = @user.moderator? ? Role[:member] : Role[:moderator]
    @user.save!
    redirect_to user_path(@user)
  end

  def statistics
    if params[:date]
      date = Date.new(params[:date][:year].to_i, params[:date][:month].to_i)
      @month = Time.parse(date.to_s)
    else
      @month = Time.today    
    end
    
    start_date  = @month.beginning_of_month
    end_date    = @month.end_of_month + 1.day
    
    @posts = @user.posts.find(:all, 
      :conditions => ['? <= published_at AND published_at <= ?', start_date, end_date])    
    
    @estimated_payment = @posts.sum do |p| 
      7
    end
  end  
  

  protected  

    def admin_or_current_user_required
      current_user && (current_user.admin? || @is_current_user) ? true : access_denied     
    end

end
