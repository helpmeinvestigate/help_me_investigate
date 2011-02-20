class InvitationsController < BaseController
  before_filter :login_required
  #TODO before_filter :is_investigating_this

  def index
    @user = current_user
    @invitations = @user.invitations

    respond_to do |format|
      format.html 
    end
  end
  
  def new
    @user = current_user
    @invitation = Invitation.new
  end
  

  def edit
    @invitation = Invitation.find(params[:id])
  end


  def create
    @user = current_user

    @invitation = Invitation.new(params[:invitation])
    @invitation.user = @user
    @invitation.investigation = Investigation.find_by_id(params[:investigation_id]) unless params[:investigation_id].blank?
    
    respond_to do |format|
      if @invitation.save
        flash[:notice] = :invitation_was_successfully_created.l
        format.html { 
          unless params[:welcome]
            unless @invitation.investigation.blank?
              redirect_to investigation_path(@invitation.investigation) 
            else
              redirect_to user_path(@invitation.user) 
            end
          else
            redirect_to welcome_complete_user_path(@invitation.user)            
          end
        }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
end