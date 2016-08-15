require 'spec_helper'

include Cbac::CbacPristine

describe "CbacPristineFile" do
  before(:each) do
    @pristine_file = PristineFile.new(:file_name =>"cbac.pristine")
  end

  describe "indicate if a line looks like a pristine line" do
    it "indicates that a ruby style comment line is not a pristine line" do
      comment_line = "#this is a comment line in Ruby"

      expect(@pristine_file.is_pristine_permission_line?(comment_line, 1)).to be_falsy
    end

    it "raises an error if the line does not look like a pristine line" do
      line = "this is not pristine line. And it isn't a comment. 1"

      expect(proc{
        @pristine_file.is_pristine_permission_line?(line, 0)
      }).to raise_error(SyntaxError)
    end

    it "returns true in case of a valid pristine line" do
      line = "0:+:PrivilegeSet(login)ContextRole(everybody)"

      expect(@pristine_file.is_pristine_permission_line?(line, 0)).to be_truthy
    end

    it "fails if the id of the pristine line contains a character" do
      line = "0b:+:PrivilegeSet(login)ContextRole(everybody)"

      expect(proc{
        @pristine_file.is_pristine_permission_line?(line, 0)
      }).to raise_error(SyntaxError)
      end

    it "succeeds if the privilege set name is not provided" do
      line = "0:+:PrivilegeSet()Admin()"

      expect(@pristine_file.is_pristine_permission_line?(line, 0)).to be_truthy
    end

    it "succeeds if the context role name is not provided" do
      line = "0:+:PrivilegeSet(login)ContextRole()"

      expect(@pristine_file.is_pristine_permission_line?(line, 0)).to be_truthy
    end

  end

  describe "parse the privilege set name from a pristine line" do
    it "fails if the privilege set name is not provided" do
      line = "0:+:PrivilegeSet()Admin()"

      expect(proc{
        @pristine_file.parse_privilege_set_name(line, 0)
      }).to raise_error(SyntaxError)
    end

    it "returns the name of the privilege set provided in the line" do
      privilege_set_name = "chat"
      line = "0:+:PrivilegeSet(#{privilege_set_name})Admin()"

      expect(@pristine_file.parse_privilege_set_name(line, 0)).to eq(privilege_set_name)
    end

    it "fails if an invalid line is provided" do
      line = "0:+:ContextRole(toeteraars)"

      expect(proc{
          @pristine_file.parse_privilege_set_name(line, 0)
      }).to raise_error(SyntaxError)
    end
  end

  describe "parse the role from a pristine line" do
    it "returns the admin role if the role is Admin()" do
      admin_role = PristineRole.new(:role_id => 0, :role_type => PristineRole.ROLE_TYPES[:admin], :name => 'administrator')
      allow(PristineRole).to receive(:admin_role).and_return(admin_role)
      line = "0:+:PrivilegeSet(chat)Admin()"

      expect(@pristine_file.parse_role(line, 0)).to eq(admin_role)
    end

    it "returns a context role if the role specified as ContextRole" do
      line = "0:+:PrivilegeSet(chat)ContextRole(logged_in_user)"

      expect(@pristine_file.parse_role(line, 0).role_type).to eq(PristineRole.ROLE_TYPES[:context])
    end

    it "returns a context role with specified name if the role specified as ContextRole" do
      context_role_name = "logged_in_user"
      line = "0:+:PrivilegeSet(chat)ContextRole(#{context_role_name})"

      expect(@pristine_file.parse_role(line, 0).name).to eq(context_role_name)
    end

    it "returns an existing context role with specified name if possible" do
      context_role_name = "logged_in_user"
      line = "0:+:PrivilegeSet(chat)ContextRole(#{context_role_name})"
      existing_context_role = PristineRole.create(:name => context_role_name, :role_id => 0, :role_type => PristineRole.ROLE_TYPES[:context])

      expect(@pristine_file.parse_role(line, 0)).to eq(existing_context_role)
    end

    it "does not return an existing context role with specified name if db should not be used" do
      context_role_name = "logged_in_user"
      line = "0:+:PrivilegeSet(chat)ContextRole(#{context_role_name})"
      existing_context_role = PristineRole.create(:name => context_role_name, :role_id => 0, :role_type => PristineRole.ROLE_TYPES[:context])

      expect(@pristine_file.parse_role(line, 0, false)).not_to eq(existing_context_role)
    end

    it "returns a context role with id of 0 if the role specified as ContextRole" do
      line = "0:+:PrivilegeSet(chat)ContextRole(logged_in_user)"

      expect(@pristine_file.parse_role(line, 0).role_id).to eq(0)
    end

    it "fails if an invalid line is provided" do
      line = "0:+:PrivilegeSet(toeteraars)"

      expect(proc{
           @pristine_file.parse_role(line, 0)
      }).to raise_error(SyntaxError)
    end

    it "fails if a generic role is provided for the normal (non-generic) pristine file" do
      line = "0:+:PrivilegeSet(chat)GenericRole(group_admins)"

      expect(proc{
           @pristine_file.parse_role(line, 0)
      }).to raise_error(SyntaxError)
    end

    it "returns a generic role if a generic pristine file is used" do
      @pristine_file = GenericPristineFile.new(:file_name =>"cbac.pristine")
      line = "0:+:PrivilegeSet(chat)GenericRole(group_admins)"

      expect(@pristine_file.parse_role(line, 0).role_type).to eq(PristineRole.ROLE_TYPES[:generic])
    end

    it "returns an existing generic role if use_db is not specified" do
      generic_role_name = 'group_admins'
      @pristine_file = GenericPristineFile.new(:file_name =>"cbac.pristine")
      line = "0:+:PrivilegeSet(chat)GenericRole(#{generic_role_name})"
      existing_role = PristineRole.create(:role_id => 1, :role_type => PristineRole.ROLE_TYPES[:generic], :name => generic_role_name)

      expect(@pristine_file.parse_role(line, 0)).to eq(existing_role)
    end

    it "does not use an existing role if use_db is set to false" do
      generic_role_name = 'group_admins'
      @pristine_file = GenericPristineFile.new(:file_name =>"cbac.pristine")
      line = "0:+:PrivilegeSet(chat)GenericRole(#{generic_role_name})"
      existing_role = PristineRole.create(:role_id => 1, :role_type => PristineRole.ROLE_TYPES[:generic], :name => generic_role_name)

      expect(@pristine_file.parse_role(line, 0, false)).not_to eq(existing_role)
    end

    it "fails if an Admin role is used in a generic pristine file" do
      @pristine_file = GenericPristineFile.new(:file_name =>"cbac.pristine")
      line = "0:+:PrivilegeSet(chat)Admin()"

      expect(proc{
           @pristine_file.parse_role(line, 0)
      }).to raise_error(SyntaxError)
    end

    it "fails if an context role is used in a generic pristine file" do
      @pristine_file = GenericPristineFile.new(:file_name =>"cbac.pristine")
      line = "0:+:PrivilegeSet(chat)ContextRole(logged_in_user)"

      expect(proc{
           @pristine_file.parse_role(line, 0)
      }).to raise_error(SyntaxError)
    end

    it "fails if an invalid line is provided in a generic pristine file" do
      @pristine_file = GenericPristineFile.new(:file_name =>"cbac.pristine")
      line = "0:+:PrivilegeSet(toeteraars)"

      expect(proc{
           @pristine_file.parse_role(line, 0)
      }).to raise_error(SyntaxError)
    end
  end

  describe "parsing a cbac_pristine file" do
    it "fails if a row number is used twice" do
      pristine_file_lines = ["0:+:PrivilegeSet(chat)ContextRole(logged_in_user)"]
      pristine_file_lines.push("0:+:PrivilegeSet(log_in)ContextRole(everybody)")

      allow(File).to receive(:open).and_return(pristine_file_lines)

      pristine_file = PristineFile.new(:file_name =>"cbac.pristine")

      expect(proc{
        pristine_file.parse
      }).to raise_error(SyntaxError)
    end

    it "fills the lines array with an object for each file line" do
      pristine_file_lines = ["0:+:PrivilegeSet(chat)ContextRole(logged_in_user)"]
      pristine_file_lines.push("1:+:PrivilegeSet(log_in)ContextRole(everybody)")
      pristine_file_lines.push("2:+:PrivilegeSet(log_out)ContextRole(logged_in_user)")

      allow(File).to receive(:open).and_return(pristine_file_lines)

      pristine_file = PristineFile.new(:file_name =>"cbac.pristine")
      pristine_file.parse

      expect(pristine_file.permissions.length).to eq(pristine_file_lines.length)
    end

    it "does not create an object for a comment line" do
      pristine_file_lines = ["0:+:PrivilegeSet(chat)ContextRole(logged_in_user)"]
      pristine_file_lines.push("1:+:PrivilegeSet(log_in)ContextRole(everybody)")
      pristine_file_lines.push("#this is a Ruby comment line")

      allow(File).to receive(:open).and_return(pristine_file_lines)

      pristine_file = PristineFile.new(:file_name =>"cbac.pristine")
      pristine_file.parse

      expect(pristine_file.permissions.length).to eq(2)
    end

    it "also adds a permission object if permission is revoked (operand - is used)" do
      pristine_file_lines = ["0:+:PrivilegeSet(chat)ContextRole(logged_in_user)"]
      pristine_file_lines.push("1:+:PrivilegeSet(log_in)ContextRole(everybody)")
      pristine_file_lines.push("2:-:PrivilegeSet(chat)ContextRole(logged_in_user)")

      allow(File).to receive(:open).and_return(pristine_file_lines)

      pristine_file = PristineFile.new(:file_name =>"cbac.pristine")
      pristine_file.parse

      expect(pristine_file.permissions.length).to eq(3)
      expect(pristine_file.permissions[2].operation).to eq('-')
    end

    it "fails if a permission is revoked which wasn't added before" do
      pristine_file_lines = ["0:+:PrivilegeSet(chat)ContextRole(logged_in_user)"]
      pristine_file_lines.push("1:+:PrivilegeSet(log_in)ContextRole(everybody)")
      pristine_file_lines.push("2:-:PrivilegeSet(chat)ContextRole(everybody)")

      allow(File).to receive(:open).and_return(pristine_file_lines)

      pristine_file = PristineFile.new(:file_name =>"cbac.pristine")

      expect(proc{
        pristine_file.parse
      }).to raise_error(SyntaxError)
    end

    it "fails if an x is used as an operand" do
      pristine_file_lines = ["0:x:PrivilegeSet(chat)ContextRole(logged_in_user)"]
      allow(File).to receive(:open).and_return(pristine_file_lines)

      pristine_file = PristineFile.new(:file_name =>"cbac.pristine")

      expect(proc{
        pristine_file.parse
      }).to raise_error(NotImplementedError)
    end

    it "fails if an => is used as an operand" do
      pristine_file_lines = ["0:=>:PrivilegeSet(chat)ContextRole(logged_in_user)"]
      allow(File).to receive(:open).and_return(pristine_file_lines)

      pristine_file = PristineFile.new(:file_name =>"cbac.pristine")

      expect(proc{
        pristine_file.parse
      }).to raise_error(NotImplementedError)
    end
  end

  describe "permission set" do
    before(:each) do
      @context_role = PristineRole.new(:role_id => 0, :role_type => PristineRole.ROLE_TYPES[:context], :name => "logged_in_user")
      @admin_role = PristineRole.new(:role_id => 1, :role_type => PristineRole.ROLE_TYPES[:admin],:name => "administrator")
      @pristine_file = PristineFile.new(:file_name =>"cbac.pristine")
    end

    it "filters out the permissions which were revoked" do
      permission_to_revoke = PristinePermission.new(:privilege_set_name => "chat", :pristine_role => @context_role, :operation => '+')
      @pristine_file.permissions.push(permission_to_revoke)
      @pristine_file.permissions.push(PristinePermission.new(:privilege_set_name => permission_to_revoke.privilege_set_name, :pristine_role => permission_to_revoke.pristine_role, :operation => '-'))

      expect(@pristine_file.permission_set).not_to include(permission_to_revoke)
    end

     it "does not include the revoke permission itself" do
      revoke_permission = PristinePermission.new(:privilege_set_name => "chat", :pristine_role => @context_role, :operation => '-')
      @pristine_file.permissions.push(PristinePermission.new(:privilege_set_name => revoke_permission.privilege_set_name, :pristine_role => revoke_permission.pristine_role, :operation => '+'))
      @pristine_file.permissions.push(revoke_permission)

      expect(@pristine_file.permission_set).not_to include(revoke_permission)
    end

    it "contains the permission if it is re-applied" do
      re_applied_permission = PristinePermission.new(:privilege_set_name => "chat", :pristine_role => @context_role, :operation => '+')
      @pristine_file.permissions.push(PristinePermission.new(:privilege_set_name => re_applied_permission.privilege_set_name, :pristine_role => re_applied_permission.pristine_role, :operation => '+'))
      @pristine_file.permissions.push(PristinePermission.new(:privilege_set_name =>  re_applied_permission.privilege_set_name, :pristine_role => re_applied_permission.pristine_role, :operation => '-'))
      @pristine_file.permissions.push(re_applied_permission)

      expect(@pristine_file.permission_set).to include(re_applied_permission)
    end

    it "raises an error if a permission is revoked which wasn't created before" do
      @pristine_file.permissions.push(PristinePermission.new(:privilege_set_name =>  "chat", :pristine_role => @context_role, :operation => '+'))
      @pristine_file.permissions.push(PristinePermission.new(:privilege_set_name =>  "login", :pristine_role => @context_role, :operation =>  '+'))
      @pristine_file.permissions.push(PristinePermission.new(:privilege_set_name =>  "blog_read", :pristine_role => @context_role, :operation =>  '-'))
      @pristine_file.permissions.push(PristinePermission.new(:privilege_set_name =>  "update_blog", :pristine_role => @context_role, :operation => '+'))

      expect(proc {
        @pristine_file.permission_set
      }).to raise_error(ArgumentError)
    end
  end
end
