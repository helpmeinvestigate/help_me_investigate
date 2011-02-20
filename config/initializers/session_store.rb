# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_hmi_session',
  :secret      => '5e8f15bc29801c0245f88b8d7b5626db2e92cbb8a8329577e695bbb725d04697a8901097e50caf098c87c5d600bf9770b4877cefccc66916b498b74b7cdd35fd'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
