require 'rbconfig'

class CbacGenerator < Rails::Generator::Base
  def initialize(runtime_args, runtime_options = {})
    super
    #puts runtime_args
    #raise "silently quiting"
  end

  def manifest
    record do |m|
      # developer files
      m.directory "config/cbac"
      m.file "config/privileges.rb", "config/cbac/privileges.rb", :collision => :skip
      m.file "config/context_roles.rb", "config/cbac/context_roles.rb", :collision => :skip
			
			# deployment file
			m.file "config/cbac.pristine", "config/cbac/cbac.pristine", :collision => :skip

      # administration pages
      m.directory "app/controllers/cbac"
      m.file "controllers/permissions_controller.rb", "app/controllers/cbac/permissions_controller.rb"
      m.file "controllers/generic_roles_controller.rb", "app/controllers/cbac/generic_roles_controller.rb"
      m.file "controllers/memberships_controller.rb", "app/controllers/cbac/memberships_controller.rb"
      m.directory "app/views/layouts"
      m.file "views/layouts/cbac.html.erb", "app/views/layouts/cbac.html.erb"
      m.directory "app/views/cbac"
      m.directory "app/views/cbac/permissions"
      m.directory "app/views/cbac/generic_roles"
      m.directory "app/views/cbac/memberships"
      m.file "views/permissions/index.html.erb", "app/views/cbac/permissions/index.html.erb"
      m.file "views/permissions/_update_context_role.html.erb", "app/views/cbac/permissions/_update_context_role.html.erb"
      m.file "views/permissions/_update_generic_role.html.erb", "app/views/cbac/permissions/_update_generic_role.html.erb"
      m.file "views/generic_roles/index.html.erb", "app/views/cbac/generic_roles/index.html.erb"
      m.file "views/memberships/index.html.erb", "app/views/cbac/memberships/index.html.erb"
      m.file "views/memberships/_update.html.erb", "app/views/cbac/memberships/_update.html.erb"
      m.directory "public/stylesheets"
      m.file "stylesheets/cbac.css", "public/stylesheets/cbac.css"

      # migrations
      m.migration_template "migrate/create_cbac.rb", "db/migrate", {:migration_file_name => "create_cbac"}
      m.migration_template "migrate/create_cbac_known_permissions.rb", "db/migrate", {:migration_file_name => "create_cbac_known_permissions"}
			m.migration_template "migrate/create_cbac_staged_change.rb", "db/migrate", {:migration_file_name => "create_cbac_staged_change"}
      # default fixtures
      m.file "fixtures/cbac_permissions.yml", "test/fixtures/cbac_permissions.yml"
      m.file "fixtures/cbac_generic_roles.yml", "test/fixtures/cbac_generic_roles.yml"
      m.file "fixtures/cbac_memberships.yml", "test/fixtures/cbac_memberships.yml"
    end
  end  
end
