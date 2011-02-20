# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')
require File.join(File.dirname(__FILE__), '../vendor/plugins/engines/boot')

Rails::Initializer.run do |config|
  #resource_hacks required here to ensure routes like /:login_slug work
  config.plugins = [:engines, :community_engine, :white_list, :all]
  config.plugin_paths += ["#{RAILS_ROOT}/vendor/plugins/community_engine/engine_plugins"]

  # Settings in config/environments/* take precedence over those specified here.
   # Application configuration should go into files in config/initializers
   # -- all .rb files in that directory are automatically loaded.

   # Add additional load paths for your own custom dirs
   # config.load_paths += %W( #{RAILS_ROOT}/extras )

   # Specify gems that this application depends on and have them installed with rake gems:install
   # config.gem "bj"
   # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
   # config.gem "sqlite3-ruby", :lib => "sqlite3"
   config.gem "aws-s3", :lib => "aws/s3"
   config.gem "geokit"
   config.gem "ruby-debug"
   config.gem "shorturl"
   config.gem "RedCloth"
   #config.gem "fiveruns_manage"
   
   
   #config.gem "acts_as_paranoid"
   
   # Only load the plugins named here, in the order given (default is alphabetical).
   # :all can be used as a placeholder for all plugins not explicitly named
   # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

   # Skip frameworks you're not going to use. To use Rails without a database,
   # you must remove the Active Record framework.
   # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

   # Activate observers that should always be running
   # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

   # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
   # Run "rake -D time" for a list of tasks for finding time zone names.
   config.active_record.default_timezone = :utc

   # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
   config.i18n.load_path += Dir[Rails.root.join('vendor','plugins','community_engine', 'lang', 'ui', '*.{rb,yml}')]
   config.i18n.default_locale = :en
   
end

ExceptionNotifier.exception_recipients = %w(stef@helpmeinvestigate.com)
ExceptionNotifier.sender_address = %("Gremlin" <gremlin@helpmeinvestigate.com>)
ExceptionNotifier.email_prefix = "[HMI] "



# Include your application configuration below
require "#{RAILS_ROOT}/vendor/plugins/community_engine/engine_config/boot.rb"

require "RedCloth"