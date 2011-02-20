class ChallengesController < BaseController
  resources_controller_for :challenges
  before_filter :login_required, :except => [:index, :show]
  
  def create
      self.resource = new_resource
      resource.user = current_user
      save_resource
      resource.save_as_live
      
      
      respond_to do |format|
        format.html do
          flash[:notice] = "You have issued this challenge"
          redirect_to investigation_investigation_challenge_path(resource.investigation,@investigation, @challenge)
        end
        format.js
        format.xml  { head :ok }
      end
      
      
  end
  
  
  def destroy
    self.resource = find_resource
    investigation = resource.investigation
    resource.destroy
    respond_to do |format|
      format.html do
        flash[:notice] = "You have deleted that challenge"
        redirect_to investigation_path(investigation)
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
        flash[:notice] = "You have set this challenge as requiring moderation"
        redirect_to investigation_challenge_path(resource.investigation,resource)
      end
      format.js
      format.xml  { head :ok }
    end
  end
  
  def trash
    self.resource = find_resource
    investigation = resource.investigation
    resource.save_as_trash
    
    respond_to do |format|
      format.html do
        flash[:notice] = "The challenge has been put in the trash"
        redirect_to investigation_path(investigation)
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
        flash[:notice] = "The challenge has been published"
        redirect_to investigation_challenge_path(resource.investigation,resource)
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
        flash[:notice] = "The challenge has been locked"
        redirect_to investigation_challenge_path(resource.investigation,resource)
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
        flash[:notice] = "The challenge has been unlocked"
        redirect_to investigation_challenge_path(resource.investigation,resource)
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
        flash[:notice] = "The challenge has been featured"
        redirect_to investigation_challenge_path(resource.investigation,resource)
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
        flash[:notice] = "The challenge has been unfeatured"
        redirect_to investigation_challenge_path(resource.investigation,resource)
      end
      format.js
      format.xml  { head :ok }
    end
  end
  
  def complete
    self.resource = find_resource
    resource.completed = true
    resource.save
    respond_to do |format|
      format.html do
        flash[:notice] = "The challenge has been marked as complete"
        redirect_to investigation_challenge_path(resource.investigation,resource)
      end
      format.js
      format.xml  { head :ok }
    end
  end
  
  def uncomplete
    self.resource = find_resource
    resource.completed = false
    resource.save
    respond_to do |format|
      format.html do
        flash[:notice] = "The challenge has been marked as in progress"
        redirect_to investigation_challenge_path(resource.investigation,resource)
      end
      format.js
      format.xml  { head :ok }
    end
  end
  
  def index
    #TODO sort by reverse date
    #TODO add translation for "completed
    @challenges = Challenge.recent.find :all, :conditions => ['completed = 0'], :page => {:size => 10, :current => params[:page]}
  end
  
  
  def all
    #TODO sort by reverse date
    #TODO add translation for "completed
    @challenges = Challenge.recent.find :all, :page => {:size => 10, :current => params[:page]}
  end
  
  def featured
    @challenges = Challenge.recent.find :all, :conditions => ['featured = 1'], :page => {:size => 10, :current => params[:page]}

  end
  
  def nearby
    @challenges = Challenge.recent.find :all, :page => {:size => 10, :current => params[:page]}
  end
  
  def popular
    
  end
  
  def completed
    @challenges = Challenge.find :all, :conditions => ['completed = 1'], :page => {:size => 10, :current => params[:page]}
  end
  
  def incomplete
    @challenges = Challenge.find :all, :conditions => ['completed = 0'], :page => {:size => 10, :current => params[:page]}
  end
  
end
