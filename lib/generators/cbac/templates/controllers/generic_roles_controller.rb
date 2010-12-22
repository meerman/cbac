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
    @role.update_attributes(params[:cbac_generic_role])
    redirect_to :action => "index"
  end

  # POST /create
  def create
    @role = Cbac::GenericRole.new(params[:cbac_generic_role])
    @role.save
    redirect_to :action => "index"
  end

  # POST /delete
  def delete
    @role = Cbac::GenericRole.find(params[:id])
    @role.delete
    redirect_to :action => "index"
  end
end
