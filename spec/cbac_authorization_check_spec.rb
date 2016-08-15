require 'spec_helper'
require 'cbac'

require_relative './fixtures/controllers/dating/daughter_controller'

# create a fake controller with some actions
describe Cbac do
  describe :authorization_check do
    include Cbac

    before :all do
      @controller = Dating::DaughterController.new

      # define a set of privileges
      Cbac::PrivilegeSet.add :go_out_with_daughter,      "Allows users to perform the actions nested in this privilege set"
        # add some privileges to the given set
        Privilege.resource :go_out_with_daughter,  "dating/daughter_controller/take_to_dinner", :post
        Privilege.resource :go_out_with_daughter,  "dating/daughter_controller/bring_home", :post

      # define a context role that can be evaluated when one of the privileges is invoked
      ContextRole.add :suitable_boyfriend do |context|
        context.send(:candidate).brought_flowers?
      end

      # allow any 'suitable_boyfriend' to invoke Privileges in the 'go_out_with_daughter' PrivilegeSet
      Cbac::Permission.create(
        :context_role => 'suitable_boyfriend',
        :privilege_set_id => Cbac::PrivilegeSetRecord.where(
          :name => 'go_out_with_daughter'
        ).first.id
      )
    end

    context "when a user attempts to invoke the action" do
      before :each do
        @controller.request = ActionDispatch::TestRequest.new
        @controller.request.request_method = 'POST'

        @controller.params = {
          :controller => "dating/daughter_controller",
          :action => "take_to_dinner"
        }
        allow(@controller).to receive(:current_user).and_return(nil)
      end

      context "and the contextual requirements are fulfilled" do
        before :each do
          ideal_son_in_law = double('user', :brought_flowers? => true)
          allow(@controller).to receive(:candidate).and_return(ideal_son_in_law)
        end

        specify "the action is invoked" do
          expect(@controller.authorize).to be_truthy
        end
      end

      context "and the contextual requirements are not fulfilled" do
        before :each do
          some_punk = double('user', :brought_flowers? => false)
          allow(@controller).to receive(:candidate).and_return(some_punk)
        end

        specify "the action is blocked" do
          expect(@controller.authorize).to be_falsey
        end
      end
    end
  end
end
