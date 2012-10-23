class Cbac::Membership < ActiveRecord::Base
  self.table_name = "cbac_memberships"
  belongs_to :generic_role, :class_name => "Cbac::GenericRole", :foreign_key => "generic_role_id"
end