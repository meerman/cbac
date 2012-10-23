class Cbac::PrivilegeSetRecord < ActiveRecord::Base
  self.table_name = "cbac_privilege_set"

  def set_comment(comment)
    self.comment = comment if has_attribute?("comment")    
  end
end