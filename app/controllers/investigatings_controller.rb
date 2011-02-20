class InvestigatingsController < BaseController
  #TODO make sure only owners or admins can destroy or edit investigatings
  resources_controller_for :investigatings
  before_filter :login_required
  
  def create
      self.resource = new_resource
      resource.user = current_user
      save_resource
      
      respond_to do |format|
        format.html do
          flash[:notice] = "You have joined this investigation"
          redirect_to investigation_path(resource.investigation)
        end
        format.js
        format.xml  { head :ok }
      end
      
      
  end
  
  def destroy
    self.resource = find_resource
    resource.destroy
    respond_to do |format|
      format.html do
        flash[:notice] = "You have quit this investigation"
        redirect_to investigation_path(@investigation)
      end
      format.js
      format.xml  { head :ok }
    end
  end
end
