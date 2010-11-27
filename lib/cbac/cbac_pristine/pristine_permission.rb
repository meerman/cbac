require File.expand_path(File.join(File.dirname(__FILE__), 'pristine_role'))
require File.expand_path(File.join(File.dirname(__FILE__), 'pristine_permission'))
require 'active_record'

module Cbac
  module CbacPristine
    class PristinePermission < ActiveRecord::Base
      set_table_name 'cbac_staged_permissions'

      belongs_to :pristine_role, :class_name => "Cbac::CbacPristine::PristineRole"

      def privilege_set
        Cbac::PrivilegeSetRecord.first(:conditions => {:name => privilege_set_name})
      end

      def operation_string
        case operation
          when '+'
            return "add"
          when '-'
            return "revoke"
          else
            return "unknown"
        end
      end

      #convert this pristine line to a yml statement which can be used to create a yml fixtures file
      #executing this statement will result in one cbac_permission in the DB
      def to_yml_fixture(fixture_id = nil)
        raise ArgumentError, "Error: cannot convert line #{line_number.to_s} to yml because the role is not specified" if pristine_role.nil?
        raise ArgumentError, "Error: cannot convert line #{line_number.to_s} to yml because the privilege_set_name is not specified" if privilege_set_name.blank?

        fixture_id = line_number if fixture_id.nil?

        yml = "cbac_permission_00" << fixture_id.to_s << ":\n"
        yml << "  id: " << fixture_id.to_s << "\n"
        yml << "  context_role: "
        yml << pristine_role.name if pristine_role.role_type == PristineRole.ROLE_TYPES[:context]
        yml << "\n"
        yml << "  generic_role_id: " << pristine_role.role_id.to_s << "\n"
        yml << "  privilege_set_id: <%= Cbac::PrivilegeSetRecord.find(:first, :conditions => {:name => '" << privilege_set_name << "'}).id %>\n"
        yml << "  created_at: " << Time.now.strftime("%Y-%m-%d %H:%M:%S") << "\n"
        yml << "  updated_at: " << Time.now.strftime("%Y-%m-%d %H:%M:%S") << "\n"
        yml << "\n"
      end

      # checks if the current cbac permissions contains a permission which is exactly like this one
      def cbac_permission_exists?
        if pristine_role.role_type == PristineRole.ROLE_TYPES[:context]
          Cbac::Permission.count(:joins => [:privilege_set], :conditions => {:cbac_privilege_set => {:name => privilege_set_name}, :context_role => pristine_role.name}) > 0
        else
          Cbac::Permission.count(:joins => [:generic_role, :privilege_set], :conditions => {:cbac_privilege_set => {:name => privilege_set_name}, :cbac_generic_roles => {:name => pristine_role.name}}) > 0
        end
      end

      # checks if a pristine permission with the same properties(except line_number) exists in the database
      def exists?
        Cbac::CbacPristine::PristinePermission.count(:conditions => {:privilege_set_name => privilege_set_name, :pristine_role_id => pristine_role_id, :operation => operation}) > 0
      end

      # checks if a pristine permission with the exact same properties(except line_number), but the reverse operation exists in the database
      def reverse_exists?
        Cbac::CbacPristine::PristinePermission.count(:conditions => {:privilege_set_name => privilege_set_name, :pristine_role_id => pristine_role_id, :operation => reverse_operation}) > 0
      end

      # delete the pristine permission with the reverse operation of this one
      def delete_reverse_permission
        reverse_permission = Cbac::CbacPristine::PristinePermission.first(:conditions => {:privilege_set_name => privilege_set_name, :pristine_role_id => pristine_role_id, :operation => reverse_operation})
        reverse_permission.delete
      end

      # get the reverse operation of this one
      def reverse_operation
        case operation
          when '+'
            return '-'
          when '-'
            return '+'
          when 'x', '=>'
            raise NotImplementedError, "Error: using an x or => in a pristine file is not implemented yet"
          else
            raise ArgumentError, "Error: invalid operation #{operation} is used in the pristine file"
        end
      end

      # checks if the known_permissions table has an entry for this permission
      def known_permission_exists?
        Cbac::KnownPermission.count(:conditions => {:permission_type => pristine_role.known_permission_type, :permission_number => line_number}) > 0
      end

      # accept this permission and apply to the current cbac permission set
      def accept
        case operation
          when '+'
            handle_grant_permission
          when '-'
            handle_revoke_permission
          when 'x', '=>'
            raise NotImplementedError, "Error: using an x or => in a pristine file is not implemented yet"
          else
            raise ArgumentError, "Error: invalid operation #{operation} is used in the pristine file"
        end
        PristinePermission.delete(id) unless id.nil?
      end

      # reject this permission, but register it as a known permission. The user actually rejected this himself.
      def reject
        register_change
        PristinePermission.delete(id) unless id.nil?
      end

      # add this permission to the cbac permission set, unless it already exists
      def handle_grant_permission
        return if cbac_permission_exists?

        permission = Cbac::Permission.new
        permission.privilege_set = privilege_set

        if pristine_role.role_type == PristineRole.ROLE_TYPES[:context]
          permission.context_role = pristine_role.name
        else
          generic_role = Cbac::GenericRole.first(:conditions => {:name => pristine_role.name})
          permission.generic_role = generic_role.nil? ? Cbac::GenericRole.create(:name => pristine_role.name, :remarks => "Autogenerated by Cbac loading / upgrade system") : generic_role
        end

        register_change if permission.save
        permission
      end

      # revoke this permission from the current permission set, raises an error if it doesn't exist yet
      def handle_revoke_permission
        raise ArgumentError, "Error: trying to revoke permission #{privilege_set_name} for #{pristine_role.name}, but this permission does not exist" unless cbac_permission_exists?

        if pristine_role.role_type == PristineRole.ROLE_TYPES[:context]
          permission = Cbac::Permission.first(:joins => [:privilege_set], :conditions => {:cbac_privilege_set => {:name => privilege_set_name}, :context_role => pristine_role.name})
        else
          permission = Cbac::Permission.first(:joins => [:generic_role, :privilege_set], :conditions => {:cbac_privilege_set => {:name => privilege_set_name}, :cbac_generic_roles => {:name => pristine_role.name}})
        end

        register_change if permission.destroy
      end

      # register this permission as a known permission
      def register_change
        Cbac::KnownPermission.create(:permission_number => line_number, :permission_type => pristine_role.known_permission_type)
      end

      # add this permission to the staging area
      def stage
        raise ArgumentError, "Error: this staged permission already exists. Record with line number #{line_number} is a duplicate permission." if exists?
        return if known_permission_exists?

        if operation == '-'
          # if the reverse permission is also staged, remove it and do not add this one
          if reverse_exists?
            delete_reverse_permission
            return
          end
          # if this is an attempt to revoke a permission, it should exist as a real cbac permission!
          save if cbac_permission_exists?
        elsif operation == '+'
          # if this is an attempt to add a permission, it MUST not exist yet
          save unless cbac_permission_exists?
        end
      end



      # clear the staging area of all generic pristine permissions
      def self.delete_generic_permissions
        generic_staged_permissions = all(:joins => :pristine_role, :conditions => ["cbac_staged_roles.role_type = ?", PristineRole.ROLE_TYPES[:generic]])
        generic_staged_permissions.each do |permission|
          delete(permission.id)
        end
      end

      # clear the staging area of all non generic permissions
      def self.delete_non_generic_permissions
        staged_permissions = all(:joins => :pristine_role, :conditions => ["cbac_staged_roles.role_type != ?", PristineRole.ROLE_TYPES[:generic]])
        staged_permissions.each do |permission|
          delete(permission.id)
        end
      end

      def self.count_generic_permissions
        count(:joins => :pristine_role, :conditions => ["cbac_staged_roles.role_type = ?", PristineRole.ROLE_TYPES[:generic]])
      end

      def self.count_non_generic_permissions
        count(:joins => :pristine_role, :conditions => ["cbac_staged_roles.role_type != ?", PristineRole.ROLE_TYPES[:generic]])
      end
    end
  end
end