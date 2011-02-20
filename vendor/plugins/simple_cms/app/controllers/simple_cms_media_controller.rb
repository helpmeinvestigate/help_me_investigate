class SimpleCmsMediaController < BaseController
  # For Rails version >= 2.1
  # uncomment self.append_view_path File.join(File.dirname(__FILE__), '..', 'app', 'views')
  # in lib/simple_cms.rb file
  # For Rails version >= 2.0 and < 2.1
	#self.view_paths << File.join(File.dirname(__FILE__), '..', 'views')
  # For Rails versions < 2.0
	#self.template_root = File.join(File.dirname(__FILE__), '..', 'views')
  
  skip_before_filter :verify_authenticity_token

  def index
    @media = SimpleCmsMedia.find(:all)
    respond_to do |format|
      format.js   #index.rjs
    end
  end

  def create
    logger.error("\nYou are in the create method\n\n")
    duplicate = false
    medias = SimpleCmsMedia.find(:all)
    @media  = SimpleCmsMedia.new(params[:media])
    medias.each do |media|
      if(@media.filename == media.filename)
        logger.error("\nWe have found a duplicate\n\n")
        duplicate = true
      end
    end
    respond_to do |format|
      logger.error("\n" + @media.inspect.to_s + "\n")
      if @media.save && duplicate == false
        format.js do
          responds_to_parent do
            render :update do |page|
              #page.alert("We are now inserting the uploaded media")
              if medias.size < 1
                #page.alert("Inserting first media")
                page.replace_html :dynamic_media_list,
                                  :partial => 'media_item',
                                  :object  => @media
              else
                page.insert_html :bottom, :uploaded_media_item, 
                                 :partial => 'media_item',
                                 :object  => @media
              end
              page << "insert_uploaded_url('#{@media.public_filename()}')"
            end
          end
        end
      else
        format.js do
          responds_to_parent do
            render :update do |page|
              if duplicate == true
                page.alert("Sorry the media with the same filename already exists. Please look in the available media for the media you are trying to upload or change the filename and try again.")
                @media.destroy
              else
                page.alert('Sorry, error uploading media')
                page.alert(@media.errors.inspect.to_s)
                logger.error("\nError uploading media:\n" + @media.errors.inspect.to_s + "\n")
              end
            end
          end
        end
      end
    end
  end

  def destroy
    @media = SimpleCmsMedia.find(params[:id])
    @media.destroy

    respond_to do |format|
      # format.html { redirect_to my_image_url }
      format.xml { head :ok }
    end
  end
end
