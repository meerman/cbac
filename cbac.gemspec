# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "cbac"
  s.version = "0.6.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Bert Meerman"]
  s.date = "2013-01-09"
  s.description = "Simple authorization system for Rails applications. Allows you to develop applications with a mixed role based authorization and a context based authorization model. Does not supply authentication."
  s.email = "bertm@rubyforge.org"
  s.extra_rdoc_files = ["README.rdoc", "lib/cbac.rb", "lib/cbac/cbac_pristine/pristine.rb", "lib/cbac/cbac_pristine/pristine_file.rb", "lib/cbac/cbac_pristine/pristine_permission.rb", "lib/cbac/cbac_pristine/pristine_role.rb", "lib/cbac/config.rb", "lib/cbac/context_role.rb", "lib/cbac/generic_role.rb", "lib/cbac/known_permission.rb", "lib/cbac/membership.rb", "lib/cbac/permission.rb", "lib/cbac/privilege.rb", "lib/cbac/privilege_new_api.rb", "lib/cbac/privilege_set.rb", "lib/cbac/privilege_set_record.rb", "lib/cbac/setup.rb", "lib/cbac/version.rb", "lib/generators/cbac/USAGE", "lib/generators/cbac/cbac_generator.rb", "lib/generators/cbac/copy_files/config/cbac.pristine", "lib/generators/cbac/copy_files/config/context_roles.rb", "lib/generators/cbac/copy_files/config/privileges.rb", "lib/generators/cbac/copy_files/controllers/generic_roles_controller.rb", "lib/generators/cbac/copy_files/controllers/memberships_controller.rb", "lib/generators/cbac/copy_files/controllers/permissions_controller.rb", "lib/generators/cbac/copy_files/controllers/upgrade_controller.rb", "lib/generators/cbac/copy_files/fixtures/cbac_generic_roles.yml", "lib/generators/cbac/copy_files/fixtures/cbac_memberships.yml", "lib/generators/cbac/copy_files/fixtures/cbac_permissions.yml", "lib/generators/cbac/copy_files/initializers/cbac_config.rb", "lib/generators/cbac/copy_files/migrate/create_cbac_from_scratch.rb", "lib/generators/cbac/copy_files/stylesheets/cbac.css", "lib/generators/cbac/copy_files/tasks/cbac.rake", "lib/generators/cbac/copy_files/views/generic_roles/index.html.erb", "lib/generators/cbac/copy_files/views/layouts/cbac.html.erb", "lib/generators/cbac/copy_files/views/memberships/_update.html.erb", "lib/generators/cbac/copy_files/views/memberships/index.html.erb", "lib/generators/cbac/copy_files/views/permissions/_update_context_role.html.erb", "lib/generators/cbac/copy_files/views/permissions/_update_generic_role.html.erb", "lib/generators/cbac/copy_files/views/permissions/index.html.erb", "lib/generators/cbac/copy_files/views/upgrade/index.html.erb", "tasks/cbac.rake"]
  s.files = ["Gemfile", "Gemfile.lock", "README.rdoc", "Rakefile", "cbac.gemspec", "config/cbac/context_roles.rb", "config/cbac/privileges.rb", "context_roles.rb", "init.rb", "lib/cbac.rb", "lib/cbac/cbac_pristine/pristine.rb", "lib/cbac/cbac_pristine/pristine_file.rb", "lib/cbac/cbac_pristine/pristine_permission.rb", "lib/cbac/cbac_pristine/pristine_role.rb", "lib/cbac/config.rb", "lib/cbac/context_role.rb", "lib/cbac/generic_role.rb", "lib/cbac/known_permission.rb", "lib/cbac/membership.rb", "lib/cbac/permission.rb", "lib/cbac/privilege.rb", "lib/cbac/privilege_new_api.rb", "lib/cbac/privilege_set.rb", "lib/cbac/privilege_set_record.rb", "lib/cbac/setup.rb", "lib/cbac/version.rb", "lib/generators/cbac/USAGE", "lib/generators/cbac/cbac_generator.rb", "lib/generators/cbac/copy_files/config/cbac.pristine", "lib/generators/cbac/copy_files/config/context_roles.rb", "lib/generators/cbac/copy_files/config/privileges.rb", "lib/generators/cbac/copy_files/controllers/generic_roles_controller.rb", "lib/generators/cbac/copy_files/controllers/memberships_controller.rb", "lib/generators/cbac/copy_files/controllers/permissions_controller.rb", "lib/generators/cbac/copy_files/controllers/upgrade_controller.rb", "lib/generators/cbac/copy_files/fixtures/cbac_generic_roles.yml", "lib/generators/cbac/copy_files/fixtures/cbac_memberships.yml", "lib/generators/cbac/copy_files/fixtures/cbac_permissions.yml", "lib/generators/cbac/copy_files/initializers/cbac_config.rb", "lib/generators/cbac/copy_files/migrate/create_cbac_from_scratch.rb", "lib/generators/cbac/copy_files/stylesheets/cbac.css", "lib/generators/cbac/copy_files/tasks/cbac.rake", "lib/generators/cbac/copy_files/views/generic_roles/index.html.erb", "lib/generators/cbac/copy_files/views/layouts/cbac.html.erb", "lib/generators/cbac/copy_files/views/memberships/_update.html.erb", "lib/generators/cbac/copy_files/views/memberships/index.html.erb", "lib/generators/cbac/copy_files/views/permissions/_update_context_role.html.erb", "lib/generators/cbac/copy_files/views/permissions/_update_generic_role.html.erb", "lib/generators/cbac/copy_files/views/permissions/index.html.erb", "lib/generators/cbac/copy_files/views/upgrade/index.html.erb", "migrations/20110211105533_add_pristine_files_to_cbac_upgrade_path.rb", "privileges.rb", "rails/init.rb", "spec/cbac_authorization_check_spec.rb", "spec/cbac_pristine_file_spec.rb", "spec/cbac_pristine_permission_spec.rb", "spec/cbac_pristine_role_spec.rb", "spec/fixtures/controllers/dating/daughter_controller.rb", "spec/rcov.opts", "spec/spec.opts", "spec/spec_helper.rb", "spec/support/schema.rb", "tasks/cbac.rake", "test/fixtures/cbac_generic_roles.yml", "test/fixtures/cbac_memberships.yml", "test/fixtures/cbac_permissions.yml", "test/fixtures/cbac_privilege_set.yml", "test/test_cbac_actions.rb", "test/test_cbac_authorize_generic_roles.rb", "test/test_cbac_context_role.rb", "test/test_cbac_privilege.rb", "test/test_cbac_privilege_set.rb", "test/test_helper.rb", "Manifest"]
  s.homepage = "http://cbac.rubyforge.org"
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Cbac", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "cbac"
  s.rubygems_version = "1.8.24"
  s.summary = "CBAC - Simple authorization system for Rails applications."
  s.test_files = ["test/test_cbac_privilege.rb", "test/test_cbac_context_role.rb", "test/test_helper.rb", "test/test_cbac_actions.rb", "test/test_cbac_privilege_set.rb", "test/test_cbac_authorize_generic_roles.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_dependency("rails", ">= 3.0")
      s.add_development_dependency("rspec-rails")
      s.add_development_dependency("sqlite3")
      s.add_development_dependency("database_cleaner")
    else
    end
  else
  end
end
