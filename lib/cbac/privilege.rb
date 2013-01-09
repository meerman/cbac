# Class containing all the privileges
#
# To define a new controller method resource: Privilege.resource :privilegeset,
# "controller/method"
#
class Privilege
  class << self
    attr_reader :get_resources, :post_resources, :model_attributes, :models

    # The includes hash contains references to inheritence. The key points to the
    # base class, the value is an array of children.
    #
    # Example:
    # If Child inherits from Parent, then the structure would be:
    # includes[:Parent] = [:Child]
    attr_reader :includes

    # Links a resource with a PrivilegeSet
    #
    # An ArgumentError exception is thrown if the PrivilegeSet does not exist.
    # To create PrivilegeSets, use the PrivilegeSet.add method
    def resource(privilege_set, method, action="GET")
      privilege_set = privilege_set.to_sym
      @get_resources = Hash.new if @get_resources.nil?
      @post_resources = Hash.new if @post_resources.nil?
      action_aliases = {"GET" => ["GET", "get", "g","idempotent"], "POST" => ["POST", "post", "p"]}
      raise ArgumentError, "CBAC: PrivilegeSet does not exist: #{privilege_set}" unless Cbac::PrivilegeSet.sets.include?(privilege_set)
      action_option = action_aliases.find { |name, aliases| aliases.include?(action.to_s) }
      raise ArgumentError, "CBAC: Wrong value for argument 'action' in Privilege.resource: #{action}" if action_option.nil?
      case action_option[0]
      when "GET"
        (@get_resources[method] ||= Array.new) << Cbac::PrivilegeSet.sets[privilege_set]
        (@includes[privilege_set] || Array.new).each {|child_set| (@get_resources[method] ||= Array.new) << Cbac::PrivilegeSet.sets[child_set]} unless @includes.nil?
      when "POST"
        (@post_resources[method] ||= Array.new) << Cbac::PrivilegeSet.sets[privilege_set]
        (@includes[privilege_set] || Array.new).each {|child_set| (@post_resources[method] ||= Array.new) << Cbac::PrivilegeSet.sets[child_set]} unless @includes.nil?
      else
        raise "CBAC: This should never happen (incorrect HTTP action)"
      end
    end

    # Make a privilege set dependant on other privilege set(s).
    #
    # Usage:
    # Privilege.include :child_set, :base_set
    # Privilege.include :child_set, [:base_set_1, :base_set_2]
    #
    # An ArgumentError exception is thrown if any of the PrivilegeSet methods do not exist.
    def include(privilege_set, included_privilege_set)
      @includes = Hash.new if @includes.nil?
      child_set = privilege_set.to_sym
      raise ArgumentError, "CBAC: PrivilegeSet does not exist: #{child_set}" unless Cbac::PrivilegeSet.sets.include?(child_set)
      included_privilege_set = [included_privilege_set] unless included_privilege_set.is_a?(Enumerable)
      included_privilege_set.each do |base_set|
        # Check for existence of PrivilegeSet
        raise ArgumentError, "CBAC: PrivilegeSet does not exist: #{base_set}" unless Cbac::PrivilegeSet.sets.include?(base_set)
        # Adds the references
        (@includes[base_set.to_sym] ||= Array.new) << child_set
        # Copies existing resources
        @get_resources.each do |method, privilege_sets|
          resource child_set, method, :get if privilege_sets.any? {|set| set.name == base_set.to_s}
        end
        @post_resources.each do |method, privilege_sets|
          resource child_set, method, :post if privilege_sets.any? {|set| set.name == base_set.to_s}
        end
      end
    end
      

    def model_attribute

    end
    def model

    end

    # Finds the privilege sets associated with the given controller_method and
    # action_type Valid values for action_type are "get", "post" and "put".
    # "put" is converted into "post".
    #
    # Usage:
    # Privilege.select "my_controller/action", :get
    #
    # Returns an array of Cbac::PrivilegeSet objects
    #
    # If incorrect values are given for action_type the method will raise an
    # ArgumentError. If the controller and action name are not found, an
    # exception is being raised.
    def select(controller_method, action_type)
      action_type = action_type.to_s
      post_methods = ["post", "put", "delete"]
      if action_type == "get"
        privilege_sets = Privilege.get_resources[controller_method]
      else if post_methods.include?(action_type)
          privilege_sets = Privilege.post_resources[controller_method]
        else
          raise ArgumentError, "CBAC: Incorrect action_type: #{action_type}"
        end
      end
      # Error handling if no privilege_sets were found
      if privilege_sets.nil?
        if action_type == "get"
          if !Privilege.post_resources[controller_method].nil?
            raise "CBAC: PrivilegeSets only exist for other action: post on method: #{controller_method}"
          end
        else
          if !Privilege.get_resources[controller_method].nil?
            raise "CBAC: PrivilegeSets only exist for other action: get on method: #{controller_method}"
          end
        end
        raise "CBAC: Could not find any privilege sets associated with: #{controller_method} and action: #{action_type}" +
          "Available GET resources:\n" + Privilege.get_resources.inject("") {|sum, (key, value)| sum + key.to_s + "\n"}
      end
      privilege_sets
    end
  end
end
