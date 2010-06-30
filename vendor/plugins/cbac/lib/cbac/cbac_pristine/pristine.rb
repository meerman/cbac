require File.expand_path(File.join(File.dirname(__FILE__), 'pristine_file'))

module Cbac
  module CbacPristine
    #creates a yml file containing all generic roles from the specified pristine file objects
    def create_generic_role_fixtures_file(pristine_files, fixtures_file_name)
      roles = []

      pristine_files.each do |pristine_file|
        #if the pristine file wasn't parsed yet, we'll do it here
        pristine_file.parse(false) if pristine_file.lines.empty?
        pristine_file.generic_roles.each do |generic_role|
          # we only want the unique generic roles, because the yml file cannot have duplicates
          has_role = false
          roles.each do |role|
            if role.name == generic_role.name
              has_role = true
            end
          end
          roles.push(generic_role) unless has_role
        end
      end
      create_fixtures_file(roles, fixtures_file_name)
    end

    # creates a yml file containing all cbac_permissions from the specified pristine file objects
    def create_permissions_fixtures_file(pristine_files, fixtures_file_name)
      permissions = []

      pristine_files.each do |pristine_file|
        pristine_file.parse(false) if pristine_file.permissions.empty?
        pristine_file.permission_set.each do |line|
          permissions.push(line)
        end
      end
      create_fixtures_file(permissions, fixtures_file_name)
    end

    # turns the fixtures into yml and writes them to a file with specified name.
    def create_fixtures_file(fixtures, fixtures_file_name)
      File.delete(fixtures_file_name) if File.exists?(fixtures_file_name)
      f = File.new(fixtures_file_name, "w")
      flock(f, File::LOCK_EX) do |f|
        fixtures.each_with_index do |fixture, index|
          f.write(fixture.to_yml_fixture(index + 1))
        end
      end
    end

    # set all cbac permissions and generic roles to the state in the specified pristine file objects
    def set_pristine_state(pristine_files, clear_tables)
      clear_cbac_tables if clear_tables
      pristine_files.each do |pristine_file|
        pristine_file.parse if pristine_file.permissions.empty?
        pristine_file.permissions.each do |permission|
          permission.accept
        end
      end
    end

    # stage all unknown cbac_permissions
    def stage_permissions(pristine_files)

      pristine_files.each do |pristine_file|
        pristine_file.parse(true) if pristine_file.permissions.empty?
        pristine_file.permissions.each do |permission|
          permission.stage
        end
      end
    end

    def clear_cbac_tables
      Cbac::GenericRole.delete_all
      Cbac::Membership.delete_all
      Cbac::Permission.delete_all
      Cbac::KnownPermission.delete_all
      Cbac::CbacPristine::PristinePermission.delete_all
      Cbac::CbacPristine::PristineRole.delete_all
    end

    def drop_generic_known_permissions
      known_permissions = Cbac::KnownPermission.find(:all, :conditions => {:permission_type => Cbac::KnownPermission.PERMISSION_TYPES[:generic]})
      known_permissions.each { |p| p.destroy }
    end

    def drop_generic_permissions
      permissions = Cbac::Permission.find(:all, :conditions => {:context_role => nil})
      (permissions.select { |perm| perm.generic_role.name != "administrators" }).each { |p| p.destroy }
    end

    def database_contains_cbac_data?
      return (Cbac::GenericRole.count != 0 or Cbac::Membership.count != 0 or Cbac::Permission.count != 0 or Cbac::KnownPermission.count != 0 or Cbac::CbacPristine::PristinePermission.count != 0 or Cbac::CbacPristine::PristineRole.count != 0)
    end

    def flock(file, mode)
      success = file.flock(mode)
      if success
        begin
          yield file
        ensure
          file.flock(File::LOCK_UN)
        end
      end
      return success
    end

  end
end