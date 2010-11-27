# Copyright 2010 Bert Meerman

########
# Test the actions
# This test set will test whether actions and sets are created. Proper usage
# of these data structures is left to other test files
class CbacActionsTest < ActiveSupport::TestCase
  # Adding actions using a simple get or post command
  def test_add_simple_action
    cbac do
      set :cbac_actions_test do
        post :foo, :bar
        get :foo, :bar
      end
    end
  end

  # Adding multiple methods with a single call
  def test_add_multiple_methods
    cbac do
      set :cbac_actions_test do
        post :foo, [:bar, :bar2]
        get :foo, [:bar, :bar2]
      end
    end
  end

  # Add methods with single parameter
  def test_add_method_with_single_parameter
    cbac do
      set :cbac_actions_test do
        post :foo, :bar, :foobar
        get :foo, :bar, :foobar
      end
    end
  end

  # Add methods with multiple parameters
  def test_add_method_with_multiple_parameter
    cbac do
      set :cbac_actions_test do
        post :foo, :bar, [:foobar, :foobar2]
        get :foo, :bar, [:foobar, :foobar2]
      end
    end
  end

  def test_add_method_with_parameter_mapping
    cbac do
      set :cbac_actions_test do
        post :foo, :bar, :foobar, {:map => :me}
        get :foo, :bar, :foobar, {:map => :me}
      end
    end
  end

  # Test must return multiple warnings, due to usage of _id in the identifier
  # specifications (parameters are /always/ identifiers
  def test_warning_on_adding_method_with_identifier
    cbac do
      set :cbac_actions_test do
        post :foo, :bar, :foobar_id
        get :foo, :bar, :foobar_id
        post :foo, :bar, [:foobar, :foobar2_id]
        get :foo, :bar, [:foobar, :foobar2_id]
      end
    end
  end

  # By default, all parameters will be blocked
end