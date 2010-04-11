# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{cbac}
  s.version = "0.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Bert Meerman"]
  s.date = %q{2010-02-05}
  s.description = %q{Simple authorization system for Rails applications. Allows you to develop applications with a mixed role based authorization and a context based authorization model. Does not supply authentication.}
  s.email = %q{b.meerman@ogd.nl}
  s.extra_rdoc_files = ["README.rdoc", "lib/cbac.rb", "lib/cbac/config.rb", "lib/cbac/context_role.rb", "lib/cbac/generic_role.rb", "lib/cbac/membership.rb", "lib/cbac/permission.rb", "lib/cbac/privilege.rb", "lib/cbac/privilege_set.rb", "lib/cbac/privilege_set_record.rb", "lib/cbac/setup.rb", "tasks/cbac.rake"]
  s.files = ["Manifest", "README.rdoc", "Rakefile", "cbac.gemspec", "generators/cbac/USAGE", "generators/cbac/cbac_generator.rb", "generators/cbac/templates/config/context_roles.rb", "generators/cbac/templates/config/privileges.rb", "generators/cbac/templates/controllers/generic_roles_controller.rb", "generators/cbac/templates/controllers/memberships_controller.rb", "generators/cbac/templates/controllers/permissions_controller.rb", "generators/cbac/templates/fixtures/cbac_generic_roles.yml", "generators/cbac/templates/fixtures/cbac_memberships.yml", "generators/cbac/templates/fixtures/cbac_permissions.yml", "generators/cbac/templates/migrate/create_cbac.rb", "generators/cbac/templates/stylesheets/cbac.css", "generators/cbac/templates/views/generic_roles/index.html.erb", "generators/cbac/templates/views/layouts/cbac.html.erb", "generators/cbac/templates/views/memberships/_update.html.erb", "generators/cbac/templates/views/memberships/index.html.erb", "generators/cbac/templates/views/permissions/_update_context_role.html.erb", "generators/cbac/templates/views/permissions/_update_generic_role.html.erb", "generators/cbac/templates/views/permissions/index.html.erb", "init.rb", "lib/cbac.rb", "lib/cbac/config.rb", "lib/cbac/context_role.rb", "lib/cbac/generic_role.rb", "lib/cbac/membership.rb", "lib/cbac/permission.rb", "lib/cbac/privilege.rb", "lib/cbac/privilege_set.rb", "lib/cbac/privilege_set_record.rb", "lib/cbac/setup.rb", "tasks/cbac.rake", "test/fixtures/cbac_generic_roles.yml", "test/fixtures/cbac_memberships.yml", "test/fixtures/cbac_permissions.yml", "test/fixtures/cbac_privilege_set.yml", "test/test_cbac_authorize_context_roles.rb", "test/test_cbac_authorize_generic_roles.rb", "test/test_cbac_context_role.rb", "test/test_cbac_privilege.rb", "test/test_cbac_privilege_set.rb"]
  s.homepage = %q{http://cbac.rubyforge.org}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Cbac", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{cbac}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{CBAC - Simple authorization system for Rails applications.}
  s.test_files = ["test/test_cbac_authorize_context_roles.rb", "test/test_cbac_authorize_generic_roles.rb", "test/test_cbac_context_role.rb", "test/test_cbac_privilege.rb", "test/test_cbac_privilege_set.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
