module SimpleCmsMod
  module Render
    def self.included(base)
      base.extend(ActionView)
      base.class_eval do
        def render_with_simple_cms(options = {}, local_assigns = {}, &block)
          if options.is_a?(Hash) && options[:simpleCMS]
            render_simple_cms(options, local_assigns, &block)
          else
            render_without_simple_cms(options, local_assigns, &block)
          end
        end
        alias_method_chain :render, :simple_cms
        
        def render_simple_cms(options = {}, local_assigns = {}, &block)
          logger.error "WE ARE RENDERING SIMPLE CMS"
          @label      = (options[:simpleCMS].blank?)? "defaultLabel" : options[:simpleCMS]
          @domain     = request.env["HTTP_X_FORWARDED_HOST"] if request.env["HTTP_X_FORWARDED_HOST"]
          @reusable   = options[:reusable] || false
          if @reusable
            @cms_params = {:label => @label, :domain => @domain}.
                          sort{|a,b| a.to_s <=> b.to_s}.
                          to_yaml.gsub(/\r/,"").gsub(/\.html/,"")
          else
            @cms_params = params.
                          merge(:label => @label, :domain => @domain).
                          sort{|a,b| a.to_s <=> b.to_s}.
                          to_yaml.gsub(/\r/,"").gsub(/\.html/,"")
          end
          logger.error "CMS PARAMS: #{@cms_params}"
          @cms_admin  = options[:admin]  || false
          @cms_user   = options[:user]   || "N/A"
          @prefix     = options[:prefix] || "" 

          session[:cms_data]                      ||= {}
          session[:cms_data][@cms_params]         ||= {}
          session[:cms_data][@cms_params][:admin]   = @cms_admin
          session[:cms_data][@cms_params][:user]    = @cms_user
          session[:cms_data][@cms_params][:prefix]  = @prefix

          request_path = request.env["REQUEST_PATH"]
          request_path = request.env["REQUEST_URI"] if request_path.blank?
          request_path = request.env["SCRIPT_NAME"] if request_path.blank?
          session[:cms_data][@cms_params][:referer] = request_path.nil? ? "/" : request_path.gsub(/\/sites.*skizmo.com/,"")
          logger.error "request_path: " + request_path.to_s
          logger.error("\nsession data: " + session[:cms_data].inspect + "\n\n")
          logger.error("session size: " + session[:cms_data].size.to_s + "\n\n")

          
          # link to add new data
          # display current data if any
          item = SimpleCmsItem.find_by_params(@cms_params)
          if !item
            logger.error "CREATING A NEW SIMPLE CMS"
            item = SimpleCmsItem.create(:params => @cms_params, :created_by => @cms_user, :updated_by => @cms_user)
            logger.error "CREATING A NEW SIMPLE CMS@@@@@@"
          end
          render :partial => shared_path("simple_cms_item"), 
                 :object  => item
        end

        def cms_shared_path(partial_path)
          shared_path(partial_path)
        end

      private

        # Path to CMS Files that the end user will experience
        # 1 partial for adding content
        # 1 partial for viewing/editing content
        def shared_path(partial_path)
          return "shared/#{partial_path}"
        end
        
        def parse_coderay(text)
          text.scan(/(<code_highlighting type=\"([a-z].+?)\">(.+?)<\/code_highlighting>)/m).each do |match|
            #logger.error("\ncode: " + match[2])
            match[2] = match[2].gsub("<br />", "").
                                gsub("&nbsp;", " ").
                                gsub("&lt;", "<").
                                gsub("&gt;", ">").
                                gsub("&quot;", "\"")
            match[2] = match[2] + "\n"
            #logger.error("\nnew code: " + match[2])
            text.gsub!(match[0],CodeRay.scan(match[2], match[1].to_sym).div( :line_numbers => :table, :css => :class))
          end
          return text
        end
      end
    end 
  end
end
