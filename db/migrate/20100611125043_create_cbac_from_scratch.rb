class CreateCbacFromScratch < ActiveRecord::Migration
  def self.up
    create_table :cbac_permissions do |t|
      t.integer :generic_role_id, :default => 0
      t.string :context_role
      t.integer :privilege_set_id
      t.timestamps
    end

    create_table :cbac_generic_roles do |t|
      t.string :name
      t.text :remarks
      t.timestamps
    end

    create_table :cbac_memberships do |t|
      t.integer :user_id
      t.integer :generic_role_id
      t.timestamps
    end

    create_table :cbac_privilege_set do |t|
      t.string :name
      t.timestamps
    end

    create_table :cbac_staged_changes do |t|
      t.integer :generic_role_id, :default => 0
      t.string :context_role
      t.integer :privilege_set_id
      t.integer :change_number
      t.text :action, :limit => 2
      t.timestamps
    end

    create_table :cbac_known_permissions, :id => false do |t|
      t.integer :permission_number, :null => :no
    end
  end

  def self.down
    drop_table :cbac_permissions
    drop_table :cbac_generic_roles
    drop_table :cbac_memberships
    drop_table :cbac_privilege_set
    drop_table :cbac_staged_changes
    drop_table :cbac_known_permission
  end
end
