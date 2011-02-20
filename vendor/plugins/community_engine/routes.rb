#Forum routes go first
recent_forum_posts '/forums/recent', :controller => 'sb_posts', :action => 'index'
resources :forums, :sb_posts, :monitorship
resources :sb_posts, :name_prefix => 'all_', :collection => { :search => :get, :monitored => :get }

%w(forum).each do |attr|
  resources :sb_posts, :name_prefix => "#{attr}_", :path_prefix => "/#{attr.pluralize}/:#{attr}_id"
end

resources :forums do |forum|
  forum.resources :moderators
  forum.resources :topics do |topic|
    topic.resources :sb_posts
    topic.resource :monitorship, :controller => :monitorships
  end
end
forum_home '/forums', :controller => 'forums', :action => 'index'
resources :topics


connect 'sitemap.xml', :controller => "sitemap", :action => "index", :format => 'xml'
connect 'sitemap', :controller => "sitemap", :action => "index"

if AppConfig.closed_beta_mode
  connect '', :controller => "base", :action => "teaser"
  home 'home', :controller => "base", :action => "site_index"
else
  home '', :controller => "base", :action => "site_index"
end

# admin routes
admin   '/admin', :controller => 'admin', :action => 'index'
admin_investigations   '/admin/investigations', :controller => 'admin', :action => 'investigations'
admin_blanks  '/admin/blanks', :controller => 'admin', :action => 'blanks'
admin_challenges   '/admin/challenges', :controller => 'admin', :action => 'challenges'
admin_users       '/admin/users', :controller => 'admin', :action => 'users'
admin_messages    '/admin/messages', :controller => 'admin', :action => 'messages'
admin_comments    '/admin/comments', :controller => 'admin', :action => 'comments'
admin_activities   '/admin/activities', :controller => 'admin', :action => 'activities'
resources :homepage_features, :path_prefix => '/admin'



# sessions routes
teaser '', :controller=>'base', :action=>'teaser'
login  '/login',  :controller => 'sessions', :action => 'new'
signup '/signup', :controller => 'users', :action => 'new'
logout '/logout', :controller => 'sessions', :action => 'destroy'
signup_by_id '/signup/:inviter_id/:inviter_code/:investigation_id', :controller => 'users', :action => 'new'
signup_by_user '/signup/:inviter_id/:inviter_code', :controller => 'users', :action => 'new'


forgot_password '/forgot_password', :controller => 'users', :action => 'forgot_password'
forgot_username '/forgot_username', :controller => 'users', :action => 'forgot_username'  
resend_activation '/resend_activation', :controller => 'users', :action => 'resend_activation'  

#clippings routes
connect '/new_clipping', :controller => 'clippings', :action => 'new_clipping'
site_clippings '/clippings', :controller => 'clippings', :action => 'site_index'
rss_site_clippings '/clippings.rss', :controller => 'clippings', :action => 'site_index', :format => 'rss'

featured '/posts/featured', :controller => 'posts', :action => 'featured'
featured_rss '/posts/featured.rss', :controller => 'posts', :action => 'featured', :format => 'rss'
popular '/posts/popular', :controller => 'posts', :action => 'popular'
popular_rss '/posts/popular.rss', :controller => 'posts', :action => 'popular', :format => 'rss'
recent '/posts/recent', :controller => 'posts', :action => 'recent'
recent_rss '/posts/recent.rss', :controller => 'posts', :action => 'recent', :format => 'rss'
rss_redirect '/posts/rss', :controller => 'base', :action => 'rss_site_index'
rss '/site_index.rss', :controller => 'base', :action => 'site_index', :format => 'rss'

about '/about', :controller => 'base', :action => 'about'
terms '/terms', :controller => 'base', :action => 'terms'
team '/team', :controller => 'base', :action => 'team'
contact '/contact', :controller => 'base', :action => 'contact'
credits '/credits', :controller => 'base', :action => 'credits'
ethics '/ethics', :controller => 'base', :action => 'ethics'
ethics '/privacy', :controller => 'base', :action => 'privacy'
request_invitation '/request', :controller => 'base', :action => 'request_invitation'


#advertise '/advertise', :controller => 'base', :action => 'advertise'
#faq '/faq', :controller => 'base', :action => 'faq'
#css_help '/css_help', :controller => 'base', :action => 'css_help'  

community_guidelines '/community-guidelines', :controller => 'base', :action => 'community_guidelines'

investigation_guidelines '/investigation-guidelines', :controller => 'base', :action => 'investigation_guidelines'


edit_account_from_email '/account/edit', :controller => 'users', :action => 'edit_account'

friendships_xml '/friendships.xml', :controller => 'friendships', :action => 'index', :format => 'xml'
friendships '/friendships', :controller => 'friendships', :action => 'index'

manage_photos 'manage_photos', :controller => 'photos', :action => 'manage_photos'
create_photo 'create_photo.js', :controller => 'photos', :action => 'create', :format => 'js'

resources :sessions
resources :statistics, :collection => {:activities => :get, :activities_chart => :get}
resources :tags, :member_path => '/tags/:id'
show_tag_type '/tags/:id/:type', :controller => 'tags', :action => 'show'
search_tags '/search/tags', :controller => 'tags', :action => 'show'
search '/search', :controller => 'base', :action => 'search'


resources :posts
resources :categories
resources :skills
resources :events
resources :favorites, :path_prefix => '/:favoritable_type/:favoritable_id'
resources :comments, :path_prefix => '/:commentable_type/:commentable_id', :member => {:shorten => :put, :publish => :put, :moderate => :put, :trash => :put}
#resources :metro_areas
#resources :ads
resources :contests, :collection => { :current => :get }
resources :activities

resources :users, :member_path => '/:id', :nested_member_path => '/:user_id', :member => { 
    :dashboard => :get,
    :assume => :get,
    :toggle_moderator => :put,
    :toggle_featured => :put,
    :change_profile_photo => :put,
    :return_admin => :get, 
    :edit_account => :get,
    :update_account => :put,
    :edit_pro_details => :get,
    :update_pro_details => :put,      
    :forgot_password => [:get, :post],
    :signup_completed => :get,
    :invite => :get,
    :welcome_photo => :get, 
    :welcome_about => :get, 
    :welcome_stylesheet => :get, 
    :welcome_invite => :get,
    :welcome_complete => :get,
    :statistics => :any,
    :deactivate => :put,
    :crop_profile_photo => [:get, :put],
    :upload_profile_photo => [:get, :put]
     } do |user|
  user.resources :friendships, :member => { :accept => :put, :deny => :put }, :collection => { :accepted => :get, :pending => :get, :denied => :get }
  user.resources :photos, :collection => {:swfupload => :post, :slideshow => :get}
  user.resources :posts, :collection => {:manage => :get}, :member => {:contest => :get, :send_to_friend => :any, :update_views => :any}
  user.resources :clippings
  user.resources :activities, :collection => {:network => :get}
  user.resources :invitations
  user.resources :tasks
  user.resources :investigatings
  user.resources :investigations
  user.resources :offerings, :collection => {:replace => :put}
  user.resources :favorites, :name_prefix => 'user_'
  user.resources :messages, :collection => { :delete_selected => :post }  
  user.resources :comments
end
resources :votes
resources :invitations

users_posts_in_category '/users/:user_id/posts/category/:category_name', :controller => 'posts', :action => 'index', :category_name => :category_name

with_options(:controller => 'theme', :filename => /.*/, :conditions => {:method => :get}) do |theme|
  theme.connect 'stylesheets/theme/:filename', :action => 'stylesheets'
  theme.connect 'javascripts/theme/:filename', :action => 'javascript'
  theme.connect 'images/theme/:filename',      :action => 'images'
end

# Deprecated routes
deprecated_popular_rss '/popular_rss', :controller => 'base', :action => 'popular', :format => 'rss'    
deprecated_category_rss '/categories/:id;rss', :controller => 'categories', :action => 'show', :format => 'rss'  
deprecated_posts_rss '/:user_id/posts;rss', :controller => 'posts', :action => 'index', :format => 'rss'