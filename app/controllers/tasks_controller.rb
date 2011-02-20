class TasksController < BaseController
  resources_controller_for :tasks, :load_enclosing => true
  before_filter :login_required
  
  def index
    @user = User.find(params[:user_id])
    @tasks = @user.tasks
    @challenges = @user.challenges
    
    respond_to do |format|
      format.html 
      format.js
    end
  end
  
  def create
      self.resource = new_resource
      resource.user = current_user
      save_resource      
      
      respond_to do |format|
        format.html do
          flash[:notice] = "You have accepted this challenge"
          redirect_to investigation_challenge_path(@investigation, @challenge)
        end
        format.js
        format.xml  { head :ok }
      end
      
      
  end

  def toggle
    self.resource = find_resource
    resource.receive_emails = ! resource.receive_emails
    resource.save
    render :partial=>"tasks/monitoring", :object=>resource
  end
  
  
  def destroy
    self.resource = find_resource
    resource.destroy
    respond_to do |format|
      format.html do
        flash[:notice] = "You have quit this challenge"
        redirect_to investigation_challenge_path(@investigation, @challenge)
      end
      format.js
      format.xml  { head :ok }
    end
  end
  
  def update
    self.resource = find_resource
    
    resource.update_attribute(:completed, true)
    
    respond_to do |format|
      format.html do
        flash[:notice] = "You have completed this challenge! Please now take a moment to fill in as much as you can about how it has been completed and what you can share with other investigators."
        redirect_to investigation_challenge_path(@investigation, @challenge)
      end
      format.js
      format.xml  { head :ok }
    end
  end
  
end
