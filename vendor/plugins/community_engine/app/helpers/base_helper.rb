require 'md5'
require 'hpricot'
require 'twitter'


# Methods added to this helper will be available to all templates in the application.
module BaseHelper

  def body_classes
    classes = []
    classes << @section
    classes
  end

  def recent_tweets
  
     #unless fragment_exist?("twitter_" + Date.today.to_s + '-' + Time.now.hour.to_s)

        begin
          logger.debug("calling twitter")
          #httpauth = Twitter::HTTPAuth.new('ourmodernlove', 'pass')
          #twitter = Twitter::Base.new(httpauth)
          #@tweets = twitter.user_timeline[0..5]
          @tweets = Twitter::Search.new.from('helpmeinvestig8').fetch().results
          logger.debug(@tweets)
        rescue
          @tweets = []
        end
      #end
      @tweets
  end
  
  def commentable_url(comment)
    if comment.commentable_type != "User"
       if comment.commentable_type == "Blank"
          investigation_blank_url(comment.commentable.investigation, comment.commentable)+"#comment_#{comment.id}"
        
        elsif comment.commentable_type == "Challenge"
            investigation_challenge_url(comment.commentable.investigation, comment.commentable)+"#comment_#{comment.id}"
        elsif comment.commentable_type == "Investigation"
          investigation_url(comment.commentable)+"#comment_#{comment.id}"
              
        else
          polymorphic_url([comment.recipient, comment.commentable])+"#comment_#{comment.id}"
        end
    else
      user_url(comment.recipient)+"#comment_#{comment.id}"
    end
  end


  def forum_page?
    %w(forums topics sb_posts).include?(@controller.controller_name)
  end
  
  def is_current_user_and_featured?(u)
     u && u.eql?(current_user) && u.featured_writer?
  end
  
  def resize_img(classname, width=90, height=135)
    "<style>
      .#{classname} {
        max-width: #{width}px;
      }
    </style>
    <script type=\"text/javascript\">
    	//<![CDATA[
        Event.observe(window, 'load', function(){
      		$$('img.#{classname}').each(function(image){
      			CommunityEngine.resize_image(image, {max_width: #{width}, max_height:#{height}});
      		});          
        }, false);
    	//]]>
    </script>"
  end

  def rounded(options={}, &content)
    options = {:class=>"box"}.merge(options)
    options[:class] = "box " << options[:class] if options[:class]!="box"

    str = '<div'
    options.collect {|key,val| str << " #{key}=\"#{val}\"" }
    str << '><div class="box_top"></div>'
    str << "\n"
    
    concat(str)
    yield(content)
    concat('<br class="clear" /><div class="box_bottom"></div></div>')
  end

  def rss_icon(url)
    '<div class="rss"><a href="' + url + '" title="RSS"><span class="hidden">RSS</span></a></div>'
  end

  def tag_cloud(tags, classes)
    unless tags.blank?
      max, min = 0, 0
      tags.each { |t|
        max = t.count.to_i if t.count.to_i > max
        min = t.count.to_i if t.count.to_i < min
      }

      divisor = ((max - min) / classes.size) + 1

      tags.each { |t|
        yield t.name, classes[(t.count.to_i - min) / divisor]
      }
    end
  end
  
  
  def context_tag_cloud(tags, classes)
    unless tags.blank?

      max, min = 0, 0
    
      tags.each { |t|
        the_count = tags.select {|tag| tag == t}.size.to_i
        max = the_count if the_count > max
        min = the_count if the_count < min
      }
    
      divisor = ((max - min) / classes.size) + 1
    
      result_tags = tags.uniq
      result_tags.each { |t|
        yield t.name, classes[(tags.select {|tag| tag == t}.size.to_i - min) / divisor]
      }
    end
  end
  
  def city_cloud(cities, classes)
    max, min = 0, 0
    cities.each { |c|
      max = c.users.size.to_i if c.users.size.to_i > max
      min = c.users.size.to_i if c.users.size.to_i < min
    }

    divisor = ((max - min) / classes.size) + 1

    cities.each { |c|
      yield c, classes[(c.users.size.to_i - min) / divisor]
    }
  end

  def truncate_words(text, length = 30, end_string = '...')
    return if text.blank?
    words = strip_tags(text).split()
    words[0..(length-1)].join(' ') + (words.length > length ? end_string : '')
  end
  
  def truncate_words_with_highlight(text, phrase)
    t = excerpt(text, phrase)
    highlight truncate_words(t, 18), phrase
  end

  def excerpt_with_jump(text, end_string = ' ...')
    return if text.blank?
    doc = Hpricot( text )
    paragraph = doc.at("p")
    if paragraph
      paragraph.to_html + end_string
    else
      truncate_words(text, 150, end_string) 
    end
  end

	def page_title
		app_base = AppConfig.community_name
		tagline = " | #{AppConfig.community_tagline}"
	
		title = app_base
		case @controller.controller_name
			when 'base'
					title += tagline
			when 'posts'
        if @post and @post.title
          title = @post.title + ' &raquo; ' + app_base + tagline
          title += (@post.tags.empty? ? '' : " &laquo; "+:keywords.l+": " + @post.tags[0...4].join(', ') )
          @canonical_url = user_post_url(@post.user, @post)
        end
			when 'users'
        if @user && !@user.new_record? && @user.login 
          title = @user.login
          title += ', expert in ' + @user.offerings.collect{|o| o.skill.name }.join(', ') if @user.vendor? and !@user.offerings.empty?
          title += ' &raquo; ' + app_base + tagline
          @canonical_url = user_url(@user)          
        else
          title = :showing_users.l+' &raquo; ' + app_base + tagline
        end
			when 'photos'
        if @user and @user.login
          title = @user.login + '\'s '+:photos.l+' &raquo; ' + app_base + tagline
        end
			when 'clippings'
        if @user and @user.login
          title = @user.login + '\'s '+:clippings.l+' &raquo; ' + app_base + tagline
        end
			when 'tags'
				case @controller.action_name
			    when 'show'
            title = @tags.map(&:name).join(', ') + ' '
            title += params[:type] ? params[:type].pluralize : :posts_photos_and_bookmarks.l
            title += ' (Related: ' + @related_tags.join(', ') + ')' if @related_tags
            title += ' | ' + app_base    
            @canonical_url = tag_url(URI::encode(@tags_raw, /[\/.?#]/)) if @tags_raw
          else
          title = 'Showing tags &raquo; ' + app_base + tagline            
			  end
      when 'categories'
        if @category and @category.name
          title = @category.name + ' '+:posts_photos_and_bookmarks.l+' &raquo; ' + app_base + tagline
        else
          title = :showing_categories.l+' &raquo; ' + app_base + tagline            
        end
      when 'skills'
        if @skill and @skill.name
          title = :find_an_expert_in.l+' ' + @skill.name + ' &raquo; ' + app_base + tagline
        else
          title = :find_experts.l+' &raquo; ' + app_base + tagline            
        end
      when 'sessions'
        title = :login.l+' &raquo; ' + app_base + tagline     
      when 'investigations'
        if @investigation and @investigation.question
          title = @investigation.question + " on Help Me Investigate"
        else
          title = "Investigations on Help Me Investigate"
        end       
      when 'blanks'
        if @blank
          title = "A blank for " + @blank.investigation.question
        else
          title = "Blanks for " + @investigation.question
          
        end
		end

    if @page_title
      title = @page_title + ' &raquo; ' + app_base + tagline
    elsif title == app_base          
		  title = :showing.l+' ' + @controller.controller_name + ' &raquo; ' + app_base + tagline
    end	
		title
	end

  def add_friend_link(user = nil)
		html = "<span class='friend_request' id='friend_request_#{user.id}'>"
    html += link_to_remote :request_friendship.l,
				{:update => "friend_request_#{user.id}",
					:loading => "$$('span#friend_request_#{user.id} span.spinner')[0].show(); $$('span#friend_request_#{user.id} a.add_friend_btn')[0].hide()", 
					:complete => visual_effect(:highlight, "friend_request_#{user.id}", :duration => 1),
          500 => "alert('"+:sorry_there_was_an_error_requesting_friendship.l+"')",
					:url => hash_for_user_friendships_url(:user_id => current_user.id, :friend_id => user.id), 
					:method => :post }, {:class => "add_friend button"}
		html +=	"<span style='display:none;' class='spinner'>"
		html += image_tag 'spinner.gif', :plugin => "community_engine"
		html += :requesting_friendship.l+" ...</span></span>"
		html
  end

  def topnav_tab(name, options)
    classes = [options.delete(:class)]
    classes << options[:section]
    classes << 'current' if options[:section] && (options.delete(:section).to_a.include?(@section))
    
    "<li class='#{classes.join(' ')}'>" + link_to( "<span>"+name+"</span>", options.delete(:url), options) + "</li>"
  end

  def subnav_tab(name, options)
    classes = [options.delete(:class)]
    classes << options[:subsection]
    classes << 'current' if options[:subsection] && (options.delete(:subsection).to_a.include?(@subsection))
    
    "<li class='#{classes.join(' ')}'>" + link_to( "<span>"+name+"</span>", options.delete(:url), options) + "</li>"
  end

  # def format_post_totals(posts)
  #   "#{posts.size} posts, How to: #{posts.select{ |p| p.category.eql?(Category.get(:how_to))}.size}, Non How To: #{posts.select{ |p| !p.category.eql?(Category.get(:how_to))}.size}"
  # end
  
  def more_comments_links(commentable)
    html = link_to "&raquo; " + :all_comments.l, comments_url(commentable.class.to_s.underscore, commentable.to_param)
    html += "<br />"
		html += link_to "&raquo; " + :comments_rss.l, formatted_comments_url(commentable.class.to_s.underscore, commentable.to_param, :rss)
		html
  end
  
  def more_user_comments_links(user = @user)
    html = link_to "&raquo; " + :all_comments.l, user_comments_url(user)
    html += "<br />"
    #formatted_user_comments_url(user.to_param, :rss) was still returning /user/id/comments.rss, so brute-forcing it
		html += link_to "&raquo; " + :comments_rss.l, formatted_user_comments_url(user.to_param, :rss)
		html  
  end
  
  def activities_line_graph(options = {})
    line_color = "0x628F6C"
    prefix  = ''
    postfix = ''
    start_at_zero = false
    swf = "/images/swf/line_grapher.swf?file_name=/statistics.xml;activities&line_color=#{line_color}&prefix=#{prefix}&postfix=#{postfix}&start_at_zero=#{start_at_zero}"

    code = <<-EOF
    <object width="100%" height="400">
    <param name="movie" value="#{swf}">
    <embed src="#{swf}" width="100%" height="400">
    </embed>
    </object>
    EOF
    code
  end

  def feature_enabled?(feature)
    AppConfig.sections_enabled.include?(feature)
  end  

  def show_footer_content?
    return true if (
      current_page?(:controller => 'base', :action => 'site_index') || 
      current_page?(:controller => 'posts', :action => 'show')  ||
      current_page?(:controller => 'categories', :action => 'show')  ||    
      current_page?(:controller => 'users', :action => 'show')
    ) 
    
    return false
  end
  
  def clippings_link
    "javascript:(function() {d=document, w=window, e=w.getSelection, k=d.getSelection, x=d.selection, s=(e?e():(k)?k():(x?x.createRange().text:0)), e=encodeURIComponent, document.location='#{APP_URL}/new_clipping?uri='+e(document.location)+'&title='+e(document.title)+'&selection='+e(s);} )();"    
  end
  
  def paginating_links(paginator, options = {}, html_options = {})
    if paginator.page_count > 1
  		name = options[:name] || PaginatingFind::Helpers::DEFAULT_OPTIONS[:name]
 
    	our_params = (options[:params] || params).clone
      
      our_params.delete("authenticity_token")
      our_params.delete("commit")

    	links = paginating_links_each(paginator, options) do |n|
    	  our_params[name] = n
    	  link_to(n, our_params, html_options.merge(:class => (paginator.page.eql?(n) ? 'active' : '')))
    	end
    end
    
    content_tag(:div, pagination_info_for(paginator), :class => 'pagination_info') + (links || '')
  end  
  
  def pagination_info_for(paginator, options = {})
    options = {:prefix => :showing.l, :connector => '-', :suffix => ""}.merge(options)
    window = paginator.first_item.to_s + options[:connector] + paginator.last_item.to_s
    options[:prefix] + " <strong>#{window}</strong> " + 'of'.l + " #{paginator.size} " + options[:suffix]
  end
  
  
  def last_active
    session[:last_active] ||= Time.now.utc
  end
    
  def submit_tag(value = :save_changes.l, options={} )
    or_option = options.delete(:or)
    return super + "<span class='button_or'>or " + or_option + "</span>" if or_option
    super
  end

  def ajax_spinner_for(id, spinner="spinner.gif")
    "<img src='/images/#{spinner}' style='display:none; vertical-align:middle;' id='#{id.to_s}_spinner'> "
  end

  def avatar_for(user, size=32)
    image_tag user.avatar_photo_url(:medium), :size => "#{size}x#{size}", :class => 'photo'
  end

  def feed_icon_tag(title, url)
    (@feed_icons ||= []) << { :url => url, :title => title }
    link_to image_tag('feed.png', :size => '14x14', :alt => :subscribe_to.l+" #{title}", :plugin => 'community_engine'), url
  end

  def search_posts_title
    returning(params[:q].blank? ? :recent_posts.l : :searching_for.l+" '#{h params[:q]}'") do |title|
      title << " by #{h User.find(params[:user_id]).display_name}" if params[:user_id]
      title << " in #{h Forum.find(params[:forum_id]).name}"       if params[:forum_id]
    end
  end

  def search_user_posts_path(rss = false)
    options = params[:q].blank? ? {} : {:q => params[:q]}
    prefix = rss ? 'formatted_' : ''
    options[:format] = 'rss' if rss
    [[:user, :user_id], [:forum, :forum_id]].each do |(route_key, param_key)|
      return send("#{prefix}#{route_key}_sb_posts_path", options.update(param_key => params[param_key])) if params[param_key]
    end
    options[:q] ? search_all_sb_posts_path(options) : send("all_#{prefix}sb_posts_path", options)
  end

  def distance_of_time_in_words(from_time, to_time = 0, include_seconds = false)
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_minutes = (((to_time - from_time).abs)/60).round
  
    case distance_in_minutes
      when 0..1           then (distance_in_minutes==0) ? :a_few_seconds_ago.l : :one_minute_ago.l
      when 2..59          then "#{distance_in_minutes} "+:minutes_ago.l
      when 60..90         then :one_hour_ago.l
      when 90..1440       then "#{(distance_in_minutes.to_f / 60.0).round} "+:hours_ago.l
      when 1440..2160     then :one_day_ago.l # 1 day to 1.5 days
      when 2160..2880     then "#{(distance_in_minutes.to_f / 1440.0).round} "+:days_ago.l # 1.5 days to 2 days
      else from_time.strftime("%b %e, %Y  %l:%M%p").gsub(/([AP]M)/) { |x| x.downcase }
    end
  end

  def time_ago_in_words_or_date(date)
    if date.to_date.eql?(Time.now.to_date)
      display = I18n.l(date.to_time, :format => :time_ago)
    elsif date.to_date.eql?(Time.now.to_date - 1)
      display = :yesterday.l
    else
      display = I18n.l(date.to_date, :format => :date_ago)
    end
  end
  
  def profile_completeness(user)
    segments = [
      {:val => 2, :action => link_to('Add a profile photo', edit_user_path(user, :anchor => 'profile_details')), :test => !user.avatar.nil? },
      {:val => 1, :action => link_to('Fill in your about me', edit_user_path(user, :anchor => 'user_description')), :test => !user.description.blank?},      
      {:val => 2, :action => link_to('Select your city', edit_user_path(user, :anchor => 'location_chooser')), :test => !user.metro_area.nil? },            
      {:val => 1, :action => link_to('Tag yourself', edit_user_path(user, :anchor => "user_tags")), :test => user.tags.any?},                  
      {:val => 1, :action => link_to('Invite some friends', new_invitation_path), :test => user.invitations.any?}
    ]
    
    completed_score = segments.select{|s| s[:test].eql?(true)}.sum{|s| s[:val]}
    incomplete = segments.select{|s| !s[:test] }
    
    total = segments.sum{|s| s[:val] }
    score = (completed_score.to_f/total.to_f)*100

    {:score => score, :incomplete => incomplete, :total => total}
  end
  

  def possesive(user)
    user.gender ? (user.male? ? :his.l : :her.l)  : :their.l    
  end
  
  def help_tooltip(unique_identifier)
        
    tooltip = Tooltip.find_or_create_by_identifier(unique_identifier)
    
    code = '<div id="' + unique_identifier + '" class="help_tooltip"><span>Help</span></div>'
    
    code += <<-EOF
    <script type='text/javascript'>
    //<![CDATA[
      
      
    document.observe('dom:loaded', function() {
      
      new Tip('#{unique_identifier}', '#{ escape_javascript( render(:partial=>'tooltips/tooltip', :locals=>{:tooltip=>tooltip} )) }', {
        
        title : 'Help',
        className: 'darktip',
        showOn: 'click',
        hideOn: { element: '.close', event: 'click'},
        closeButton: true,
        hook: { target: 'topMiddle', tip: 'bottomRight' },
        offset: { x: 0, y: -5 }
      });
    
    });
    //]]>
    </script>
    EOF
    
    content_for :scripts do
      code
    end
  end
  
  def hint(unique_identifier)
        
    tooltip = Tooltip.find_or_create_by_identifier(unique_identifier)
    
    render :partial => 'tooltips/hint', :object => tooltip
  end
  
  def is_html(text)
    unless text.blank?
      if text.index('<') #might be html
        tokenizer = HTML::Tokenizer.new(text)

        while token = tokenizer.next
          node = HTML::Node.parse(nil, 0, 0, token, false)
          # if any nodes are not text, then it must be HTML
          return true if node.class != HTML::Text
        end
      end
    end
    false
  end


  def slightly_less_simple_format(text, html_options={})
    text
  end


  def clean(text)
    
    if is_html(text)
      auto_link(slightly_less_simple_format(text))
    else
      auto_link(RedCloth.new(text).to_html)
    end
  end
  

end
