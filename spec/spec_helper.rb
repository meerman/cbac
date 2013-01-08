ENV["RAILS_ENV"] ||= 'test'

require 'bundler'
Bundler.require
require 'rails/all'
require 'rspec/rails'

require 'cbac'

require 'support/schema'
require 'database_cleaner'

DatabaseCleaner.strategy = :transaction

RSpec.configure do |config|
  config.before(:suite) do
    Cbac::Schema.load
  end

  config.after(:suite) do
    Cbac::Schema.drop
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
