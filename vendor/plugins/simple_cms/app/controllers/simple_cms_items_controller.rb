class SimpleCmsItemsController < BaseController
  # For Rails version >= 2.1
  # uncomment self.append_view_path File.join(File.dirname(__FILE__), '..', 'app', 'views')
  # in lib/simple_cms.rb file
  # For Rails version >= 2.0 and < 2.1
	#self.view_paths << File.join(File.dirname(__FILE__), '..', 'views')
  # For Rails versions < 2.0
	#self.template_root = File.join(File.dirname(__FILE__), '..', 'views')
  
  skip_before_filter :verify_authenticity_token
  #before_filter :authenticate
  #require 'coderay'
  #layout 'plugin'
  
  before_filter :set_page_title
  
  def set_page_title
    @page_title = "CMS"
  end
  
  def show
    @simple_cms_item = SimpleCmsItem.find(params[:id])
        
    render :layout => false
           
    
  end  
  
	def edit
		@simple_cms_item = SimpleCmsItem.find(params[:id])
    referer = session[:cms_data][@simple_cms_item.params][:referer]
    #logger.error("\nsession data: " + session[:cms_data].inspect + "\n\n")
    #logger.error("\ncms_referer: " + referer.to_s + "\n\n")
    # if no referer, then redirect to base root of application
    # the user jumped to edit without going through the interface
    # this is a no no for many reasons
    #if referer.nil?
      # derive base root path
      #path = request.env["REQUEST_PATH"].gsub(/simple_cms_items.*$/, "")
      #redirect_to path
      #return
    #end
    
    @versions = @simple_cms_item.versions
    #@prefix = session[:cms_data][@simple_cms_item.params][:prefix]

    # if user is not an admin, redirect to the refering page
    #if !session[:cms_data][@simple_cms_item.params][:admin]
    #  redirect_to referer
		#	return
		#els
		
		if request.post?
      if params[:commit] == "Cancel"
        redirect_to :back
        return
      end
      if !(@simple_cms_item.data.to_s == params[:simple_cms_item][:data].to_s)
        @simple_cms_item.updated_by = current_user
        @simple_cms_item.update_attributes(params[:simple_cms_item])
      else
        logger.error("\nUser did not make any changes\n")
      end
      redirect_to referer
      return
		end
	end

  def show_revision
    @simple_cms_item = SimpleCmsItem.find(params[:id].to_i)
    @cms_item_version = @simple_cms_item.versions.find_by_version(params[:version].to_i)
    respond_to do |format|
      format.js
    end
  end

  def use_revision
    @simple_cms_item = SimpleCmsItem.find(params[:id])
    @simple_cms_item.revert_to!(params[:version].to_i)
    redirect_to session["cms_referer"]
  end

  def insert_revision
    @simple_cms_item = SimpleCmsItem.find(params[:id].to_i)
    @cms_item_version = @simple_cms_item.versions.find_by_version(params[:version].to_i)
    @simple_cms_item.revert_to!(@cms_item_version.version)
    @versions = @simple_cms_item.versions
  end

end
