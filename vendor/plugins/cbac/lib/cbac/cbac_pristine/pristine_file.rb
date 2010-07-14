require File.expand_path(File.join(File.dirname(__FILE__), 'pristine_role'))
require File.expand_path(File.join(File.dirname(__FILE__), 'pristine_permission'))

module Cbac
  module CbacPristine
    class AbstractPristineFile
      attr_accessor :file_name, :permissions, :generic_roles

      def initialize(file_name)
        @file_name = file_name
        @generic_roles = []
        @permissions = []
        @admin_role = nil
      end

      def parse(use_db = true)
        @permissions = Array.new

        f = File.open(@file_name, "r")
        last_row_number = -1
        f.each_with_index do |l, line_number|
          pristine_permission = PristinePermission.new
          permission_line = l.chomp
          # if this is not a line we can convert into a permission, go to next line (or fail.....)
          next unless is_pristine_permission_line?(permission_line, line_number)

          # check if the row numbers are constructed properly.
          # this is needed for migration purposes, each permission should have an unique and persistent row number
          header_match = permission_line.match(/^(\d+):([\+-x]|=>):\s*/)
          pristine_permission.line_number = header_match.captures[0].to_i
          if pristine_permission.line_number != last_row_number.succ
            raise SyntaxError, "Error: row numbers in pristine file do not increase monotonously"
          else
            last_row_number = pristine_permission.line_number
          end
          pristine_permission.operation = header_match.captures[1]
          # parse the role and privilege set name
          pristine_permission.privilege_set_name = parse_privilege_set_name(permission_line, line_number)
          pristine_permission.pristine_role = parse_role(permission_line, line_number, use_db)
          # it's pristine, so changes should be treated as such
          # if a permission was created and later revoked, we should remove the pristine line which was created before
          case pristine_permission.operation
            when '+'
              @permissions.push(pristine_permission)
            when '-'
              permission_to_delete = nil
              #check if this is actually a permission that can be revoked.
              @permissions.each do |known_permission|
                if known_permission.privilege_set_name == pristine_permission.privilege_set_name and known_permission.pristine_role.name == pristine_permission.pristine_role.name
                  permission_to_delete = known_permission
                  break
                end
              end
              if permission_to_delete.nil?
                raise SyntaxError, "Error: trying to remove a privilege set with \"#{permission_line}\" on line #{(line_number + 1).to_s}, but this privilege set wasn't created!"
              else
                @permissions.push(pristine_permission)
              end
            when 'x', '=>'
              raise NotImplementedError, "Using an x or => in a pristine file is not implemented yet"
          end
        end
      end

      def is_pristine_permission_line?(line, line_number)
        if line.match(/^\s*(\d+)\s*:\s*([\+-x]|=>)\s*:(\s*[A-Za-z]+\(\s*[A-Za-z_]*\s*\))+\s*\Z/) #looks like pristine line.....
          return true
        end
        if line.match(/^\s*(#.*|\s*)$/) # line is whitespace or comment line
          return false
        end
        raise SyntaxError, "Error: garbage found in input file on line #{(line_number + 1).to_s}" #line is rubbish
      end

      def parse_privilege_set_name(line, line_number)
        if match_data= line.match(/^.*PrivilegeSet\(\s*([A-Za-z0-9_]+)\s*\)\s*/)
          return match_data.captures[0]
        end
        raise SyntaxError, "Error: PrivilegeSet expected, but found: \"#{line}\" on line #{(line_number + 1).to_s}"
      end

      def parse_role(line, line_number, use_db = true)
        raise NotImplementedError("Error: the AbstractPristineFile cannot parse roles, use a PristineFile or GenericPristineFile instead")
      end

      def permission_set
        permission_set = Array.new(@permissions)
        @permissions.each do |pristine_permission|
           case pristine_permission.operation
            when '+'
              permission_set.push(pristine_permission)
            when '-'
              permission_to_delete = nil
              #check if this is actually a permission that can be revoked.
              permission_set.each do |known_permission|
                if known_permission.privilege_set_name == pristine_permission.privilege_set_name and known_permission.pristine_role.name == pristine_permission.pristine_role.name and known_permission.operation == '+'
                  permission_to_delete = known_permission
                  break
                end
              end
              if permission_to_delete.nil?
                raise ArgumentError, "Error: trying to remove permission #{pristine_permission.privilege_set_name}\" for #{pristine_permission.pristine_role.name}, but this permission wasn't created!"
              else
                permission_set.delete(permission_to_delete)
                permission_set.delete(pristine_permission)
              end
            when 'x', '=>'
              raise NotImplementedError, "Using an x or => in a pristine file is not implemented yet"
          end
        end
        permission_set
      end

    end


    class PristineFile < Cbac::CbacPristine::AbstractPristineFile
      def parse_role(line, line_number, use_db = true)
        if line.match(/^.*Admin\(\)/)
          return @admin_role unless @admin_role.nil?

          @admin_role = PristineRole.admin_role(use_db)
          @generic_roles.push(@admin_role)
          return @admin_role
        end
        if context_role_name = line.match(/^.*ContextRole\(\s*([A-Za-z0-9_]+)\s*\)/)
          # NOTE: the 0 for an ID is very important! In CBAC a context role permission MUST have 0 as generic_role_id
          # if not, the context role is not found by CBAC and thus will not work
          context_role = use_db ? PristineRole.first(:conditions => {:role_type => PristineRole.ROLE_TYPES[:context], :name => context_role_name.captures[0]}) : nil
          context_role = PristineRole.new(:role_id => 0, :role_type => PristineRole.ROLE_TYPES[:context], :name => context_role_name.captures[0]) if context_role.nil?
          return context_role
        end
        raise SyntaxError, "Error: ContextRole or Admin expected, but found: \"#{line}\" on line #{(line_number + 1).to_s}"
      end


    end

    class GenericPristineFile < Cbac::CbacPristine::AbstractPristineFile
      def parse_role(line, line_number, use_db = true)
        # generic pristine files differ, because they create generic roles when needed
        # but those generic roles should be re-used if one with that name already exists
        if generic_role= line.match(/^.*GenericRole\(\s*([A-Za-z0-9_]+)\s*\)/)
          @generic_roles.each do |generic_cbac_role|
            if generic_cbac_role.name == generic_role.captures[0]
              return generic_cbac_role
            end
          end
          role = use_db ? PristineRole.first(:conditions => {:role_type => PristineRole.ROLE_TYPES[:generic], :name => generic_role.captures[0]}) : nil
          role =  PristineRole.new(:role_id => @generic_roles.length + 2, :role_type => PristineRole.ROLE_TYPES[:generic], :name => generic_role.captures[0]) if role.nil?
          @generic_roles.push(role)
          return role
        end
        raise SyntaxError, "Error: GenericRole expected, but found: \"#{line}\" on line #{(line_number + 1).to_s}"
      end
    end
  end
end