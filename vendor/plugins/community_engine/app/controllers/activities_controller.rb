class ActivitiesController < BaseController
  before_filter :login_required, :except => :index
  before_filter :find_user, :except => :index
  before_filter :require_current_user, :except => :index
  
  def network
    @activities = @user.network_activity(:size => 15, :current => params[:page])
  end
  
  def index
    
    if(params[:investigation_id])
      @investigation = Investigation.find(params[:investigation_id])
      @activities = Activity.on_investigations([@investigation.id])
    elsif(params[:user_id] || params[:id])
      find_user  
      @activities = Activity.by_users([@user.id]) #(:all, :size => 30, :current => params[:page], :limit => 1000)
    else  
      @activities = User.recent_activity(:size => 30, :current => params[:page], :limit => 1000)
    end
    
    @popular_tags = popular_tags(30, ' count DESC')    
  end

end
