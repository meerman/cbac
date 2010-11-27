# Copyright 2010 Bert Meerman
require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

# ### Tests the Cbac::Privilege class
#
class CbacPrivilegeTest <  ActiveSupport::TestCase
  # Setup defines the PrivilegeSet that is being used by all PrivilegeTest
  # methods
  def setup
    PrivilegeSet.add :cbac_privilege, "" unless PrivilegeSet.sets.include?(:cbac_privilege)
    PrivilegeSet.add :base_inheritence_privilege, "" unless PrivilegeSet.sets.include?(:base_inheritence_privilege)
  end

  # Test adding get and post resources It is possible to add a resource using
  # different names for actions. This method also checks if these aliases are
  # all operating well.
  def test_add_resources
    assert_difference("Privilege.get_resources.length", 4, "GET resource was not added.") do
      Privilege.resource :cbac_privilege, "add/resources/get/1", :GET
      Privilege.resource :cbac_privilege, "add/resources/get/2", :get
      Privilege.resource :cbac_privilege, "add/resources/get/3", :g
      Privilege.resource :cbac_privilege, "add/resources/get/4", :idempotent
    end
    assert_difference("Privilege.post_resources.length", 3, "POST resource was not added.") do
      Privilege.resource :cbac_privilege, "add/resources/post/1", :POST
      Privilege.resource :cbac_privilege, "add/resources/post/2", :post
      Privilege.resource :cbac_privilege, "add/resources/post/3", :p
    end
  end

  # Test the include method for single inheritence
  def test_single_inheritence
    Privilege.resource :base_inheritence_privilege, "single/inheritence"
    Privilege.resource :base_inheritence_privilege, "single/inheritence/post", :post
    PrivilegeSet.add :cbac_single_inheritence, "PrivilegeSet for single inheritence test"
    Privilege.include :cbac_single_inheritence, :base_inheritence_privilege
    result = Privilege.select("single/inheritence", :get)
    assert_equal true, result.any? {|set| set.name == "base_inheritence_privilege"}, "Could not find PrivilegeSet (hint: error probably belongs to other test)"
    assert_equal true, result.any? {|set| set.name == "cbac_single_inheritence"}, "Single inheritence failure"
    result = Privilege.select("single/inheritence/post", :post)
    assert_equal true, result.any? {|set| set.name == "cbac_single_inheritence"}, "Single inheritence failure with POST method"
  end

  # Test the include method for multiple inheritence
  def test_multiple_inheritence
    Privilege.resource :base_inheritence_privilege, "multiple/inheritence"
    PrivilegeSet.add :base_multiple_inheritence, "parent/ base PrivilegeSet for multiple inheritence test"
    PrivilegeSet.add :cbac_multiple_inheritence, "child PrivilegeSet for multiple inheritence test"
    Privilege.resource :base_multiple_inheritence, "multiple/inheritence_again"
    Privilege.include :cbac_multiple_inheritence, [:base_inheritence_privilege, :base_multiple_inheritence]
    result = Privilege.select("multiple/inheritence", :get)
    assert_equal true, result.any? {|set| set.name == "base_inheritence_privilege"}, "Could not find PrivilegeSet (hint: error probably belongs to other test)"
    assert_equal true, result.any? {|set| set.name == "cbac_multiple_inheritence"}, "Multiple inheritence failure"
    result = Privilege.select("multiple/inheritence_again", :get)
    assert_equal true, result.any? {|set| set.name == "cbac_multiple_inheritence"}, "Multiple inheritence failure"
  end

  # Inheritence must be applied if a resource is added after an inheritence call
  def test_inherit_resource_after_declaration
    PrivilegeSet.add :cbac_inheritence_after_declaration, "PrivilegeSet for single inheritence test"
    # First, we setup the inheritence relation
    Privilege.include :cbac_inheritence_after_declaration, :base_inheritence_privilege
    # Then, we setup the resource connection
    Privilege.resource :base_inheritence_privilege, "inheritence/after/declaration"
    Privilege.resource :base_inheritence_privilege, "inheritence/after/declaration/post", :post
    # Test
    result = Privilege.select("inheritence/after/declaration", :get)
    assert_equal true, result.any?{|set| set.name == "base_inheritence_privilege"}, "Could not find PrivilegeSet (hint: error probably belongs to other test)"
    assert_equal true, result.any?{|set| set.name == "cbac_inheritence_after_declaration"}, "Resource declaration after inheritence call failed"
    result = Privilege.select("inheritence/after/declaration/post", :post)
    assert_equal true, result.any?{|set| set.name == "cbac_inheritence_after_declaration"}, "Resource declaration after inheritence call failed with POST method"
  end

  # If the inheritence functionality is used with invalid privilege_sets, an ArgumentException must be thrown
  def test_inheritence_with_invalid_privilege_sets
    assert_raise(ArgumentError) do
      Privilege.include :cbac_privilege, :invalid_privilege_set
    end
    assert_raise(ArgumentError) do
      Privilege.include :invalid_privilege_set, :cbac_privilege
    end
  end

  # If an invalid action is specified, the method must raise an ArgumentError
  # exception.
  def test_add_incorrect_action
    assert_raise(ArgumentError) do
      Privilege.resource :cbac_privilege, "add/incorrect/action", :error
    end
  end

  # If a privilege is added to a non existing PrivilegeSet, an ArgumentError
  # exception must occur.
  def test_add_resource_to_invalid_privilege_set
    assert_raise(ArgumentError) do
      Privilege.resource :cbac_privilege_error, "add/resource/to/invalid/privilege/set", :get
    end
  end

  # Test the Privilege.select method. This method accepts a controller method
  # string and an action type It returns the privilegesets that comply with this
  # combination The actions post, put and delete are identical. This test aims
  # at testing this assumption.
  def test_select_correct
    Privilege.resource :cbac_privilege, "select/correct/get", :get
    Privilege.resource :cbac_privilege, "select/correct/post", :post
    Privilege.resource :cbac_privilege, "select/correct/put", :post
    Privilege.resource :cbac_privilege, "select/correct/delete", :post
    assert_equal 1, Privilege.select("select/correct/get", :get).length
    [:post, :put, :delete].each do |action|
      assert_equal 1, Privilege.select("select/correct/post", action).length
      assert_equal 1, Privilege.select("select/correct/put", action).length
      assert_equal 1, Privilege.select("select/correct/delete", action).length
    end
  end

  def test_exception()
    begin
      yield
    rescue Exception => e
      return e.message
    end
    raise "No exception was thrown"
  end

  # test selecting an incorrect action type
  def test_select_incorrect_action_types
    controller_method = "select/incorrect/action/types/get"
    Privilege.resource :cbac_privilege, controller_method, :get
    Privilege.select(controller_method, :get)
    assert_match(/Incorrect action_type/, test_exception { Privilege.select(controller_method, :error) })
  end

  # If a user asks for the wrong action_type (e.g. a request is made for 'get'
  # but there are only 'post' privileges or vica versa) the system will throw an
  # exception as expected, but the system will also hint at the possibility of
  # messing up get and post.
  def test_select_the_other_action_type
    controller_method = "select/the/other/action/type/get"
    Privilege.resource :cbac_privilege, controller_method, :get
    assert_match(/PrivilegeSets only exist for other action/, test_exception { Privilege.select(controller_method, :post) })
  end

  # Trying to find privileges for a set that doesn't exist, should result in an
  # exception
  def test_select_could_not_find_any_privilegeset
    controller_method = "select/could/not/find/any/privilegeset/get"
    assert_raise(RuntimeError) do
      Privilege.select(controller_method, :post)
    end
  end
end