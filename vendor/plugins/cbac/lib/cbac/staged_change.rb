class Cbac::StagedChange < ActiveRecord::Base
  set_table_name "cbac_staged_changes"

  attr_accessor_with_default :accepted, true
end
