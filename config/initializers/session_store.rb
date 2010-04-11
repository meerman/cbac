# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_CBAC_session',
  :secret      => '49a98f304d1fc6955e60d4c33551991a0c716e94e3306de95c8cd0236b2041d36517d7cc365d8a22b00c4c33e3a060e324532fdf71aa48a5e2912bf6e47641f4'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
