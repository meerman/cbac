require 'rbconfig'

class CbacGenerator < Rails::Generators::Base
  include Rails::Generators::Migration

  def self.source_root
    @source_root ||= File.join(File.dirname(__FILE__), 'copy_files')
  end

  # Implement the required interface for Rails::Generators::Migration.
  # taken from http://github.com/rails/rails/blob/master/activerecord/lib/generators/active_record.rb
  def self.next_migration_number(dirname)
    if ActiveRecord::Base.timestamped_migrations
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    else
      "%.3d" % (current_migration_number(dirname) + 1)
    end
  end
   
  def manifest
    puts Dir.getwd

    # developer files
    empty_directory "config/cbac"
    copy_file "config/privileges.rb", "config/cbac/privileges.rb", :collision => :skip
    copy_file "config/context_roles.rb", "config/cbac/context_roles.rb", :collision => :skip

    # deployment file
    copy_file "config/cbac.pristine", "config/cbac/cbac.pristine", :collision => :skip

    # administration pages
    empty_directory "app/controllers/cbac"
    copy_file "controllers/permissions_controller.rb", "app/controllers/cbac/permissions_controller.rb"
    copy_file "controllers/generic_roles_controller.rb", "app/controllers/cbac/generic_roles_controller.rb"
    copy_file "controllers/memberships_controller.rb", "app/controllers/cbac/memberships_controller.rb"
    copy_file "controllers/upgrade_controller.rb", "app/controllers/cbac/upgrade_controller.rb"
    empty_directory "app/views/layouts"
    copy_file "views/layouts/cbac.html.erb", "app/views/layouts/cbac.html.erb"
    empty_directory "app/views/cbac"
    empty_directory "app/views/cbac/permissions"
    empty_directory "app/views/cbac/generic_roles"
    empty_directory "app/views/cbac/memberships"
    empty_directory "app/views/cbac/upgrade"
    copy_file "views/permissions/index.html.erb", "app/views/cbac/permissions/index.html.erb"
    copy_file "views/permissions/_update_context_role.html.erb", "app/views/cbac/permissions/_update_context_role.html.erb"
    copy_file "views/permissions/_update_generic_role.html.erb", "app/views/cbac/permissions/_update_generic_role.html.erb"
    copy_file "views/generic_roles/index.html.erb", "app/views/cbac/generic_roles/index.html.erb"
    copy_file "views/memberships/index.html.erb", "app/views/cbac/memberships/index.html.erb"
    copy_file "views/memberships/_update.html.erb", "app/views/cbac/memberships/_update.html.erb"
    copy_file "views/upgrade/index.html.erb", "app/views/cbac/upgrade/index.html.erb"
    empty_directory "public/stylesheets"
    copy_file "stylesheets/cbac.css", "public/stylesheets/cbac.css"

    # migrations
    #puts "type of m: " + class.name
    if self.class.migration_exists?("#{::Rails.root.to_s}/db/migrate", "create_cbac")
      # This is an upgrade from a previous version of CBAC
      migration_template "migrate/create_cbac_upgrade_path.rb", "db/migrate/create_cbac_upgrade_path" unless self.class.migration_exists?("#{::Rails.root.to_s}/db/migrate", "create_cbac_upgrade_path")
    else
      # This is the first install of CBAC into the current project
      migration_template "migrate/create_cbac_from_scratch.rb", "db/migrate/create_cbac_from_scratch" unless self.class.migration_exists?("#{::Rails.root.to_s}/db/migrate", "create_cbac_from_scratch")
    end
    # default fixtures
    copy_file "fixtures/cbac_permissions.yml", "test/fixtures/cbac_permissions.yml"
    copy_file "fixtures/cbac_generic_roles.yml", "test/fixtures/cbac_generic_roles.yml"
    copy_file "fixtures/cbac_memberships.yml", "test/fixtures/cbac_memberships.yml"

    # initializer
    copy_file "initializers/cbac_config.rb", "config/initializers/cbac_config.rb"

    # Rake task
    empty_directory "lib/tasks"
    copy_file "tasks/cbac.rake", "lib/tasks/cbac.rake"
  end
end
