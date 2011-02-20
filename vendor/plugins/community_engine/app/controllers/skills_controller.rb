class SkillsController < BaseController
  before_filter :login_required, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :admin_required, :only => [:new, :create, :edit, :update, :destroy]

  # GET /skills
  # GET /skills.xml
  def index
    @skills = Skill.find(:all)

    @users = User.recent.vendors.find :all, :include => :tags, :page => {:current => params[:page], :size => 10}
    
    @tags = User.tag_counts :limit => 10

    @active_users = User.find(:all,
      :include => [:offerings],
      :limit => 5,
      :conditions => ["users.updated_at > ? AND vendor = ?", 5.days.ago, true],
      :order => "users.view_count DESC")

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @skills.to_xml }
    end
  end
  
  # GET /skills/1
  # GET /skills/1.xml
  def show
    @skill = Skill.find(params[:id])
    @users = @skill.users.find(:all, :page => {:current => params[:page], :size => 10})
        
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @skill.to_xml }
    end
  end
  
  # GET /skills/new
  def new
    @skill = Skill.new
  end
  
  # GET /skills/1;edit
  def edit
    @skill = Skill.find(params[:id])
  end

  # POST /skills
  # POST /skills.xml
  def create
    @skill = Skill.new(params[:skill])
    
    respond_to do |format|
      if @skill.save
        flash[:notice] = :skill_was_successfully_created.l
        
        format.html { redirect_to skill_url(@skill) }
        format.xml do
          headers["Location"] = skill_url(@skill)
          render :nothing => true, :status => "201 Created"
        end
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @skill.errors.to_xml }
      end
    end
  end
  
  # PUT /skills/1
  # PUT /skills/1.xml
  def update
    @skill = Skill.find(params[:id])
    
    respond_to do |format|
      if @skill.update_attributes(params[:skill])
        format.html { redirect_to skill_url(@skill) }
        format.xml  { render :nothing => true }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @skill.errors.to_xml }        
      end
    end
  end
  
  # DELETE /skills/1
  # DELETE /skills/1.xml
  def destroy
    @skill = Skill.find(params[:id])
    @skill.destroy
    
    respond_to do |format|
      format.html { redirect_to skills_url   }
      format.xml  { render :nothing => true }
    end
  end
end