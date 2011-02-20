class SimpleCmsMigrationsGenerator < Rails::Generator::Base
	def manifest
		record do |m|
      @migration_directory = "#{RAILS_ROOT}/db/migrate"
      %w{create_simple_cms_items 
         create_simple_cms_images
         create_simple_cms_medias
         change_items_data_column
         }.each do |x|
           if migration_exists?("#{x}").empty?
		         m.migration_template "#{x}.rb", "db/migrate", 
                                  :migration_file_name => x, 
                                  :assigns => {:class_name => x.camelize}
           else
             puts "#{x} migration already exists ... skipping." 
           end
      end
    end
	end

  def migration_exists?(file_name)
    Dir.glob("#{@migration_directory}/[0-9]*_*.rb").grep(/[0-9]+_#{file_name}.rb$/)
  end
end
