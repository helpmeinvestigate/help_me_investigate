class MessagesController < BaseController
  before_filter :find_user
  before_filter :login_required
  before_filter :require_ownership_or_moderator

    
  def index
    if params[:mailbox] == "sent"
      @messages = @user.sent_messages.find(:all, :page => {:current => params[:page], :size => 20})
    else
      @messages = @user.received_messages.find(:all, :page => {:current => params[:page], :size => 20})
    end
  end
  
  def show
    @message = Message.read(params[:id], current_user)
  end
  
  def new
    @message = Message.new(params[:message])

    if params[:reply_to]
      @reply_to = @user.received_messages.find(params[:reply_to])
      unless @reply_to.nil?
        @message.to = @reply_to.sender.login
        @message.subject = "Re: #{@reply_to.subject}"
        @message.body = "\n\n*Original message*\n\n #{@reply_to.body}"
      end
    end
  end
  
  def create
    
    if ( params[:everyone] || params[:admins] ) && current_user.admin?
    
      
      users = User.active if params[:everyone]
      users = User.admins if params[:admins]
      
      
      flash[:notice] = "Bulk messaging results:"
      
      users.each do |user|
         @message = Message.new(params[:message])
         @message.sender = @user
         @message.recipient = user
         @message.bulk = true
         unless @message.save
          flash[:notice] << "<br /><strong>Failed</strong>: " + user.login
         else
           flash[:notice] << "<br />Success: " + user.login
         end
      end
      
      redirect_to user_messages_path(@user)
      
    else
      @message = Message.new(params[:message])
      @message.sender = @user
      @message.recipient = User.find_by_login(params[:message][:to])
      
      if @message.save
        flash[:notice] = :message_sent.l
        redirect_to user_messages_path(@user)
      else
        render :action => :new
      end
      
    end
  
    
  end
  
  def delete_selected
    if request.post?
      if params[:delete]
        params[:delete].each { |id|
          @message = Message.find(:first, :conditions => ["messages.id = ? AND (sender_id = ? OR recipient_id = ?)", id, @user, @user])
          @message.mark_deleted(@user) unless @message.nil?
        }
        flash[:notice] = :messages_deleted.l
      end
      redirect_to user_message_path(@user, @messages)
    end
  end
  
  private
    def find_user
      @user = User.find(params[:user_id])
    end

    def require_ownership_or_moderator
      unless admin? || moderator? || (@user && (@user.eql?(current_user)))
        redirect_to :controller => 'sessions', :action => 'new' and return false
      end
      return @user
    end    
end