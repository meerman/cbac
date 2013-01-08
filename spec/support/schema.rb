require File.expand_path('../../../lib/generators/cbac/copy_files/migrate/create_cbac_from_scratch.rb', __FILE__)

class Cbac::Schema
  DATABASE_FILE = File.expand_path('../test.sqlite3', __FILE__)

  def self.load
    print "Loading fresh database schema..."

    connect!
    CreateCbacFromScratch.suppress_messages do
      CreateCbacFromScratch.up
    end
    connect!

    puts "done"
  end

  def self.drop
    FileUtils.rm_rf(DATABASE_FILE)
  end

private
  def self.connect!
    ActiveRecord::Base.establish_connection(
      :adapter => 'sqlite3',
      :database => Cbac::Schema::DATABASE_FILE
    )
  end

end
