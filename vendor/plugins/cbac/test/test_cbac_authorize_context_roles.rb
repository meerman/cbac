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
# Tests the Cbac system for authorization with context roles
#
class CbacAuthorizeContextRolesTest <  ActiveSupport::TestCase
  include Cbac
  
  self.fixture_path = File.join(File.dirname(__FILE__), "fixtures")
  fixtures :all
  attr_accessor :authorize_context_eval_string
  attr_accessor :session

  # Setup defines the PrivilegeSet that is being used by all PrivilegeTest methods
  def setup
    return if PrivilegeSet.sets.include?(:cbac_context_role)
    PrivilegeSet.add :cbac_context_role, ""
    Privilege.resource  :cbac_context_role, "authorize/context/roles", :get
    ContextRole.add :authorize_context_role, "context[:authorize_context_eval_string]"
  end

  # Check to see if action is correctly authorized
  def test_authorize_ok
    assert_equal true, authorization_check("authorize/context", "roles", :get, {:authorize_context_eval_string => true})
  end

  # Run authorization with incorrect authorization
  def test_authorize_incorrect_privilege
    assert_equal false, authorization_check("authorize/context", "roles", :get, {:authorize_context_eval_string => false})
  end
end
