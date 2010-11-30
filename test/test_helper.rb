# Copyright 2010 Bert Meerman

# Setup ActiveRecord and ActiveSupport
ENV["RAILS_ENV"] ||=  "test"
RAILS_ENV ||= "test"
require "active_record"
require "active_record/fixtures"
require "yaml"
require "erb"
require "active_support"
ActiveRecord::Base.establish_connection(
  'adapter' => 'sqlite3',
  'database' => 'test/db/test.sqlite3'
)
fixture_files = Dir.glob(File.join(File.dirname(__FILE__), "fixtures", "*.yml"))
fixture_files.each do |filename|
  Fixtures.create_fixtures('test/fixtures', File.basename(filename, ".*"))
end
RAILS_ROOT ||=  "."

# Setup cbac configuration
require "cbac"
class ActiveSupport::TestCase
  include Cbac

  session = Hash.new
  session[:currentuser] = 1
end
