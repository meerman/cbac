# Class containing all the privileges
#
# To define a new controller method resource: Privilege.resource :privilegeset,
# "controller/method"
#
class Privilege
  class << self
    attr_reader :get_resources, :post_resources, :model_attributes, :models

    # Links a resource with a PrivilegeSet
    #
    # An ArgumentError exception is thrown if the PrivilegeSet does not exist.
    # To create PrivilegeSets, use the PrivilegeSet.add method
    def resource(privilege_set, method, action="GET")
      privilege_set = privilege_set.to_sym
      @get_resources = Hash.new if @get_resources.nil?
      @post_resources = Hash.new if @post_resources.nil?
      action_aliases = {"GET" => ["GET", "get", "g","idempotent"], "POST" => ["POST", "post", "p"]}
      raise ArgumentError, "CBAC: PrivilegeSet does not exist: #{privilege_set}" unless PrivilegeSet.sets.include?(privilege_set)
      action_option = action_aliases.find { |name, aliases| aliases.include?(action.to_s) }
      raise ArgumentError, "CBAC: Wrong value for argument 'action' in Privilege.resource: #{action}" if action_option.nil?
      case action_option[0]
      when "GET"
        (@get_resources[method] ||= Array.new) << PrivilegeSet.sets[privilege_set]
      when "POST"
        (@post_resources[method] ||= Array.new) << PrivilegeSet.sets[privilege_set]
      else
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
        raise "CBAC: Could not find any privilege sets associated with: #{controller_method} and action: #{action_type}"
      end
      privilege_sets
    end
  end
end
