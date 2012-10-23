class Cbac::Permission < ActiveRecord::Base
  self.table_name = "cbac_permissions"

  belongs_to :generic_role, :class_name => "Cbac::GenericRole", :foreign_key => "generic_role_id"
  belongs_to :privilege_set, :class_name => "Cbac::PrivilegeSetRecord", :foreign_key => "privilege_set_id"
end