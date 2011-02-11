
require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))
require 'spec'
require '../lib/cbac/cbac_pristine/pristine'
require '../lib/cbac/cbac_pristine/pristine_role'
require '../lib/cbac/cbac_pristine/pristine_permission'

include Cbac::CbacPristine

describe "CbacPristinePermission" do


  describe "convert pristine line to a yml fixture" do
    before(:each) do
      @context_role = PristineRole.new(:role_id => 0, :role_type => PristineRole.ROLE_TYPES[:context], :name => "logged_in_user")
      @admin_role = PristineRole.new(:role_id => 1, :role_type => PristineRole.ROLE_TYPES[:admin], :name => "administrator")
    end


    it "should raise an error if the pristine line has no role" do
      pristine_permission =  PristinePermission.new(:line_number => 1, :privilege_set_name => 'log_in', :pristine_role =>  nil)
      lambda{
        pristine_permission.to_yml_fixture
      }.should raise_error(ArgumentError)
    end

    it "should raise an error if the pristine line has no privilege_set_name" do
      pristine_permission =  PristinePermission.new(:line_number => 1, :privilege_set_name => "", :pristine_role => @context_role)
      lambda{
        pristine_permission.to_yml_fixture
      }.should raise_error(ArgumentError)
    end

    it "should return a yml string starting with cbac_permission_ " do
      pristine_permission =  PristinePermission.new(:line_number => 1, :privilege_set_name => "chat", :pristine_role => @context_role)

      pristine_permission.to_yml_fixture.should match(/\Acbac_permission_/)
    end

    it "should return a yml string containing the line number of the pristine line" do
      line_number= 100
      pristine_permission =  PristinePermission.new(:line_number => line_number, :privilege_set_name => "chat", :pristine_role => @context_role)

      pristine_permission.to_yml_fixture.should match(/id: #{line_number}/)
    end

    it "should return a yml string containing a generic role id of 0 if a context_role is used" do
      pristine_permission =  PristinePermission.new(:line_number => 150, :privilege_set_name => "chat", :pristine_role => @context_role)

      pristine_permission.to_yml_fixture.should match(/generic_role_id: 0/)
    end

    it "should return a yml string containing the name of the context role if a context_role is used" do
      pristine_permission =  PristinePermission.new(:line_number => 150, :privilege_set_name => "chat", :pristine_role => @context_role)

      pristine_permission.to_yml_fixture.should match(/context_role: #{@context_role.name}/)
    end

    it "should return a yml string containing the id of the generic role if a generic role is used" do
      pristine_permission =  PristinePermission.new(:line_number => 150, :privilege_set_name => "chat", :pristine_role => @admin_role)

      pristine_permission.to_yml_fixture.should match(/generic_role_id: #{@admin_role.id.to_s}/)
    end

    it "should return a yml string containing ruby code to find the privilege set by name" do
      pristine_permission =  PristinePermission.new(:line_number => 150, :privilege_set_name => "chat", :pristine_role => @context_role)

      pristine_permission.to_yml_fixture.should match(/privilege_set_id: \<%= Cbac::PrivilegeSetRecord.find\(:first, :conditions => \{:name => '#{pristine_permission.privilege_set_name}'\}\)\.id %>/)
    end

    it "should return a yml string containing created_at and updated_at" do
      pristine_permission =  PristinePermission.new(:line_number => 1, :privilege_set_name => "chat", :pristine_role => @context_role)
      pristine_permission.to_yml_fixture.should match(/created_at:.+updated_at:/m)
    end
  end

  describe "check if this pristine permission exists" do
    before(:each) do
      @privilege_set = Cbac::PrivilegeSetRecord.create(:name => "login")
      @admin_role = Cbac::GenericRole.create(:name => "administrator")

      @pristine_context_role = PristineRole.new(:role_id => 0, :role_type => PristineRole.ROLE_TYPES[:context], :name => "logged_in_user")
      @pristine_admin_role = PristineRole.new(:role_id => 1, :role_type => PristineRole.ROLE_TYPES[:admin],  :name => @admin_role.name)
    end

    it "should return true if the pristine permission exists as generic cbac permission in the database" do
      Cbac::Permission.create(:privilege_set_id => @privilege_set.id, :generic_role_id => @admin_role.id)
      
      pristine_permission =  PristinePermission.new(:privilege_set_name => @privilege_set.name, :pristine_role => @pristine_admin_role)

      pristine_permission.cbac_permission_exists?.should be_true
    end

    it "should return true if the pristine permission exists as context cbac permission in the database" do
      Cbac::Permission.create(:privilege_set_id => @privilege_set.id, :generic_role_id => 0, :context_role => @pristine_context_role.name)

      pristine_permission =  PristinePermission.new(:privilege_set_name => @privilege_set.name, :pristine_role => @pristine_context_role)

      pristine_permission.cbac_permission_exists?.should be_true
    end

    it "should return false if the pristine permission does not exist as context cbac permission in the database" do
      pristine_permission =  PristinePermission.new(:privilege_set_name => @privilege_set.name, :pristine_role => @pristine_context_role)

      pristine_permission.cbac_permission_exists?.should be_false
    end

    it "should return false if the pristine permission does not exist as a generic cbac permission in the database" do
      pristine_permission =  PristinePermission.new(:privilege_set_name => @privilege_set.name, :pristine_role => @pristine_admin_role)

      pristine_permission.cbac_permission_exists?.should be_false
    end

    it "should return false if a similar pristine permission exist as a generic cbac permission in the database, but for another generic role" do
      group_admin = Cbac::GenericRole.create(:name => "group_administrator")
      Cbac::Permission.create(:privilege_set_id => @privilege_set.id, :generic_role_id => group_admin.id)

      pristine_permission =  PristinePermission.new(:privilege_set_name => @privilege_set.name, :pristine_role => @pristine_admin_role)

      pristine_permission.cbac_permission_exists?.should be_false
    end

    it "should return false if a similar pristine permission exist as a context cbac permission in the database, but for another context role" do
      Cbac::Permission.create(:privilege_set_id => @privilege_set.id, :generic_role_id => 0, :context_role => "group_owner")

      pristine_permission =  PristinePermission.new(:privilege_set_name => @privilege_set.name, :pristine_role => @pristine_context_role)

      pristine_permission.cbac_permission_exists?.should be_false
    end
  end

  describe "check if a known permission exists for this pristine permission" do
     before(:each) do

      @pristine_context_role = PristineRole.new(:role_id => 0, :role_type => PristineRole.ROLE_TYPES[:context], :name => "logged_in_user")
      @pristine_admin_role = PristineRole.new(:role_id => 1, :role_type => PristineRole.ROLE_TYPES[:admin],  :name => "administrator")
    end

    it "should return true if the pristine permission exists as a known permission in the database" do
      pristine_permission =  PristinePermission.new(:pristine_role => @pristine_admin_role, :line_number => 4, :privilege_set_name => "not relevant")

      Cbac::KnownPermission.create(:permission_number => pristine_permission.line_number, :permission_type => Cbac::KnownPermission.PERMISSION_TYPES[:context])

      pristine_permission.known_permission_exists?.should be_true
    end
  end

  describe "apply the permission" do
    before(:each) do
      @privilege_set = Cbac::PrivilegeSetRecord.create(:name => "login")
      @admin_role = Cbac::GenericRole.create(:name => "administrator")

      @pristine_context_role = PristineRole.new(:role_id => 0, :role_type => PristineRole.ROLE_TYPES[:context], :name => "logged_in_user")
      @pristine_admin_role = PristineRole.new(:role_id => 1, :role_type => PristineRole.ROLE_TYPES[:admin], :name => @admin_role.name)
    end


    it "should add the context permission to the database if operation + is used" do
      pristine_permission =  PristinePermission.new(:privilege_set_name =>  @privilege_set.name, :pristine_role => @pristine_context_role)
      pristine_permission.operation = '+'

      proc {
        pristine_permission.accept
      }.should change(Cbac::Permission, :count).by(1)
    end

    it "should create a generic permission if operation + is used" do
      pristine_permission =  PristinePermission.new(:privilege_set_name => @privilege_set.name, :pristine_role => @pristine_admin_role)
      pristine_permission.operation = '+'

      proc {
        pristine_permission.accept
      }.should change(Cbac::Permission, :count).by(1)
    end

    it "should delete the pristine permission since it was accepted" do
      pristine_permission =  PristinePermission.create(:privilege_set_name => @privilege_set.name, :pristine_role => @pristine_admin_role, :operation => '+')

      proc {
        pristine_permission.accept
      }.should change(PristinePermission, :count).by(-1)
    end

    it "should create a generic role if it doesn't exist in yet" do
      cbac_privilege_set = Cbac::PrivilegeSetRecord.create(:name => "cbac_administration")

      cbac_admin_role = PristineRole.new(:role_id => 1, :role_type => PristineRole.ROLE_TYPES[:generic], :name => "cbac_administrator")
      pristine_permission =  PristinePermission.new(:privilege_set_name => cbac_privilege_set.name, :pristine_role => cbac_admin_role)
      pristine_permission.operation = '+'

      proc {
        pristine_permission.accept
      }.should change(Cbac::GenericRole, :count).by(1)
    end

    it "should use an existing role if possible" do
      pristine_permission =  PristinePermission.new(:privilege_set_name => @privilege_set.name, :pristine_role => @pristine_admin_role)
      pristine_permission.operation = '+'

      pristine_permission.accept
      # test smell: depends on a clean database
      cbac_permission = Cbac::Permission.first

      cbac_permission.generic_role.should == @admin_role
    end

    it "should remove an existing permission if operation - is used" do
      Cbac::Permission.create(:privilege_set_id => @privilege_set.id, :generic_role_id => 0, :context_role => @pristine_context_role.name)

      pristine_permission =  PristinePermission.new(:privilege_set_name => @privilege_set.name, :pristine_role => @pristine_context_role)
      pristine_permission.operation = '-'

      proc {
        pristine_permission.accept
      }.should change(Cbac::Permission, :count).by(-1)
    end

    it "should raise an error if operation - is used and the permission does not exist" do
      pristine_permission =  PristinePermission.new(:privilege_set_name => @privilege_set.name, :pristine_role => @pristine_context_role)
      pristine_permission.operation = '-'

      proc {
        pristine_permission.accept
      }.should raise_error(ArgumentError)
    end

    it "should create a known permission to record a change" do
      pristine_permission =  PristinePermission.new(:privilege_set_name =>  @privilege_set.name, :pristine_role => @pristine_context_role)
      pristine_permission.operation = '+'

      proc {
        pristine_permission.accept
      }.should change(Cbac::KnownPermission, :count).by(1)
    end

    it "should create a known permission with specified permission identifier" do
      pristine_permission =  PristinePermission.new(:privilege_set_name => @privilege_set.name, :pristine_role => @pristine_context_role)
      pristine_permission.operation = '+'

      pristine_permission.accept

      known_permission = Cbac::KnownPermission.last

      known_permission.permission_number.should == pristine_permission.line_number
    end

    it "should create a known permission with specified role type" do
      pristine_permission =  PristinePermission.new(:privilege_set_name => @privilege_set.name, :pristine_role => @pristine_context_role)
      pristine_permission.operation = '+'

      pristine_permission.accept

      known_permission = Cbac::KnownPermission.last

      known_permission.permission_type.should == Cbac::KnownPermission.PERMISSION_TYPES[:context]
    end

    it "should also create a known permission if operation - is used to revoke a permission" do
      Cbac::Permission.create(:privilege_set_id => @privilege_set.id, :generic_role_id => 0, :context_role => @pristine_context_role.name)

      pristine_permission =  PristinePermission.new(:privilege_set_name => @privilege_set.name, :pristine_role => @pristine_context_role)
      pristine_permission.operation = '-'

      proc {
        pristine_permission.accept
      }.should change(Cbac::KnownPermission, :count).by(1)
    end
  end

  describe "stage the permission so it can be applied" do
    before(:each) do
      @pristine_context_role = PristineRole.new(:role_id => 0, :role_type => PristineRole.ROLE_TYPES[:context], :name => "logged_in_user")
      @pristine_admin_role = PristineRole.new(:role_id => 1, :role_type => PristineRole.ROLE_TYPES[:admin], :name => "administrator")
    end

    it "should persist the pristine permission to the database" do
      pristine_permission =  PristinePermission.new(:privilege_set_name => "login", :pristine_role => @pristine_context_role, :operation => '+')

      proc {
        pristine_permission.stage
      }.should change(Cbac::CbacPristine::PristinePermission, :count).by(1)

    end

    it "should persist the associated role if it doesn't exist yet" do
      pristine_permission =  PristinePermission.new(:privilege_set_name => "login", :pristine_role => @pristine_context_role, :operation => '+')

      proc {
        pristine_permission.stage
      }.should change(Cbac::CbacPristine::PristineRole, :count).by(1)
    end

    it "should not create a new pristine permission if the cbac permission exists and the pristine permission wants to add" do
      privilege_set = Cbac::PrivilegeSetRecord.create(:name => "login")
      Cbac::Permission.create(:privilege_set_id => privilege_set.id, :generic_role_id => 0, :context_role => @pristine_context_role.name)

      pristine_permission =  PristinePermission.new(:operation => '+', :privilege_set_name => privilege_set.name, :pristine_role => @pristine_context_role)
      proc {
        pristine_permission.stage
      }.should_not change(Cbac::CbacPristine::PristinePermission, :count)
    end

    it "should create a new pristine permission if the cbac permission exists and the pristine permission wants to revoke" do
      privilege_set = Cbac::PrivilegeSetRecord.create(:name => "login")
      Cbac::Permission.create(:privilege_set_id => privilege_set.id, :generic_role_id => 0, :context_role => @pristine_context_role.name)

      pristine_permission =  PristinePermission.new(:operation => '-', :privilege_set_name => privilege_set.name, :pristine_role => @pristine_context_role)
      proc {
        pristine_permission.stage
      }.should change(Cbac::CbacPristine::PristinePermission, :count).by(1)
    end

    it "should not create a new pristine permission if a staged add permission exists and this pristine permission wants to revoke" do
      privilege_set_name = "chat"
      PristinePermission.new(:operation => '+', :privilege_set_name => privilege_set_name, :pristine_role => @pristine_context_role)
      pristine_revoke_permission =  PristinePermission.new(:operation => '-', :privilege_set_name => privilege_set_name, :pristine_role => @pristine_context_role)

      proc {
        pristine_revoke_permission.stage
      }.should_not change(Cbac::CbacPristine::PristinePermission, :count).by(1)
    end

    it "should delete a staged add permission if the pristine permission wants to revoke the same permission" do
      privilege_set_name = "chat"
      PristinePermission.create(:operation => '+', :privilege_set_name => privilege_set_name, :pristine_role => @pristine_context_role)
      pristine_revoke_permission =  PristinePermission.new(:operation => '-', :privilege_set_name => privilege_set_name, :pristine_role => @pristine_context_role)

      proc {
        pristine_revoke_permission.stage
      }.should change(Cbac::CbacPristine::PristinePermission, :count).by(-1)
    end

    it "should not create a new pristine permission if a cbac known permission exists" do
      known_number = 1
      pristine_permission =  PristinePermission.new(:line_number => known_number, :privilege_set_name => "name not relevant", :pristine_role => @pristine_context_role)
      Cbac::KnownPermission.create(:permission_number => known_number, :permission_type => Cbac::KnownPermission.PERMISSION_TYPES[:context])

      proc {
        pristine_permission.stage
      }.should_not change(Cbac::CbacPristine::PristinePermission, :count)

    end

    it "should raise an error if the same pristine permission is staged twice" do
      privilege_set_name = "chat"
      PristinePermission.create(:operation => '+', :privilege_set_name => privilege_set_name, :pristine_role => @pristine_context_role, :line_number => 2)
      pristine_permission =  PristinePermission.new(:operation => '+', :privilege_set_name => privilege_set_name, :pristine_role => @pristine_context_role, :line_number => 3)

      proc {
        pristine_permission.stage
      }.should raise_error(ArgumentError)
    end


  end

end

