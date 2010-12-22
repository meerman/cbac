class Cbac::UpgradeController < ApplicationController

  layout 'cbac'

  def index
    @permissions =  Cbac::CbacPristine::PristinePermission.all    
  end

  def update

    params[:permissions].each do |perm_array|
      next if perm_array[1][:action] == 'leave'
      permission = Cbac::CbacPristine::PristinePermission.find(perm_array[1][:id])
      case perm_array[1][:action]
        when 'accept'
          permission.accept
        when 'reject'
          permission.reject
      end
    end
    redirect_to :action => :index

  end
end