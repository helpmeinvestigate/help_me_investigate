# Include hook code here
#require 'application'
require 'simple_cms'

ActionView::Base.send :include, SimpleCmsMod::Render

ApplicationController.send :include, SimpleCmsMod::ViewPaths

model_path      = File.join(directory, 'app', 'models')
$LOAD_PATH << model_path

# Use Dependencies.load_paths for any version <= 2.1.0
# Use ActiveSupport::Dependencies.load_paths for any version >= 2.1.1
# If you are using a version <= 2.1.0 and it is not in the list then add it
if %w(1.2.0 1.2.1 1.2.3 1.2.4 1.2.5 1.2.6 2.0.0 2.0.1 2.0.2 2.1.0).include?(RAILS_GEM_VERSION)
  Dependencies.load_paths << model_path
else
  ActiveSupport::Dependencies.load_paths << model_path
end

controller_path = File.join(directory, 'app', 'controllers')
$LOAD_PATH << controller_path

# Use Dependencies.load_paths for any version <= 2.1.0
# Use ActiveSupport::Dependencies.load_paths for any version >= 2.1.1
# If you are using a version <= 2.1.0 and it is not in the list then add it
if %w(1.2.0 1.2.1 1.2.3 1.2.4 1.2.5 1.2.6 2.0.0 2.0.1 2.0.2 2.1.0).include?(RAILS_GEM_VERSION)
  Dependencies.load_paths << controller_path
else
  ActiveSupport::Dependencies.load_paths << controller_path
end
config.controller_paths << controller_path
