class AddPristineFilesToCbacUpgradePath < ActiveRecord::Migration
  def self.up
    create_table :cbac_pristine_files do |t|
      t.string :type
      t.string :file_name
      t.timestamps null: false
    end

    add_column :cbac_staged_permissions, :pristine_file_id, :integer
  end

  def self.down
    drop_table :cbac_pristine_files
    remove_column :cbac_staged_permissions, :pristine_file_id
  end
end
