class CreateCbacUpgradePath < ActiveRecord::Migration
  def self.up
    create_table :cbac_staged_changes do |t|
      t.integer :generic_role_id, :default => 0
      t.string :context_role
      t.integer :privilege_set_id
      t.integer :change_number
      t.string :comment
      t.text :action, :limit => 2
      t.timestamps
    end
    create_table :cbac_known_permissions, :id => false do |t|
      t.integer :permission_number, :null => :no
      t.integer :permission_type, :default => 0
    end
  end

  def self.down
    drop_table :cbac_staged_changes
    drop_table :cbac_known_permissions
  end
end
