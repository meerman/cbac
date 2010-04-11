class Cbac::PrivilegeSetRecord < ActiveRecord::Base
  set_table_name "cbac_privilege_set"

  attr_accessor :comment
end