# desc "Explaining what the task does"
namespace :simple_cms do
  
  PLUGIN_ROOT = File.dirname(__FILE__) + '/../'

  desc 'Installs required javascript and css files to the public/javascripts and public/stylesheets directories'
  task :install do
    FileList[PLUGIN_ROOT + '/assets/javascripts/*.js'].each do |f|
      puts "ADDING /public/javascripts/" + File.basename(f)
      FileUtils.cp f, RAILS_ROOT + '/public/javascripts'
    end
    FileList[PLUGIN_ROOT + '/assets/stylesheets/*.css'].each do |f|
      puts "ADDING /public/stylesheets/" + File.basename(f)
      FileUtils.cp f, RAILS_ROOT + '/public/stylesheets'
    end
    
    puts "COPYING tiny_mce:"
    FileUtils.cp_r Dir[PLUGIN_ROOT + '/assets/javascripts/tiny_mce'], RAILS_ROOT + '/public/javascripts'
  end
  
  desc 'Uninstalls all javascript and css files that were created by the simple_cms:install'
  task :uninstall do
    puts "REMOVING /assets/javascripts/tiny_mce:"
    FileUtils.rm_rf RAILS_ROOT + '/public/javascripts/tiny_mce'

    FileList[PLUGIN_ROOT + '/assets/javascripts/*.js'].each do |file|
      puts "REMOVING /public/javascripts/" + File.basename(file)
      FileUtils.rm RAILS_ROOT + '/public/javascripts/' + File.basename(file)
    end
    FileList[PLUGIN_ROOT + '/assets/stylesheets/*.css'].each do |file|
      puts "REMOVING /public/stylesheets/" + File.basename(file)
      FileUtils.rm RAILS_ROOT + '/public/stylesheets/' + File.basename(file)
    end
  end

  desc 'Installs simple_cms dependencies(attachment_fu, responds_to_parent, acts_as_versioned, and coderay)'
  task :install_dependencies do
    puts "Installing plugin attachment_fu..."
    puts `ruby script/plugin install http://svn.pullmonkey.com/plugins/trunk/attachment_fu`
    puts "\n\n\n\n"
    puts "Installing plugin responds_to_parent..."
    puts `ruby script/plugin install http://svn.pullmonkey.com/plugins/trunk/responds_to_parent`
    puts "\n\n\n\n"
    puts "Installing plugin acts_as_versioned..."
    puts `ruby script/plugin install http://svn.pullmonkey.com/plugins/trunk/acts_as_versioned_2.1.1`
    FileUtils.mv PLUGIN_ROOT + '../acts_as_versioned_2.1.1', PLUGIN_ROOT + '../acts_as_versioned'
    puts "\n\n\n\n"
    puts "Installing plugin coderay..."
    puts `ruby script/plugin install http://svn.pullmonkey.com/plugins/trunk/coderay`
  end
end
