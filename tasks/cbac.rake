#TODO: zip (or something) the directory resulting from a snapshot and delete it
#TODO: unzip (or something) the provided snapshot and load from it, then delete temp dir
#TODO: add staging area to extracted snapshot, inserted snapshot, clearing code, etc.

#TODO: add comments to pristine lines, in a Comment() style

# WARNING: Non-changes are not saved as known_permissions when using pristine or such. THIS IS NOT A BUG! Think of the following scenario:
# 1) Developers grant permission X
# 2) User deploys. Permission X is granted in the database.
# 3) User revokes permission X
# 4) Developers revoke permission X
# 5) User upgrades. No change in permission X detected, (since devteam and user agree) so the user is not prompted to accept the change.
# 6) User grants permission X again
# 7) User upgrades again. At this point, we want the user to be warned that the devteam thinks granting this permission is not a good idea. 
#    This is only possible if the non-change in #5 is not registered as KnownChange

# Get a privilege set that fulfills the provided conditions
  def get_privilege_set(conditions)
    Cbac::PrivilegeSetRecord.first(:conditions => conditions)
  end

# Get a Hash containing all entries from the provided table
  def select_all(table)
    ActiveRecord::Base.connection.select_all("SELECT * FROM %s;" % table)
  end

# Generate a usable filename for dumping records of the specified type
  def get_filename(type)
    "#{ENV['SNAPSHOT_NAME']}/cbac_#{type}.yml"
  end

  def load_objects_from_yaml(type)
    filename = get_filename(type)

    Yaml.load_file(filename)
  end

# Dump the specified permissions to a YAML file
  def dump_permissions_to_yaml_file(permissions)
    permissions.each do |cp|
      privilege_set_name = get_privilege_set(:id => cp['privilege_set_id']).name
      cp['privilege_set_id'] = "<%= Cbac::PrivilegeSetRecord.where(name: '#{privilege_set_name}').first.id %>"
    end
    dump_objects_to_yaml_file(permissions, "permissions")
  end

# Dump a set of objects to a YAML file. Filename is determined by type-string
  def dump_objects_to_yaml_file(objects, type)
    filename = get_filename(type)

    puts "Writing #{type} to disk"

    File.open(filename, "w") do |output_file|
      index = "0000"
      output_file.write objects.inject({}) { |hash, record|
        hash["#{type.singularize}_#{index.succ!}"] = record
        hash
      }.to_yaml
    end
  end

  def get_cbac_pristine_adapter
    adapter_class = Class.new
    adapter_class.send :include, Cbac::CbacPristine
    adapter_class.new
  end

  namespace :cbac do
    desc 'Initialize CBAC tables with bootstrap data. Allows ADMINUSER to log in and visit CBAC administration pages. Also, if a Privilege Set called "login" exists, this privilege is granted to "everyone"'
    task :bootstrap => :environment do
      adapter = get_cbac_pristine_adapter
      if adapter.database_contains_cbac_data?
        if ENV['FORCE'] == "true"
          puts "FORCE specified: emptying CBAC tables"
          adapter.clear_cbac_tables
        else
          puts "CBAC bootstrap failed: CBAC tables are nonempty. Specify FORCE=true to override this check and empty the tables"
          exit
        end
      end

      adminuser = ENV['ADMINUSER'] || 1
      login_privilege_set = get_privilege_set(:name => "login")
      everybody_context_role = ContextRole.roles[:everybody]
      if !login_privilege_set.nil? and !everybody_context_role.nil?
        puts "Login privilege exists. Allowing context role 'everybody' to use login privilege"
        login_permission = Cbac::Permission.new(:context_role => 'everybody', :privilege_set_id => login_privilege_set.id)
        throw "Failed to save Login Permission" unless login_permission.save
      end

      puts "Creating Generic Role: administrators"
      admin_role = Cbac::GenericRole.new(:name => "administrator", :remarks => "System administrators - may edit CBAC permissions")
      throw "Failed to save new Generic Role" unless admin_role.save

      puts "Creating Administrator Membership for user #{adminuser}"
      membership = Cbac::Membership.new(:user_id => adminuser, :generic_role_id => admin_role.id)
      throw "Failed to save new Administrator Membership" unless membership.save

      begin
        admin_privilege_set_id = get_privilege_set({:name => 'cbac_administration'}).id
      rescue
        throw "No PrivilegeSet cbac_administration defined. Aborting."
      end
      cbac_admin_permission = Cbac::Permission.new(:generic_role_id => admin_role.id, :privilege_set_id => admin_privilege_set_id)
      throw "Failed to save Cbac_Administration Permission" unless cbac_admin_permission.save

      puts <<EOF
**********************************************************
* Succesfully bootstrapped CBAC. The specified user (# #{adminuser} ) *
* may now visit the cbac administration pages, which are *
* located at the URL /cbac/permissions/index by default  *
**********************************************************
EOF
    end

    desc 'Extract a snapshot of the current authorization settings, which can later be restored using the restore_snapshot task. Parameter SNAPSHOT_NAME determines where the snapshot is stored'
    task :extract_snapshot => :environment do
      if ENV['SNAPSHOT_NAME'].nil?
        puts "Missing argument SNAPSHOT_NAME. Substituting timestamp for SNAPSHOT_NAME"
        require 'date'
        ENV['SNAPSHOT_NAME'] = DateTime.now.strftime("%Y%m%d%H%M%S")
      end

      if File::exists?(ENV['SNAPSHOT_NAME']) # Directory already exists!
        if ENV['FORCE'] == "true"
          puts "FORCE specified - overwriting older snapshot with same name."
        else
          puts "A snapshot with the given name (#{ENV['SNAPSHOT_NAME']}) already exists, and overwriting is dangerous. Specify FORCE=true to override this check"
          exit
        end
      else # Directory does not exist yet
        FileUtils.mkdir(ENV['SNAPSHOT_NAME'])
      end

      puts "Extracting CBAC permissions to #{ENV['SNAPSHOT_NAME']}"

      # Don't need privilege sets since they are loaded from a config file.
      staged_changes = select_all "cbac_staged_permissions"
      dump_objects_to_yaml_file(staged_changes, "staged_permissions")

      staged_roles = select_all "cbac_staged_roles"
      dump_objects_to_yaml_file(staged_roles, "staged_roles")

      permissions = select_all "cbac_permissions"
      dump_permissions_to_yaml_file(permissions)

      generic_roles = select_all "cbac_generic_roles"
      dump_objects_to_yaml_file(generic_roles, "generic_roles")

      memberships = select_all "cbac_memberships"
      dump_objects_to_yaml_file(memberships, "memberships")

      known_permissions = select_all "cbac_known_permissions"
      dump_objects_to_yaml_file(known_permissions, "known_permissions")
    end

    desc 'Restore a snapshot of authorization settings that was extracted earlier. Specify a snapshot using SNAPSHOT_NAME'
    task :restore_snapshot => :environment do
      adapter = get_cbac_pristine_adapter
      if ENV['SNAPSHOT_NAME'].nil?
        puts "Missing required parameter SNAPSHOT_NAME. Exiting."
        exit
      elsif adapter.database_contains_cbac_data?
        if ENV['FORCE'] == "true"
          puts "FORCE specified: emptying CBAC tables"
          adapter.clear_cbac_tables
        else
          puts "Reloading snapshot failed: CBAC tables are nonempty. Specify FORCE=true to override this check and empty the tables"
          exit
        end
      end

      puts "Restoring snapshot #{ENV['SNAPSHOT_NAME']}"

      ENV['FIXTURES_PATH'] = ENV['SNAPSHOT_NAME']

      # Don't need privilege sets since they are loaded from a config file.
      ENV['FIXTURES'] = "cbac_generic_roles,cbac_memberships,cbac_known_permissions,cbac_permissions,cbac_staged_permissions, cbac_staged_roles"

      Rake::Task["db:fixtures:load"].invoke
      puts "Successfully restored snapshot."
      #TODO: check if rake task was successful. else
      #  puts "Restoring snapshot failed."
      #end
    end

    desc 'Restore permissions to factory settings by loading the pristine file into the database'
    task :pristine => :environment do
      adapter = get_cbac_pristine_adapter
      if adapter.database_contains_cbac_data?
        if ENV['FORCE'] == "true"
          puts "FORCE specified: emptying CBAC tables"
        else
          puts "CBAC pristine failed: CBAC tables are nonempty. Specify FORCE=true to override this check and empty the tables"
          exit
        end
      end

      if ENV['SKIP_SNAPSHOT'] == 'true'
        puts "\nSKIP_SNAPSHOT provided - not dumping database."
      else
        puts "\nDumping a snapshot of the database"
        Rake::Task["cbac:extract_snapshot"].invoke
      end
      filename = ENV['PRISTINE_FILE'] || "config/cbac/cbac.pristine"
      puts "Parsing pristine file #{filename}"
      pristine_file = adapter.find_or_create_pristine_file(filename)
      adapter.set_pristine_state([pristine_file], true)
      puts "Applied #{pristine_file.permissions.length.to_s} permissions."
      puts "Task cbac:pristine finished."
    end

    desc 'Restore generic permissions to factory settings'
    task :pristine_generic => :environment do
      adapter = get_cbac_pristine_adapter
      if adapter.database_contains_cbac_data?
        if ENV['FORCE'] == "true"
          puts "FORCE specified. Dropping all generic permissions and replacing them with generic pristine"
          adapter.delete_generic_known_permissions
          adapter.delete_generic_permissions
        else
          puts "CBAC pristine failed: CBAC tables are nonempty. Specify FORCE=true to override this check and empty the tables"
          exit
        end
      end

      if ENV['SKIP_SNAPSHOT'] == 'true'
        puts "\nSKIP_SNAPSHOT provided - not dumping database."
      else
        puts "\nDumping a snapshot of the database"
        Rake::Task["cbac:extract_snapshot"].invoke
      end

      filename = ENV['GENERIC_PRISTINE_FILE'] || "config/cbac/cbac_generic.pristine"
      puts "Parsing pristine file #{filename}"
      pristine_file = adapter.find_or_create_generic_pristine_file(filename)
      adapter.set_pristine_state([pristine_file], false)
      puts "Applied #{pristine_file.permissions.length.to_s} permissions."
      puts "Task cbac:pristine_generic finished."
    end

    desc 'Restore all permissions to factory state. Uses the pristine file and the generic pristine file'
    task :pristine_all => :environment do
      adapter = get_cbac_pristine_adapter
      if adapter.database_contains_cbac_data?
        if ENV['FORCE'] == "true"
          puts "FORCE specified: emptying CBAC tables"
        else
          puts "CBAC pristine failed: CBAC tables are nonempty. Specify FORCE=true to override this check and empty the tables"
          exit
        end
      end

      if ENV['SKIP_SNAPSHOT'] == 'true'
        puts "\nSKIP_SNAPSHOT provided - not dumping database."
      else
        puts "\nDumping a snapshot of the database"
        Rake::Task["cbac:extract_snapshot"].invoke
      end
      filename = ENV['PRISTINE_FILE'] || "config/cbac/cbac.pristine"
      generic_filename = ENV['GENERIC_PRISTINE_FILE'] || "config/cbac/cbac_generic.pristine"
      puts "Parsing pristine file #{filename} and generic pristine file #{generic_filename}"
      pristine_file = adapter.find_or_create_pristine_file(filename)
      generic_pristine_file = adapter.find_or_create_generic_pristine_file(generic_filename)
      adapter.set_pristine_state([pristine_file, generic_pristine_file], true)
      puts "Applied #{pristine_file.permissions.length.to_s} permissions and #{generic_pristine_file.permissions.length.to_s} generic permissions."
      puts "Task cbac:pristine_all finished."
    end

    desc 'Upgrade permissions by adding them to the staging area. Does not upgrade generic permissions'
    task :upgrade_pristine => :environment do
      adapter = get_cbac_pristine_adapter
      if ENV['SKIP_SNAPSHOT'] == 'true'
        puts "\nSKIP_SNAPSHOT provided - not dumping database."
      else
        puts "\nDumping a snapshot of the database"
        Rake::Task["cbac:extract_snapshot"].invoke
      end

      ENV['CHANGE_TYPE'] = 'context'
      filename = ENV['PRISTINE_FILE'] || "config/cbac/cbac.pristine"
      puts "Parsing pristine file #{filename}"

      pristine_file = adapter.find_or_create_pristine_file(filename)
      adapter.delete_non_generic_staged_permissions
      puts "Deleted all staged context and administrator permissions"

      adapter.stage_permissions([pristine_file])
      puts "Staged #{adapter.number_of_non_generic_staged_permissions.to_s} permissions."
      puts "Task cbac:upgrade_pristine finished."
    end


    desc 'Upgrade generic permissions by adding them to the staging area. Does not upgrade context or admin permissions.'
    task :upgrade_pristine_generic => :environment do
      adapter = get_cbac_pristine_adapter
      if ENV['SKIP_SNAPSHOT'] == 'true'
        puts "\nSKIP_SNAPSHOT provided - not dumping database."
      else
        puts "\nDumping a snapshot of the database"
        Rake::Task["cbac:extract_snapshot"].invoke
      end

      ENV['CHANGE_TYPE'] = 'context'
      generic_filename = ENV['GENERIC_PRISTINE_FILE'] || "config/cbac/cbac_generic.pristine"

      puts "Parsing pristine file #{generic_filename}"
      generic_pristine_file = adapter.find_or_create_generic_pristine_file(generic_filename)

      adapter.delete_non_generic_staged_permissions
      puts "Deleted all staged generic permissions"

      adapter.stage_permissions([generic_pristine_file])
      puts "Staged #{adapter.number_of_generic_staged_permissions.to_s} generic permissions."
      puts "Task cbac:upgrade_pristine finished."
    end

    desc 'Upgrade all permissions by adding them to the staging area.'
    task :upgrade_all => :environment do
      adapter = get_cbac_pristine_adapter
      if ENV['SKIP_SNAPSHOT'] == 'true'
        puts "\nSKIP_SNAPSHOT provided - not dumping database."
      else
        puts "\nDumping a snapshot of the database"
        Rake::Task["cbac:extract_snapshot"].invoke
      end

      ENV['CHANGE_TYPE'] = 'context'
      filename = ENV['PRISTINE_FILE'] || "config/cbac/cbac.pristine"
      generic_filename = ENV['GENERIC_PRISTINE_FILE'] || "config/cbac/cbac_generic.pristine"
      puts "Parsing pristine file #{filename} and generic pristine file #{generic_filename}"

      pristine_file = adapter.find_or_create_pristine_file(filename)
      generic_pristine_file = adapter.find_or_create_generic_pristine_file(generic_filename)

      adapter.delete_generic_staged_permissions
      adapter.delete_non_generic_staged_permissions
      puts "Deleted all current staged permissions"


      adapter.stage_permissions([pristine_file, generic_pristine_file])
      puts "Staged #{adapter.number_of_non_generic_staged_permissions.to_s} permissions and #{adapter.number_of_generic_staged_permissions.to_s} generic permissions."
      puts "Task cbac:upgrade_all finished."
    end
end
