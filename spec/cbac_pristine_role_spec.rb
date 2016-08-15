require 'spec_helper'

include Cbac::CbacPristine

describe "CbacPristineRole" do
  describe "convert pristine role to a yml fixture" do
    it "returns an empty string if the pristine role is of type :context" do
      pristine_role = PristineRole.new(:role_id => 0, :role_type => PristineRole.ROLE_TYPES[:context], :name => "name is irrelevant")

      expect(pristine_role.to_yml_fixture).to be_empty
    end

    it "raises an error if the role name is not specified" do
      pristine_role = PristineRole.new(:role_id => 0, :role_type => PristineRole.ROLE_TYPES[:admin], :name => "")

      expect(proc{
        pristine_role.to_yml_fixture
      }).to raise_error(ArgumentError)
    end

    it "returns a yml string starting with cbac_generic_role_ " do
      pristine_role = PristineRole.new(:role_id => 0, :role_type => PristineRole.ROLE_TYPES[:generic], :name => "name is irrelevant")

      expect(pristine_role.to_yml_fixture).to match(/\Acbac_generic_role_/)
    end

    it "returns a yml string containing the id of the pristine role" do
      role_id = 100
      pristine_role = PristineRole.new(:role_id => role_id, :role_type => PristineRole.ROLE_TYPES[:generic], :name => "name is irrelevant")

      expect(pristine_role.to_yml_fixture).to match(/id: #{role_id}/)
    end

    it "returns a yml string containing the name of the pristine role" do
      name = "Administrator"
      pristine_role = PristineRole.new(:role_id => 0, :role_type => PristineRole.ROLE_TYPES[:generic], :name => name)

      expect(pristine_role.to_yml_fixture).to match(/name: #{name}/)
    end

    it "returns a yml string containing created_at and updated_at" do
      pristine_role = PristineRole.new(:role_id => 0, :role_type => PristineRole.ROLE_TYPES[:generic], :name => "name is irrelevant")

      expect(pristine_role.to_yml_fixture).to match(/created_at:.+updated_at:/m)
    end
  end

  describe "admin role" do
    it "returns a role with the admin role_type" do
      admin_role = PristineRole.admin_role

      expect(admin_role.role_type).to eq(PristineRole.ROLE_TYPES[:admin])
    end

    it "returns a new admin role if the role does not exist in the database" do
      admin_role = PristineRole.admin_role

      expect(admin_role.id).to be_nil
    end

    it "returns an existing admin role if possible" do
      existing_admin_role = PristineRole.create(:role_id => 0, :role_type => PristineRole.ROLE_TYPES[:admin], :name => "administrator")
      admin_role = PristineRole.admin_role

      expect(admin_role).to eq(existing_admin_role)
    end

    it "does not return an existing admin role if database should not be used" do
      existing_admin_role = PristineRole.create(:role_id => 0, :role_type => PristineRole.ROLE_TYPES[:admin], :name => "administrator")
      admin_role = PristineRole.admin_role(false)

      expect(admin_role).not_to eq(existing_admin_role)
      expect(admin_role.id).to be_nil
    end
  end
end

