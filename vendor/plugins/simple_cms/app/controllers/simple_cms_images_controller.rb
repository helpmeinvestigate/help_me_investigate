class SimpleCmsImagesController < BaseController
  # For Rails version >= 2.1
  # uncomment self.append_view_path File.join(File.dirname(__FILE__), '..', 'app', 'views')
  # in lib/simple_cms.rb file
  # For Rails version >= 2.0 and < 2.1
	#self.view_paths << File.join(File.dirname(__FILE__), '..', 'views')
  # For Rails versions < 2.0
	#self.template_root = File.join(File.dirname(__FILE__), '..', 'views')
  
  skip_before_filter :verify_authenticity_token

  def index
    @images = SimpleCmsImage.find_all_by_thumbnail(nil)
    @thumb_images = SimpleCmsImage.find_all_by_thumbnail('thumb')
    logger.error("\nimages: " + @images.to_s)
    logger.error("\nthumb_images: " + @thumb_images.to_s + "\n\n")
    respond_to do |format|
      format.js   #index.rjs
    end
  end

  def create
    duplicate = false;
    images = SimpleCmsImage.find_all_by_thumbnail(nil)
    @image  = SimpleCmsImage.new(params[:image])
    respond_to do |format|
      images.each do |image|
        if(image.filename == @image.filename)
          duplicate = true
        end
      end
      # logger.error("\nimage: " + @image.inspect.to_s + "\n\n")
      if @image.save && !(duplicate == true)
        format.js do
          responds_to_parent do
            render :update do |page|
              page << "ts_insert_image('#{@image.public_filename()}',
                                       '#{@image.filename()}');"
            end
          end
        end
      else
        format.js do
          responds_to_parent do
            render :update do |page|
              if duplicate
                page.alert("An image with that filename has already been uploaded. Please look at the Uploaded images for your desired image or change the filename of the image you are trying to upload.")
                @image.destroy
              else
                page.alert('Sorry, error uploading images')
              end
            end
          end
        end
      end
    end
  end

  def destroy
    @image = SimpleCmsImage.find(params[:id])
    @image.destroy

    render :update do |page|
      page["image_#{params[:id]}"].remove
    end
  end
end
