ENV["RAILS_ENV"] ||= 'test'

require 'spec/autorun'
require 'spec/rails'

Spec::Runner.configure do |config|
   # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
end