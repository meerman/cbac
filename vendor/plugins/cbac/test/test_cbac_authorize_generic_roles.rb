require File.expand_path(File.join(File.dirname(__FILE__), '../../../../test/test_helper'))
require 'test/unit'
require 'rubygems'

# Dummy code for overriding the default current_user behavior
module Cbac
  def current_user
    1
  end
end

###
# Tests the Cbac system for authorization with generic roles
#
class CbacAuthorizeGenericRolesTest <  ActiveSupport::TestCase
  self.fixture_path = File.join(File.dirname(__FILE__), "fixtures")
  fixtures :all

  # Setup defines the PrivilegeSet that is being used by all PrivilegeTest methods
  def setup
    return if PrivilegeSet.sets.include?(:cbac_generic_role)
    PrivilegeSet.add :cbac_generic_role, ""
    PrivilegeSet.add :cbac_generic_role_incorrect, ""
    Privilege.resource  :cbac_generic_role, "authorize/generic/roles", :get
    Privilege.resource  :cbac_generic_role_incorrect, "authorize/generic/roles_incorrect", :get
  end

  # Check to see if action is correctly authorized
  def test_authorize_ok
    assert_equal true, authorization_check("authorize/generic", "roles", :get)
  end

  # Run authorization with incorrect authorization
  def test_authorize_incorrect_privilege
    assert_equal false, authorization_check("authorize/generic", "roles_incorrect", :get)
  end
end
