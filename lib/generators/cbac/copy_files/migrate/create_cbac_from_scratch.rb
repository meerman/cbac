class CreateCbacFromScratch < ActiveRecord::Migration
  def self.up
    unless Cbac::Permission.table_exists?
      create_table :cbac_permissions do |t|
        t.integer :generic_role_id, :default => 0
        t.string :context_role
        t.integer :privilege_set_id
        t.timestamps null: false
      end
    end

    unless Cbac::GenericRole.table_exists?
      create_table :cbac_generic_roles do |t|
        t.string :name
        t.text :remarks
        t.timestamps null: false
      end
    end

    unless Cbac::Membership.table_exists?
      create_table :cbac_memberships do |t|
        t.integer :user_id
        t.integer :generic_role_id
        t.timestamps null: false
      end
    end

    unless Cbac::PrivilegeSetRecord.table_exists?
      create_table :cbac_privilege_set do |t|
        t.string :name
        t.string :comment
        t.timestamps null: false
      end
    end

    unless Cbac::CbacPristine::PristineFile.table_exists?
      create_table :cbac_pristine_files do |t|
        t.string :type
        t.string :file_name
        t.timestamps null: false
      end
    end

    unless Cbac::CbacPristine::PristinePermission.table_exists?
      create_table :cbac_staged_permissions do |t|
        t.integer :pristine_role_id
        t.integer :pristine_file_id
        t.string :privilege_set_name
        t.integer :line_number
        t.string :comment
        t.text :operation, :limit => 2
        t.timestamps null: false
      end
    end

    unless Cbac::CbacPristine::PristineRole.table_exists?
      create_table :cbac_staged_roles do |t|
        t.string :role_type
        t.string :name
        t.integer :role_id
        t.timestamps null: false
      end
    end

    unless Cbac::KnownPermission.table_exists?
      create_table :cbac_known_permissions do |t|
        t.integer :permission_number, :null => :no
        t.integer :permission_type, :default => 0
      end
    end
  end

  def self.down
    drop_table :cbac_permissions
    drop_table :cbac_generic_roles
    drop_table :cbac_memberships
    drop_table :cbac_privilege_set
    drop_table :cbac_staged_permissions
    drop_table :cbac_staged_roles
    drop_table :cbac_known_permission
  end
end
