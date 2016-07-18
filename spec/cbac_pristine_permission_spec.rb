require 'spec_helper'

include Cbac::CbacPristine

describe "CbacPristinePermission" do
  describe "convert pristine line to a yml fixture" do
    before(:each) do
      @admin_role = PristineRole.new(:role_id => 1, :role_type => PristineRole.ROLE_TYPES[:admin], :name => "administrator")
      @context_role = PristineRole.new(:role_id => 0, :role_type => PristineRole.ROLE_TYPES[:context], :name => "chat_starter")
    end

    it "raises an error if the pristine line has no role" do
      pristine_permission = PristinePermission.new(:line_number => 1, :privilege_set_name => 'log_in', :pristine_role =>  nil)

      expect(lambda {
        pristine_permission.to_yml_fixture
      }).to raise_error(ArgumentError)
    end

    it "raises an error if the pristine line has no privilege_set_name" do
      pristine_permission = PristinePermission.new(:line_number => 1, :privilege_set_name => "", :pristine_role => @context_role)

      expect(lambda {
        pristine_permission.to_yml_fixture
      }).to raise_error(ArgumentError)
    end

    it "returns a yml string starting with cbac_permission_ " do
      pristine_permission = PristinePermission.new(:line_number => 1, :privilege_set_name => "chat", :pristine_role => @context_role)

      expect(pristine_permission.to_yml_fixture).to match(/\Acbac_permission_/)
    end

    it "returns a yml string containing the line number of the pristine line" do
      line_number= 100
      pristine_permission = PristinePermission.new(:line_number => line_number, :privilege_set_name => "chat", :pristine_role => @context_role)

      expect(pristine_permission.to_yml_fixture).to match(/id: #{line_number}/)
    end

    it "returns a yml string containing a generic role id of 0 if a context_role is used" do
      pristine_permission = PristinePermission.new(:line_number => 150, :privilege_set_name => "chat", :pristine_role => @context_role)

      expect(pristine_permission.to_yml_fixture).to match(/generic_role_id: 0/)
    end

    it "returns a yml string containing the name of the context role if a context_role is used" do
      pristine_permission = PristinePermission.new(:line_number => 150, :privilege_set_name => "chat", :pristine_role => @context_role)

      expect(pristine_permission.to_yml_fixture).to match(/context_role: #{@context_role.name}/)
    end

    it "returns a yml string containing the id of the generic role if a generic role is used" do
      pristine_permission = PristinePermission.new(:line_number => 150, :privilege_set_name => "chat", :pristine_role => @admin_role)

      expect(pristine_permission.to_yml_fixture).to match(/generic_role_id: #{@admin_role.id.to_s}/)
    end

    it "returns a yml string containing ruby code to find the privilege set by name" do
      pristine_permission = PristinePermission.new(:line_number => 150, :privilege_set_name => "chat", :pristine_role => @context_role)

      expect(pristine_permission.to_yml_fixture).to match(/privilege_set_id: \<%= Cbac::PrivilegeSetRecord.where\(name: '#{pristine_permission.privilege_set_name}'\)\.first\.id %>/)
    end

    it "returns a yml string containing created_at and updated_at" do
      pristine_permission = PristinePermission.new(:line_number => 1, :privilege_set_name => "chat", :pristine_role => @context_role)
      expect(pristine_permission.to_yml_fixture).to match(/created_at:.+updated_at:/m)
    end
  end

  describe "check if this pristine permission exists" do
    before(:each) do
      @privilege_set = Cbac::PrivilegeSetRecord.create(:name => "login")
      @admin_role = Cbac::GenericRole.create(:name => "administrator")

      @pristine_context_role = PristineRole.new(:role_id => 0, :role_type => PristineRole.ROLE_TYPES[:context], :name => "logged_in_user")
      @pristine_admin_role = PristineRole.new(:role_id => 1, :role_type => PristineRole.ROLE_TYPES[:admin],  :name => @admin_role.name)
    end

    it "returns true if the pristine permission exists as generic cbac permission in the database" do
      Cbac::Permission.create(:privilege_set_id => @privilege_set.id, :generic_role_id => @admin_role.id)

      pristine_permission = PristinePermission.new(:privilege_set_name => @privilege_set.name, :pristine_role => @pristine_admin_role)

      expect(pristine_permission.cbac_permission_exists?).to be_truthy
    end

    it "returns true if the pristine permission exists as context cbac permission in the database" do
      Cbac::Permission.create(:privilege_set_id => @privilege_set.id, :generic_role_id => 0, :context_role => @pristine_context_role.name)

      pristine_permission = PristinePermission.new(:privilege_set_name => @privilege_set.name, :pristine_role => @pristine_context_role)

      expect(pristine_permission.cbac_permission_exists?).to be_truthy
    end

    it "returns false if the pristine permission does not exist as context cbac permission in the database" do
      pristine_permission = PristinePermission.new(:privilege_set_name => @privilege_set.name, :pristine_role => @pristine_context_role)

      expect(pristine_permission.cbac_permission_exists?).to be_falsey
    end

    it "returns false if the pristine permission does not exist as a generic cbac permission in the database" do
      pristine_permission = PristinePermission.new(:privilege_set_name => @privilege_set.name, :pristine_role => @pristine_admin_role)

      expect(pristine_permission.cbac_permission_exists?).to be_falsey
    end

    it "returns false if a similar pristine permission exist as a generic cbac permission in the database, but for another generic role" do
      group_admin = Cbac::GenericRole.create(:name => "group_administrator")
      Cbac::Permission.create(:privilege_set_id => @privilege_set.id, :generic_role_id => group_admin.id)

      pristine_permission = PristinePermission.new(:privilege_set_name => @privilege_set.name, :pristine_role => @pristine_admin_role)

      expect(pristine_permission.cbac_permission_exists?).to be_falsey
    end

    it "returns false if a similar pristine permission exist as a context cbac permission in the database, but for another context role" do
      Cbac::Permission.create(:privilege_set_id => @privilege_set.id, :generic_role_id => 0, :context_role => "group_owner")

      pristine_permission = PristinePermission.new(:privilege_set_name => @privilege_set.name, :pristine_role => @pristine_context_role)

      expect(pristine_permission.cbac_permission_exists?).to be_falsey
    end
  end

  describe "check if a known permission exists for this pristine permission" do
     before(:each) do
      @pristine_context_role = PristineRole.new(:role_id => 0, :role_type => PristineRole.ROLE_TYPES[:context], :name => "logged_in_user")
      @pristine_admin_role = PristineRole.new(:role_id => 1, :role_type => PristineRole.ROLE_TYPES[:admin],  :name => "administrator")
    end

    it "returns true if the pristine permission exists as a known permission in the database" do
      pristine_permission = PristinePermission.new(:pristine_role => @pristine_admin_role, :line_number => 4, :privilege_set_name => "not relevant")

      Cbac::KnownPermission.create(:permission_number => pristine_permission.line_number, :permission_type => Cbac::KnownPermission.PERMISSION_TYPES[:context])

      expect(pristine_permission.known_permission_exists?).to be_truthy
    end
  end

  describe "registering the change" do
    before(:each) do
      @privilege_set = Cbac::PrivilegeSetRecord.create(:name => "login")

      @admin_role = Cbac::GenericRole.create(:name => "administrator")
      @pristine_admin_role = PristineRole.new(:role_id => 1, :role_type => PristineRole.ROLE_TYPES[:admin], :name => @admin_role.name)

      @pristine_permission = PristinePermission.new(:privilege_set_name => @privilege_set.name, :pristine_role => @pristine_admin_role)
      @pristine_permission.operation = '+'
      @pristine_permission.line_number = rand

      @pristine_file = double('pristine_file', :permissions => [ @pristine_permission ])
      allow(@pristine_permission).to receive(:pristine_file).and_return @pristine_file
    end

    it "creates a known permission to record a change" do
      expect(proc {
        @pristine_permission.accept
      }).to change(Cbac::KnownPermission, :count).by(1)
    end

    it "creates a known permission with specified permission identifier" do
      @pristine_permission.accept

      known_permission = Cbac::KnownPermission.last

      expect(known_permission.permission_number).to eq(@pristine_permission.line_number)
    end

    it "creates a known permission with specified role type" do
      @pristine_permission.accept

      known_permission = Cbac::KnownPermission.last

      expect(known_permission.permission_type).to eq(Cbac::KnownPermission.PERMISSION_TYPES[:context])
    end

    context "if the operation is '-'" do
      before :each do
        Cbac::Permission.create(:privilege_set_id => @privilege_set.id, :generic_role_id => @pristine_admin_role.role_id, :context_role => @pristine_admin_role.name)

        @pristine_permission.operation = '-'
      end

      it "still creates a known permission" do
        expect(proc {
          @pristine_permission.accept
        }).to change(Cbac::KnownPermission, :count).by(1)
      end
    end
  end

  describe "apply the permission" do
    before(:each) do
      @privilege_set = Cbac::PrivilegeSetRecord.create(:name => "login")
      @admin_role = Cbac::GenericRole.create(:name => "administrator")

      @pristine_context_role = PristineRole.new(:role_id => 0, :role_type => PristineRole.ROLE_TYPES[:context], :name => "logged_in_user")
      @pristine_admin_role = PristineRole.new(:role_id => 1, :role_type => PristineRole.ROLE_TYPES[:admin], :name => @admin_role.name)

      @pristine_permission = PristinePermission.new(:privilege_set_name => @privilege_set.name)
      allow(@pristine_permission).to receive(:register_change)
    end

    context "if operation '+' is used" do
      before :each do
        @pristine_permission.operation = '+'
      end

      context "if the role is a context role" do
        before :each do
          @pristine_permission.pristine_role = @pristine_context_role
          @pristine_permission.save!
        end

        it "deletes the pristine permission since it was accepted" do
          expect(proc {
            @pristine_permission.accept
          }).to change(PristinePermission, :count).by(-1)
        end

        it "registers the change" do
          expect(@pristine_permission).to receive(:register_change)

          @pristine_permission.accept
        end

        it "adds the context permission to the database" do
          expect(proc {
            @pristine_permission.accept
          }).to change(Cbac::Permission, :count).by(1)
        end
      end

      context "if the role is a generic role" do
        before :each do
          @pristine_permission.pristine_role = @pristine_admin_role
          @pristine_permission.save!
        end

        it "deletes the pristine permission since it was accepted" do
          expect(proc {
            @pristine_permission.accept
          }).to change(PristinePermission, :count).by(-1)
        end

        it "registers the change" do
          expect(@pristine_permission).to receive(:register_change)

          @pristine_permission.accept
        end

        it "creates a generic permission" do
          expect(proc {
            @pristine_permission.accept
          }).to change(Cbac::Permission, :count).by(1)
        end

        context "and the given role already exists" do
          it "uses the existing role" do
            @pristine_permission.pristine_role = @pristine_admin_role

            @pristine_permission.accept

            expect(Cbac::Permission.last.generic_role).to eq(@admin_role)
          end
        end

        context "but no role with that name exists" do
          before :each do
            Cbac::GenericRole.delete_all
          end

          it "creates a generic role if it doesn't exist yet" do
            expect(proc {
              @pristine_permission.accept
            }).to change(Cbac::GenericRole, :count).by(1)
          end
        end
      end
    end

    context "if operation '-' is used" do
      before :each do
        @pristine_permission.operation = '-'
        @pristine_permission.pristine_role = @pristine_context_role
      end

      it "removes an existing permission" do
        Cbac::Permission.create(:privilege_set_id => @privilege_set.id, :generic_role_id => 0, :context_role => @pristine_context_role.name)

        expect(proc {
          @pristine_permission.accept
        }).to change(Cbac::Permission, :count).by(-1)
      end

      context "if the permission specified does not exist" do
        before :each do
          Cbac::Permission.delete_all
        end

        it "raises an error" do
          expect(proc {
            @pristine_permission.accept
          }).to raise_error(ArgumentError)
        end
      end
    end
  end

  describe "stage the permission so it can be applied" do
    before(:each) do
      @pristine_context_role = PristineRole.new(:role_id => 0, :role_type => PristineRole.ROLE_TYPES[:context], :name => "logged_in_user")
      @pristine_admin_role = PristineRole.new(:role_id => 1, :role_type => PristineRole.ROLE_TYPES[:admin], :name => "administrator")
    end

    it "persists the pristine permission to the database" do
      pristine_permission = PristinePermission.new(:privilege_set_name => "login", :pristine_role => @pristine_context_role, :operation => '+')

      expect(proc {
        pristine_permission.stage
      }).to change(Cbac::CbacPristine::PristinePermission, :count).by(1)
    end

    it "persists the associated role if it doesn't exist yet" do
      pristine_permission = PristinePermission.new(:privilege_set_name => "login", :pristine_role => @pristine_context_role, :operation => '+')

      expect(proc {
        pristine_permission.stage
      }).to change(Cbac::CbacPristine::PristineRole, :count).by(1)
    end

    it "does not create a new pristine permission if the cbac permission exists and the pristine permission wants to add" do
      privilege_set = Cbac::PrivilegeSetRecord.create(:name => "login")
      Cbac::Permission.create(:privilege_set_id => privilege_set.id, :generic_role_id => 0, :context_role => @pristine_context_role.name)

      pristine_permission = PristinePermission.new(:operation => '+', :privilege_set_name => privilege_set.name, :pristine_role => @pristine_context_role)

      expect(proc {
        pristine_permission.stage
      }).not_to change(Cbac::CbacPristine::PristinePermission, :count)
    end

    it "creates a new pristine permission if the cbac permission exists and the pristine permission wants to revoke" do
      privilege_set = Cbac::PrivilegeSetRecord.create(:name => "login")
      Cbac::Permission.create(:privilege_set_id => privilege_set.id, :generic_role_id => 0, :context_role => @pristine_context_role.name)

      pristine_permission = PristinePermission.new(:operation => '-', :privilege_set_name => privilege_set.name, :pristine_role => @pristine_context_role)

      expect(proc {
        pristine_permission.stage
      }).to change(Cbac::CbacPristine::PristinePermission, :count).by(1)
    end

    it "does not create a new pristine permission if a staged add permission exists and this pristine permission wants to revoke" do
      privilege_set_name = "chat"
      PristinePermission.new(:operation => '+', :privilege_set_name => privilege_set_name, :pristine_role => @pristine_context_role)
      pristine_revoke_permission = PristinePermission.new(:operation => '-', :privilege_set_name => privilege_set_name, :pristine_role => @pristine_context_role)

      expect(proc {
        pristine_revoke_permission.stage
      }).not_to change(Cbac::CbacPristine::PristinePermission, :count)
    end

    it "deletes a staged add permission if the pristine permission wants to revoke the same permission" do
      privilege_set_name = "chat"
      PristinePermission.create(:operation => '+', :privilege_set_name => privilege_set_name, :pristine_role => @pristine_context_role)
      pristine_revoke_permission = PristinePermission.new(:operation => '-', :privilege_set_name => privilege_set_name, :pristine_role => @pristine_context_role)

      expect(proc {
        pristine_revoke_permission.stage
      }).to change(Cbac::CbacPristine::PristinePermission, :count).by(-1)
    end

    it "does not create a new pristine permission if a cbac known permission exists" do
      known_number = 1
      pristine_permission = PristinePermission.new(:line_number => known_number, :privilege_set_name => "name not relevant", :pristine_role => @pristine_context_role)
      Cbac::KnownPermission.create(:permission_number => known_number, :permission_type => Cbac::KnownPermission.PERMISSION_TYPES[:context])

      expect(proc {
        pristine_permission.stage
      }).not_to change(Cbac::CbacPristine::PristinePermission, :count)
    end

    it "raises an error if the same pristine permission is staged twice" do
      privilege_set_name = "chat"
      PristinePermission.create(:operation => '+', :privilege_set_name => privilege_set_name, :pristine_role => @pristine_context_role, :line_number => 2)
      pristine_permission = PristinePermission.new(:operation => '+', :privilege_set_name => privilege_set_name, :pristine_role => @pristine_context_role, :line_number => 3)

      expect(proc {
        pristine_permission.stage
      }).to raise_error(ArgumentError)
    end
  end
end

