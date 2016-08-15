class Cbac::GenericRole < ActiveRecord::Base
  self.table_name = "cbac_generic_roles"

  has_many :generic_role_members, :class_name => "Cbac::Membership", :foreign_key => "generic_role_id"
  has_many :permissions, :class_name => "Cbac::Permission", :foreign_key => "generic_role_id"
end
