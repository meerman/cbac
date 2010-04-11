class Cbac::MembershipsController < ApplicationController
  # The layout used for all CBAC pages
  layout "cbac"

  # GET /index
  # GET /index.xml
  def index
    @generic_roles = Cbac::GenericRole.find(:all)
    @users = User.find(:all)
  end

  # POST /update
  def update
    Cbac::Membership.find(:all, :conditions => ["generic_role_id = ? AND user_id = ?", params[:generic_role_id], params[:user_id]]).each{|p|p.delete}
    if params[:member].to_s == "1"
      Cbac::Membership.create(:generic_role_id => params[:generic_role_id], :user_id => params[:user_id])
    end
    role = Cbac::GenericRole.find(params[:generic_role_id])
    render :partial => "cbac/memberships/update.html", :locals => {:generic_role => role,
      :user_id => params[:user_id], :update_partial => true}
  end
end
