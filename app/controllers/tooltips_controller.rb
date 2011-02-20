class TooltipsController < BaseController
  resources_controller_for :tooltips
  #before_filter :login_required, :except => [:show]
  #before_filter :require_admin, :except => [:show]
  
  def show
    self.resource = find_resource
    render :layout => false
  end
  
  private
  
  def require_admin
    @user = current_user
    unless admin?
      redirect_to :controller => 'sessions', :action => 'new' and return false
    end
    return @user
  end
  
end
