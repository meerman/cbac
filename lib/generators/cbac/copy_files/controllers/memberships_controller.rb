class Cbac::MembershipsController < ApplicationController
  # The layout used for all CBAC pages
  layout "cbac"

  # GET /index
  # GET /index.xml
  def index
    @generic_roles = Cbac::GenericRole.all
    @users = User.all
  end

  # POST /update
  def update
    Cbac::Membership.where(generic_role_id: params[:generic_role_id], user_id: params[:user_id]).each(&:delete)
    if params[:member].to_s == "1"
      Cbac::Membership.create do |membership|
        membership.generic_role_id = params[:generic_role_id]
        membership.user_id = params[:user_id]
      end
    end
    role = Cbac::GenericRole.find(params[:generic_role_id])
    render :partial => "cbac/memberships/update.html", :locals => {:generic_role => role,
      :user_id => params[:user_id], :update_partial => true}
  end
end
