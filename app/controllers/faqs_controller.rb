class FaqsController < BaseController
  resources_controller_for :faqs
  before_filter :login_required, :only => [:new, :create, :destroy, :update]
  before_filter :require_admin, :except => [:index, :show]
  skip_before_filter :beta_login_required, :only => [:index, :show]
  

  private
  
  def require_admin
    @user = current_user
    unless admin?
      redirect_to :controller => 'sessions', :action => 'new' and return false
    end
    return @user
  end

end
