require File.expand_path(File.join(File.dirname(__FILE__), '../../../../test/test_helper'))
require 'test/unit'
require 'rubygems'

# ### Tests the Cbac::ContextRole class
#
class CbacContextRoleTest <  ActiveSupport::TestCase
  # Adds a new context role This test should add a new ContextRole and
  # everything should be working.
  def test_adding_new_context_role_by_string
    eval_string = "true"
    assert_difference("ContextRole.roles.length", 1, "Failed to add new ContextRole") do
      ContextRole.add :test_adding_new_context_role_by_string, eval_string
    end
    assert_equal(true, ContextRole.roles.keys.include?(:test_adding_new_context_role_by_string), "ContextRole symbol not found.")
    result = ContextRole.roles[:test_adding_new_context_role_by_string].call(nil)
    assert_equal(true, result, "Incorrect eval string.")
    eval_string = "false"
    assert_difference("ContextRole.roles.length", 1, "Failed to add new ContextRole") do
      ContextRole.add :test_adding_new_context_role_by_string2, eval_string
    end
    assert_equal(true, ContextRole.roles.keys.include?(:test_adding_new_context_role_by_string2), "ContextRole symbol not found.")
    result = ContextRole.roles[:test_adding_new_context_role_by_string2].call(nil)
    assert_equal(false, result, "Incorrect eval string.")
  end

  # Adds a new context role This test should add a new ContextRole and
  # everything should be working.
  def test_adding_new_context_role_by_block_statement
    assert_difference("ContextRole.roles.length", 1, "Failed to add new ContextRole") do
      ContextRole.add :test_adding_new_context_role_by_block_stmt do
        @test = 2
        true
      end
    end
    assert_equal(true, ContextRole.roles.keys.include?(:test_adding_new_context_role_by_block_stmt), "ContextRole symbol not found.")
    @test = 0
    ContextRole.roles[:test_adding_new_context_role_by_block_stmt].call
    assert_equal(2, @test, "Incorrect eval string.")
  end

  # When adding an already existing ContextRole, an ArgumentError should be
  # raised. ContextRoles can only be declared once.
  def test_adding_double_context_roles
    ContextRole.add :test_adding_double_context_roles, ""
    assert_raise(ArgumentError) do
      ContextRole.add :test_adding_double_context_roles, ""
    end
  end
end
