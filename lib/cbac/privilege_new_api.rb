# New API interface for CBAC system
#
# Changelog
# 101022  Bert Meerman    Initial commit
#

module Cbac
  # Starts a privileges and privilegeset declaration block
  def cbac(&block)
    # Defines a new privilegeset
    def set(name, description, &block)

      # Adds a post declaration
      def post(controller, *methods)
        raise "Cannot add privilege without a set" unless @current_set_name
        methods.each {|method|
          Privilege.resource @current_set_name, controller.to_s + "/" + method.to_s, :post
        }
      end

      # Adds a get declaration
      def get(controller, *methods)
        raise "Cannot add privilege without a set" unless @current_set_name
        methods.each {|method|
          Privilege.resource @current_set_name, controller.to_s + "/" + method.to_s, :get
        }
      end

      # Includes the stuff from another set
      def includes(*set)
        raise "includes is not yet supported"
      end

      raise "Cannot embed a set in another set"  if @current_set
      name = name.to_sym
      description = description.to_str
      PrivilegeSet.add(name, description)
      @current_set = PrivilegeSet.sets[name]
      @current_set_name = name
      yield block
      @current_set = nil
      @current_set_name = nil
    end

    # Start an additional namespace declaration
    def in_module (name, &block)
      current_namespace = @cbac_namespace
      @cbac_namespace = @cbac_namespace.to_s + name.to_s + "/"
      yield block
      @cbac_namespace = current_namespace
    end

    # Runs the block
    yield block
  end
end
