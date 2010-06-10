class CreateCbacStagedChange < ActiveRecord::Migration
  def self.up
    create_table :cbac_staged_changes do |t|
      t.integer :generic_role_id, :default => 0
      t.string :context_role
      t.integer :privilege_set_id
      t.integer :change_number
      t.text :action, :limit => 2
      t.timestamps
    end
  end

  def self.down
    drop_table :cbac_staged_changes
  end
end
