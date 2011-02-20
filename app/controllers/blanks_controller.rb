class BlanksController < BaseController
  resources_controller_for :blanks
  before_filter :login_required
  
  def create
      self.resource = new_resource
      resource.user = current_user
      save_resource
      resource.save_as_live
            
      respond_to do |format|
        format.html do
          flash[:notice] = "You have joined this investigation"
          redirect_to investigation_path(@investigation)
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
        flash[:notice] = "You have set this blank as requiring moderation"
        redirect_to investigation_blank_path(resource.investigation, resource)
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
        flash[:notice] = "The blank has been put in the trash"
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
        flash[:notice] = "The blank has been published"
        redirect_to blank_path(resource)
      end
      format.js
      format.xml  { head :ok }
    end
  end
  
  
  def show
    self.resource = find_resource
    @related = Investigation.find_related_to(@blank.investigation)
    @investigation = @blank.investigation
    @blanks = @investigation.blanks
  end
  
end
