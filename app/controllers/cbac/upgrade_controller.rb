class Cbac::UpgradeController < ApplicationController
  # The layout used for all CBAC pages
  layout "cbac"

  # GET /index
  # GET /index.xml
  def index
    @staged_changes = Cbac::StagedChange.all
  end

  # POST /update
  def update
  end
end
