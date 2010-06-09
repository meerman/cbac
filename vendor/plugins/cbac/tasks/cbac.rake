# This rakefile contains the rake tasks for CBAC
#
# CBAC is context based access control. It enables an application to
#
#
# cbac:setup
# cbac:check
#
# 2009-11-27  Bert Meerman        First version
#
namespace :cbac do
  namespace :check do
    desc "Checks all the available controller methods for missing privileges"
    task :mapping do
      load_controller_methods
      puts "lala"
    end
  end
end
