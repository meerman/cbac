class CreateCbacUpgradePath < ActiveRecord::Migration
  def self.up

    create_table :cbac_staged_permissions do |t|
      t.integer :pristine_role_id
      t.string :privilege_set_name
      t.integer :line_number
      t.string :comment
      t.text :operation, :limit => 2
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
    drop_table :cbac_staged_permissions
    drop_table :cbac_staged_roles
    drop_table :cbac_known_permissions
  end
end
