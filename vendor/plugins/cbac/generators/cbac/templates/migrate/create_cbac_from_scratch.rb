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

    create_table :cbac_staged_permissions do |t|
      t.integer :pristine_role_id
      t.string :privilege_set_name
      t.integer :line_number
      t.string :comment
      t.text :operand, :limit => 2
      t.timestamps
    end

    create_table :cbac_staged_roles do |t|
      t.string :role_type
      t.string :name
      t.integer :role_id
      t.timestamps
    end

    create_table :cbac_known_permissions do |t|
      t.integer :permission_number, :null => :no
      t.integer :permission_type, :default => 0
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
