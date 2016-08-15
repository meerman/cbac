class Cbac::GenericRolesController < ApplicationController
  # The layout used for all CBAC pages
  layout "cbac"

  # GET /index
  # GET /index.xml
  def index
  end

  # POST /update
  def update
    @role = Cbac::GenericRole.find(params[:id])
    @role.update_attributes(role_params)
    redirect_to :action => "index"
  end

  # POST /create
  def create
    @role = Cbac::GenericRole.new(role_params)
    @role.save
    redirect_to :action => "index"
  end

  # POST /delete
  def delete
    @role = Cbac::GenericRole.find(params[:id])
    @role.delete
    redirect_to :action => "index"
  end

  private
  def role_params
    params.required(:cbac_generic_role).permit(:name, :remarks)
  end
end
