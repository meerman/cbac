require 'active_record'
module Cbac
  module CbacPristine
    class PristineRole < ActiveRecord::Base
      self.table_name = "cbac_staged_roles"
      attr_readonly :role_type, :role_id, :name

      def self.ROLE_TYPES
        {:context => "context", :generic => "generic", :admin => "administrator"}
      end

     
      #convert this cbac role to a yml statement which can be used to create a yml fixtures file
      #executing this statement will result in one cbac_generic_role in the DB
      def to_yml_fixture(fixture_id = nil)
        fixture_id = role_id if fixture_id.nil?

        return '' if role_type == Cbac::CbacPristine::PristineRole.ROLE_TYPES[:context]
        raise ArgumentError, "cannot convert role #{id.to_s} to yml, because it has no name" if name.blank?

        yml = "cbac_generic_role_00" << fixture_id.to_s << ":\n"
        yml << "  id: " << fixture_id.to_s << "\n"
        yml << "  name: " << name << "\n"
        yml << "  created_at: " << Time.now.strftime("%Y-%m-%d %H:%M:%S") << "\n"
        yml << "  updated_at: " << Time.now.strftime("%Y-%m-%d %H:%M:%S") << "\n"
        yml << "\n"
      end

      def known_permission_type
        # NOTE: known permissions use different type definitions than pristine roles.
        # They only use the file type to determine if it is a generic or context role.
        # Context roles include the admin role (same file) while pristine roles use a different type
        role_type == PristineRole.ROLE_TYPES[:generic] ? Cbac::KnownPermission.PERMISSION_TYPES[:generic] : Cbac::KnownPermission.PERMISSION_TYPES[:context]
      end

      def self.admin_role(use_db = true)
        admin_role =  use_db ? PristineRole.first(:conditions => {:role_type => PristineRole.ROLE_TYPES[:admin]}) : nil

        admin_role.nil?  ? PristineRole.new(:role_id => 1, :role_type => PristineRole.ROLE_TYPES[:admin], :name => "administrator") : admin_role
      end
    end
  end
end
