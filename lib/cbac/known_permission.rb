class Cbac::KnownPermission < ActiveRecord::Base
  self.table_name = "cbac_known_permissions"
  attr_readonly :permission_type, :permission_number

  cattr_accessor :PERMISSION_TYPES
  @@PERMISSION_TYPES = {:context => 0, :generic => 1}

  def self.find_context_permissions(conditions = {})
    all(:conditions => conditions.merge(:permission_type => @@PERMISSION_TYPES[:context]))
  end

  def self.find_generic_permissions(conditions = {})
    all(:conditions => conditions.merge(:permission_type => @@PERMISSION_TYPES[:generic]))
  end
end
