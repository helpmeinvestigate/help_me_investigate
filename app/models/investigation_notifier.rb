class InvestigationNotifier < ActionMailer::Base
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::SanitizeHelper
  extend  ActionView::Helpers::SanitizeHelper::ClassMethods # Required for rails 2.2

  include BaseHelper
  ActionMailer::Base.default_url_options[:host] = APP_URL.sub('http://', '')

  def moderation_notification(investigation)
    @recipients  = "admin@helpmeinvestigate.com"
    setup_sender_info
    @subject     = "[Moderate this] " + investigation.question
    @sent_on     = Time.now
    @body[:question] = investigation.question
    @body[:description] = investigation.description
    @body[:user] = investigation.user
    @body[:url]  = "#{APP_URL}/investigations/#{investigation.to_param}"
  end

  def approval_notification(investigation)
    @recipients  = investigation.user.email
    setup_sender_info
    @subject     = "Your investigation has been approved"
    @sent_on     = Time.now
    @body[:question] = investigation.question
    @body[:description] = investigation.question
    @body[:user] = investigation.user
    @body[:url]  = "#{APP_URL}/investigations/#{investigation.to_param}"
  end
  
  def challenge_completed_notification(user,investigation,challenge)
    @recipients  = user.email
    setup_sender_info
    @subject     = "A challenge has been completed on your investigation"
    @sent_on     = Time.now
    @body[:question] = investigation.question
    @body[:description] = challenge.title
    @body[:user] = challenge.user
    @body[:url]  = "#{APP_URL}/investigations/#{investigation.to_param}"
  end
  
  def completed_notification(user,investigation)
    @recipients  = user.email
    setup_sender_info
    @subject     = "Your investigation has been completed!"
    @sent_on     = Time.now
    @body[:question] = investigation.question
    @body[:description] = investigation.description
    @body[:user] = user
    @body[:url]  = "#{APP_URL}/investigations/#{investigation.to_param}"
  end
  
  def uncompleted_notification(user,investigation)
    @recipients  = user.email
    setup_sender_info
    @subject     = "Your investigation has been reopened"
    @sent_on     = Time.now
    @body[:question] = investigation.question
    @body[:description] = investigation.description
    @body[:user] = user
    @body[:url]  = "#{APP_URL}/investigations/#{investigation.to_param}"
  end
  
  
  def challenge_set_notification(user,investigation,challenge)
    @recipients  = user.email
    setup_sender_info
    @subject     = "A new challenge has been set on your investigation"
    @sent_on     = Time.now
    @body[:question] = investigation.question
    @body[:description] = challenge.title
    @body[:user] = challenge.user
    @body[:url]  = "#{APP_URL}/investigations/#{investigation.to_param}"
  end
  
  def challenge_accepted_notification(user,investigation,challenge)
    @recipients  = user.email
    setup_sender_info
    @subject     = "You have accepted a challenge"
    @sent_on     = Time.now
    @body[:question] = investigation.question
    @body[:description] = challenge.title
    @body[:user] = challenge.user
    @body[:url]  = "#{APP_URL}/investigations/#{investigation.to_param}"
  end
  
  def signup_invitation(email, user, investigation, message)
    setup_sender_info
    @recipients  = "#{email}"
    @subject     = "#{user.login} would like you to join #{AppConfig.community_name}!"
    @sent_on     = Time.now
    @body[:user] = user
    @body[:investigation] = investigation
    @body[:url]  = signup_by_id_url(user.id, user.invite_code, investigation.id)
    
    @body[:message] = message
  end

  def friendship_request(friendship)
    setup_email(friendship.friend)
    @subject     += "#{friendship.user.login} would like to be friends with you!"
    @body[:url]  = pending_user_friendships_url(friendship.friend)
    @body[:requester] = friendship.user
  end
  
  def friendship_accepted(friendship)
    setup_email(friendship.user) 
    @subject     += "Friendship request accepted!"       
    @body[:requester] = friendship.user
    @body[:friend]    = friendship.friend
    @body[:url]       = user_url(friendship.friend)
  end

  def comment_notice(comment)
    setup_email(comment.recipient)
    @subject     += "#{comment.username} has something to say to you on #{AppConfig.community_name}!"
    @body[:url]  = commentable_url(comment)
    @body[:comment] = comment
    @body[:commenter] = comment.user
  end
  
  def follow_up_comment_notice(user, comment)
    setup_email(user)
    @subject     += "#{comment.username} has commented on a #{comment.commentable_type} that you also commented on."
    @body[:url]  = commentable_url(comment)
    @body[:comment] = comment
    @body[:commenter] = comment.user
  end  

  def follow_up_comment_notice_anonymous(email, comment)
    @recipients  = "#{email}"
    setup_sender_info
    @subject     = "[#{AppConfig.community_name}] "
    @sent_on     = Time.now
    @subject     += "#{comment.username} has commented on a #{comment.commentable_type} that you also commented on."
    @body[:url]  = commentable_url(comment)
    @body[:comment] = comment
  end

  def new_forum_post_notice(user, post)
     setup_email(user)
     @subject     += "#{post.user.login} has posted in a thread you are monitoring."
     @body[:url]  = "#{forum_topic_url(:forum_id => post.topic.forum, :id => post.topic, :page => post.topic.last_page)}##{post.dom_id}"
     @body[:post] = post
     @body[:author] = post.user
   end

  def signup_notification(user)
    setup_email(user)
    @subject    += "Please activate your new #{AppConfig.community_name} account"
    @body[:url]  = "#{APP_URL}/users/activate/#{user.activation_code}"
  end
  
  def message_notification(message)
    setup_email(message.recipient)
    @subject     += "#{message.sender.login} sent you a private message!"
    @body[:message] = message
  end


  def post_recommendation(name, email, post, message = nil, current_user = nil)
    @recipients  = "#{email}"
    @sent_on     = Time.now
    setup_sender_info
    @subject     = "Check out this story on #{AppConfig.community_name}"
    content_type "text/plain"
    @body[:name] = name  
    @body[:title]  = post.title
    @body[:post] = post
    @body[:signup_link] = (current_user ?  signup_by_id_url(current_user, current_user.invite_code) : "#{APP_URL}/signup" )
    @body[:message]  = message
    @body[:url]  = user_post_url(post.user, post)
    @body[:description] = truncate_words(post.post, 100, @body[:url] )     
  end
  
  def activation(user)
    setup_email(user)
    @subject    += "Your #{AppConfig.community_name} account has been activated!"
    @body[:url]  = "#{APP_URL}"
  end
  
  def reset_password(user)
    setup_email(user)
    @subject    += "#{AppConfig.community_name} User information"
  end

  def forgot_username(user)
    setup_email(user)
    @subject    += "#{AppConfig.community_name} User information"
  end

  
  protected
  def setup_email(user)
    @recipients  = "#{user.email}"
    setup_sender_info
    @subject     = "[#{AppConfig.community_name}] "
    @sent_on     = Time.now
    @body[:user] = user
  end
  
  def setup_sender_info
    @from       = "The #{AppConfig.community_name} Team <#{AppConfig.support_email}>" 
    headers     "Reply-to" => "#{AppConfig.support_email}"
    @content_type = "text/plain"           
  end

  
end
