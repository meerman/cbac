# Copyright 2010 Bert Meerman
require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

###
# Tests the Cbac::PrivilegeSet class
#
class CbacPrivilegeSetTest <  ActiveSupport::TestCase
  #self.fixture_path = File.join(File.dirname(__FILE__), "fixtures")
  #fixtures :all

  # Adds a new privilege to the PrivilegeSet.
  # This test should add a new privilege and everything should be working.
  def test_adding_new_privilege_set
    comment = "test_adding_new_privilege_set"
    assert_difference("PrivilegeSet.sets.length", 1, "Adding test PrivilegeSet") do
      PrivilegeSet.add :test_adding_new_privilege_set, comment
    end
    assert_equal(true, PrivilegeSet.sets.include?(:test_adding_new_privilege_set), "PrivilegeSet symbol not found.")
    assert_equal(comment, PrivilegeSet.sets[:test_adding_new_privilege_set].comment, "Incorrect comment.")
  end

  # When adding an already existing PrivilegeSet, an ArgumentError should be raised.
  # PrivilegeSets can only be declared once.
  def test_adding_double_privilege_sets
    PrivilegeSet.add :test_adding_double_privilege_sets, ""
    assert_raise(ArgumentError) do
      PrivilegeSet.add :test_adding_double_privilege_sets, ""
    end
  end

  # This privilegeset is already in the database. The id
  # should therefore be identical to the id specified in the fixture.
  # Also, the number of records should not change.
  def test_initializing_existing_privilege_set
    assert_difference("PrivilegeSet.sets.length", 1, "Adding test PrivilegeSet") do
      assert_difference("Cbac::PrivilegeSetRecord.find(:all).length", 0, "Record should have been added to table") do
        PrivilegeSet.add :existing_privilege_set, "Something"
      end
    end
  end

  # This privilegeset does not yet exist. A new entry should be created
  # in the database. Also, the id should not be zero.
  def test_initializing_new_privilege_set
    assert_difference("PrivilegeSet.sets.length", 1, "Adding test PrivilegeSet") do
      assert_difference("Cbac::PrivilegeSetRecord.find(:all).length", 1, "Record should not be added to table - record already exists") do
        PrivilegeSet.add :test_initializing_new_privilege_set, "Something"
      end
    end
  end
end