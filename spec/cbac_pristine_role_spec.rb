require 'spec_helper'

include Cbac::CbacPristine

describe "CbacPristineRole" do

  describe "convert pristine role to a yml fixture" do
    it "should return an empty string if the pristine role is of type :context" do
      pristine_role = PristineRole.new(:role_id => 0, :role_type => PristineRole.ROLE_TYPES[:context], :name => "name is irrelevant")

      pristine_role.to_yml_fixture.should be_empty
    end

    it "should raise an error if the role name is not specified" do
      pristine_role = PristineRole.new(:role_id => 0, :role_type => PristineRole.ROLE_TYPES[:admin], :name => "")

      proc{
        pristine_role.to_yml_fixture
      }.should raise_error(ArgumentError)
    end


    it "should return a yml string starting with cbac_generic_role_ " do
      pristine_role = PristineRole.new(:role_id => 0, :role_type => PristineRole.ROLE_TYPES[:generic], :name => "name is irrelevant")

      pristine_role.to_yml_fixture.should match(/\Acbac_generic_role_/)
    end

    it "should return a yml string containing the id of the pristine role" do
      role_id = 100
      pristine_role = PristineRole.new(:role_id => role_id, :role_type => PristineRole.ROLE_TYPES[:generic], :name => "name is irrelevant")

      pristine_role.to_yml_fixture.should match(/id: #{role_id}/)
    end

    it "should return a yml string containing the name of the pristine role" do
      name = "Administrator"
      pristine_role = PristineRole.new(:role_id => 0, :role_type => PristineRole.ROLE_TYPES[:generic], :name => name)
      pristine_role.to_yml_fixture.should match(/name: #{name}/)
    end

    it "should return a yml string containing created_at and updated_at" do
      pristine_role = PristineRole.new(:role_id => 0, :role_type => PristineRole.ROLE_TYPES[:generic], :name => "name is irrelevant")

      pristine_role.to_yml_fixture.should match(/created_at:.+updated_at:/m)
    end
  end

  describe "admin role" do
    it "should return a role with the admin role_type" do
      admin_role = PristineRole.admin_role

      admin_role.role_type.should == PristineRole.ROLE_TYPES[:admin]
    end

    it "should return a new admin role if the role does not exist in the database" do
      admin_role = PristineRole.admin_role

      admin_role.id.should be_nil
    end

    it "should return an existing admin role if possible" do
      existing_admin_role = PristineRole.create(:role_id => 0, :role_type => PristineRole.ROLE_TYPES[:admin], :name => "administrator")

      admin_role = PristineRole.admin_role

      admin_role.should == existing_admin_role
    end

    it "should not return an existing admin role if database should not be used" do
      existing_admin_role = PristineRole.create(:role_id => 0, :role_type => PristineRole.ROLE_TYPES[:admin], :name => "administrator")

      admin_role = PristineRole.admin_role(false)

      admin_role.should_not == existing_admin_role
      admin_role.id.should be_nil
    end
  end



end

