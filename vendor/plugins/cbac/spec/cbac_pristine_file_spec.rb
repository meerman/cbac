require 'spec'
require 'cbac/cbac_pristine/pristine_permission'
require 'cbac/cbac_pristine/pristine_role'
require 'cbac/cbac_pristine/pristine_file'
require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))
include Cbac::CbacPristine

describe "CbacPristineFile" do
  before(:each) do
      @pristine_file = PristineFile.new("cbac.pristine")
  end

  describe "indicate if a line looks like a pristine line" do
    
    it "should indicate that a ruby style comment line is not a pristine line" do
      comment_line = "#this is a comment line in Ruby"

      @pristine_file.is_pristine_permission_line?(comment_line, 1).should be_false
    end

    it "should raise an error if the line does not look like a pristine line" do
      line = "this is not pristine line. And it isn't a comment. 1"

      proc{
        @pristine_file.is_pristine_permission_line?(line, 0)
      }.should raise_error(SyntaxError)
    end

    it "should return true in case of a valid pristine line" do
      line = "0:+:PrivilegeSet(login)ContextRole(everybody)"

      @pristine_file.is_pristine_permission_line?(line, 0).should be_true
    end

    it "should fail if the id of the pristine line contains a character" do
      line = "0b:+:PrivilegeSet(login)ContextRole(everybody)"

      proc{
        @pristine_file.is_pristine_permission_line?(line, 0)
      }.should raise_error(SyntaxError)
      end

    it "should succeed if the privilege set name is not provided" do
      line = "0:+:PrivilegeSet()Admin()"

      @pristine_file.is_pristine_permission_line?(line, 0).should be_true
    end

    it "should succeed if the context role name is not provided" do
      line = "0:+:PrivilegeSet(login)ContextRole()"

      @pristine_file.is_pristine_permission_line?(line, 0).should be_true
    end

  end

  describe "parse the privilege set name from a pristine line" do
    it "should fail if the privilege set name is not provided" do
      line = "0:+:PrivilegeSet()Admin()"

      proc{
        @pristine_file.parse_privilege_set_name(line, 0)
      }.should raise_error(SyntaxError)
    end

    it "should return the name of the privilege set provided in the line" do
      privilege_set_name = "chat"
      line = "0:+:PrivilegeSet(#{privilege_set_name})Admin()"

      @pristine_file.parse_privilege_set_name(line, 0).should == privilege_set_name      
    end

    it "should fail if an invalid line is provided" do
      line = "0:+:ContextRole(toeteraars)"

      proc{
          @pristine_file.parse_privilege_set_name(line, 0)
      }.should raise_error(SyntaxError)
    end
  end

  describe "parse the role from a pristine line" do
    it "should return the admin role if the role is Admin()" do
      admin_role = PristineRole.new(:role_id => 0, :role_type => PristineRole.ROLE_TYPES[:admin], :name => 'administrators')
      PristineRole.stub!(:admin_role).and_return(admin_role)
      line = "0:+:PrivilegeSet(chat)Admin()"

      @pristine_file.parse_role(line, 0).should == admin_role
    end

    it "should return a context role if the role specified as ContextRole" do
      line = "0:+:PrivilegeSet(chat)ContextRole(logged_in_user)"

      @pristine_file.parse_role(line, 0).role_type.should == PristineRole.ROLE_TYPES[:context]
    end

    it "should return a context role with specified name if the role specified as ContextRole" do
      context_role_name = "logged_in_user"
      line = "0:+:PrivilegeSet(chat)ContextRole(#{context_role_name})"

      @pristine_file.parse_role(line, 0).name.should == context_role_name
    end

    it "should return an existing context role with specified name if possible" do
      context_role_name = "logged_in_user"
      line = "0:+:PrivilegeSet(chat)ContextRole(#{context_role_name})"
      existing_context_role = PristineRole.create(:name => context_role_name, :role_id => 0, :role_type => PristineRole.ROLE_TYPES[:context])

      @pristine_file.parse_role(line, 0).should == existing_context_role
    end

    it "should not return an existing context role with specified name if db should not be used" do
      context_role_name = "logged_in_user"
      line = "0:+:PrivilegeSet(chat)ContextRole(#{context_role_name})"
      existing_context_role = PristineRole.create(:name => context_role_name, :role_id => 0, :role_type => PristineRole.ROLE_TYPES[:context])

      @pristine_file.parse_role(line, 0, false).should_not == existing_context_role
    end

    it "should return a context role with id of 0 if the role specified as ContextRole" do
      line = "0:+:PrivilegeSet(chat)ContextRole(logged_in_user)"

      @pristine_file.parse_role(line, 0).role_id.should == 0
    end

    it "should fail if an invalid line is provided" do
      line = "0:+:PrivilegeSet(toeteraars)"

      proc{
           @pristine_file.parse_role(line, 0)
      }.should raise_error(SyntaxError)
    end

    it "should fail if a generic role is provided for the normal (non-generic) pristine file" do
      line = "0:+:PrivilegeSet(chat)GenericRole(group_admins)"

      proc{
           @pristine_file.parse_role(line, 0)
      }.should raise_error(SyntaxError)
    end


    it "should return a generic role if a generic pristine file is used" do
      @pristine_file = GenericPristineFile.new("cbac.pristine")
      line = "0:+:PrivilegeSet(chat)GenericRole(group_admins)"

      @pristine_file.parse_role(line, 0).role_type.should == PristineRole.ROLE_TYPES[:generic]
    end

    it "should return an existing generic role if use_db is not specified" do
      generic_role_name = 'group_admins'
      @pristine_file = GenericPristineFile.new("cbac.pristine")
      line = "0:+:PrivilegeSet(chat)GenericRole(#{generic_role_name})"
      existing_role = PristineRole.create(:role_id => 1, :role_type => PristineRole.ROLE_TYPES[:generic], :name => generic_role_name)

      @pristine_file.parse_role(line, 0).should == existing_role
    end

    it "should not use an existing role if use_db is set to false" do
      generic_role_name = 'group_admins'
      @pristine_file = GenericPristineFile.new("cbac.pristine")
      line = "0:+:PrivilegeSet(chat)GenericRole(#{generic_role_name})"
      existing_role = PristineRole.create(:role_id => 1, :role_type => PristineRole.ROLE_TYPES[:generic], :name => generic_role_name)

      @pristine_file.parse_role(line, 0, false).should_not == existing_role
    end

    it "should fail if an Admin role is used in a generic pristine file" do
      @pristine_file = GenericPristineFile.new("cbac.pristine")
      line = "0:+:PrivilegeSet(chat)Admin()"

      proc{
           @pristine_file.parse_role(line, 0)
      }.should raise_error(SyntaxError)
    end

    it "should fail if an context role is used in a generic pristine file" do
      @pristine_file = GenericPristineFile.new("cbac.pristine")
      line = "0:+:PrivilegeSet(chat)ContextRole(logged_in_user)"

      proc{
           @pristine_file.parse_role(line, 0)
      }.should raise_error(SyntaxError)
    end

    it "should fail if an invalid line is provided in a generic pristine file" do
      @pristine_file = GenericPristineFile.new("cbac.pristine")
      line = "0:+:PrivilegeSet(toeteraars)"

      proc{
           @pristine_file.parse_role(line, 0)
      }.should raise_error(SyntaxError)
    end
  end

  describe "parsing a cbac_pristine file" do

    it "should fail if a row number is used twice" do
      pristine_file_lines = ["0:+:PrivilegeSet(chat)ContextRole(logged_in_user)"]
      pristine_file_lines.push("0:+:PrivilegeSet(log_in)ContextRole(everybody)")
      
      File.stub!(:open).and_return(pristine_file_lines)

      pristine_file = PristineFile.new("cbac.pristine")

      proc{
        pristine_file.parse
      }.should raise_error(SyntaxError)
    end

    it "should fill the lines array with an object for each file line" do
      pristine_file_lines = ["0:+:PrivilegeSet(chat)ContextRole(logged_in_user)"]
      pristine_file_lines.push("1:+:PrivilegeSet(log_in)ContextRole(everybody)")
      pristine_file_lines.push("2:+:PrivilegeSet(log_out)ContextRole(logged_in_user)")

      File.stub!(:open).and_return(pristine_file_lines)

      pristine_file = PristineFile.new("cbac.pristine")
      pristine_file.parse

      pristine_file.permissions.length.should == pristine_file_lines.length
    end

    it "should not create an object for a comment line" do
      pristine_file_lines = ["0:+:PrivilegeSet(chat)ContextRole(logged_in_user)"]
      pristine_file_lines.push("1:+:PrivilegeSet(log_in)ContextRole(everybody)")
      pristine_file_lines.push("#this is a Ruby comment line")

      File.stub!(:open).and_return(pristine_file_lines)

      pristine_file = PristineFile.new("cbac.pristine")
      pristine_file.parse

      pristine_file.permissions.length.should == 2
    end

    it "should also add a permission object if permission is revoked (operand - is used)" do
      pristine_file_lines = ["0:+:PrivilegeSet(chat)ContextRole(logged_in_user)"]
      pristine_file_lines.push("1:+:PrivilegeSet(log_in)ContextRole(everybody)")
      pristine_file_lines.push("2:-:PrivilegeSet(chat)ContextRole(logged_in_user)")

      File.stub!(:open).and_return(pristine_file_lines)

      pristine_file = PristineFile.new("cbac.pristine")
      pristine_file.parse

      pristine_file.permissions.length.should == 3
      pristine_file.permissions[2].operand.should == '-'
    end

    it "should fail if a permission is revoked which wasn't added before" do
      pristine_file_lines = ["0:+:PrivilegeSet(chat)ContextRole(logged_in_user)"]
      pristine_file_lines.push("1:+:PrivilegeSet(log_in)ContextRole(everybody)")
      pristine_file_lines.push("2:-:PrivilegeSet(chat)ContextRole(everybody)")

      File.stub!(:open).and_return(pristine_file_lines)

      pristine_file = PristineFile.new("cbac.pristine")
      proc{
        pristine_file.parse
      }.should raise_error(SyntaxError)
    end

    it "should fail if an x is used as an operand" do
      pristine_file_lines = ["0:x:PrivilegeSet(chat)ContextRole(logged_in_user)"]
      File.stub!(:open).and_return(pristine_file_lines)

      pristine_file = PristineFile.new("cbac.pristine")
      proc{
        pristine_file.parse
      }.should raise_error(NotImplementedError)
    end

    it "should fail if an => is used as an operand" do
      pristine_file_lines = ["0:=>:PrivilegeSet(chat)ContextRole(logged_in_user)"]
      File.stub!(:open).and_return(pristine_file_lines)

      pristine_file = PristineFile.new("cbac.pristine")
      proc{
        pristine_file.parse
      }.should raise_error(NotImplementedError)
    end
  end

  describe "permission set" do
    before(:each) do
      @context_role = PristineRole.new(:role_id => 0, :role_type => PristineRole.ROLE_TYPES[:context], :name => "logged_in_user")
      @admin_role = PristineRole.new(:role_id => 1, :role_type => PristineRole.ROLE_TYPES[:admin],:name => "administrator")
      @pristine_file = PristineFile.new("cbac.pristine")
    end

    it "should filter out the permissions which were revoked" do
      permission_to_revoke = PristinePermission.new(:privilege_set_name => "chat", :pristine_role => @context_role, :operand => '+')
      @pristine_file.permissions.push(permission_to_revoke)
      @pristine_file.permissions.push(PristinePermission.new(:privilege_set_name => permission_to_revoke.privilege_set_name, :pristine_role => permission_to_revoke.pristine_role, :operand => '-'))

      @pristine_file.permission_set.should_not include(permission_to_revoke)
    end

     it "should not include the revoke permission itself" do
      revoke_permission = PristinePermission.new(:privilege_set_name => "chat", :pristine_role => @context_role, :operand => '-')
      @pristine_file.permissions.push(PristinePermission.new(:privilege_set_name => revoke_permission.privilege_set_name, :pristine_role => revoke_permission.pristine_role, :operand => '+'))
      @pristine_file.permissions.push(revoke_permission)

      @pristine_file.permission_set.should_not include(revoke_permission)
    end

    it "should contain the permission if it is re-applied" do
      re_applied_permission = PristinePermission.new(:privilege_set_name => "chat", :pristine_role => @context_role, :operand => '+')
      @pristine_file.permissions.push(PristinePermission.new(:privilege_set_name => re_applied_permission.privilege_set_name, :pristine_role => re_applied_permission.pristine_role, :operand => '+'))
      @pristine_file.permissions.push(PristinePermission.new(:privilege_set_name =>  re_applied_permission.privilege_set_name, :pristine_role => re_applied_permission.pristine_role, :operand => '-'))
      @pristine_file.permissions.push(re_applied_permission)

      @pristine_file.permission_set.should include(re_applied_permission)
    end

    it "should raise an error if a permission is revoked which wasn't created before" do
      @pristine_file.permissions.push(PristinePermission.new(:privilege_set_name =>  "chat", :pristine_role => @context_role, :operand => '+'))
      @pristine_file.permissions.push(PristinePermission.new(:privilege_set_name =>  "login", :pristine_role => @context_role, :operand =>  '+'))
      @pristine_file.permissions.push(PristinePermission.new(:privilege_set_name =>  "blog_read", :pristine_role => @context_role, :operand =>  '-'))
      @pristine_file.permissions.push(PristinePermission.new(:privilege_set_name =>  "update_blog", :pristine_role => @context_role, :operand => '+'))

      proc {
        @pristine_file.permission_set
      }.should raise_error(ArgumentError)

    end
  end
end