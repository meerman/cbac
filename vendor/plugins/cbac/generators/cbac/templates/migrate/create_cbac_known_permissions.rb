class CreateCbacKnownPermissions < ActiveRecord::Migration
  def self.up
    create_table :cbac_known_permissions, :id => false do |t|
      t.integer :permission_number, :null => :no
    end
  end

  def self.down
    drop_table :cbac_known_permissions
  end
end
