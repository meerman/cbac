class Cbac::PermissionsController < ApplicationController
  # The layout used for all CBAC pages
  layout "cbac"

  # GET /index GET /index.xml
  def index
    if params[:role_substr] and params[:role_substr] != ""
      @context_roles = []
      @generic_roles = []

      params[:role_substr].split('|').each do |role_start|
          @context_roles += (ContextRole.roles.select {|key,value| !key.to_s.match(/^#{role_start}/).nil?}).collect{|key, value| [key, value]}
        @generic_roles += Cbac::GenericRole.find(:all).select {|role| !role.name.match(/^#{role_start}/).nil? }
      end
    else
      @context_roles = ContextRole.roles
      @generic_roles = Cbac::GenericRole.all    
    end

    if params[:priv_substr] && params[:priv_substr] != ""
      @sets = []
      params[:priv_substr].split('|').each do |priv_start|
        @sets += PrivilegeSet.sets.select {|key, value| !key.to_s.match(/^#{priv_start}/).nil?}
      end
    else 
      @sets = PrivilegeSet.sets
    end
  end

  def update
    unless params[:context_role].nil?
      update_context_role
      return
    end
    unless params[:generic_role_id].nil?
      update_generic_role
    end
  end

  private

  # POST /update
  def update_context_role
    Cbac::Permission.find(:all, :conditions => ["context_role = ? AND privilege_set_id = ?", params[:context_role], params[:privilege_set_id]]).each{|p|p.delete}
    if params[:permission].to_s == "1"
      Cbac::Permission.create(:context_role => params[:context_role], :privilege_set_id => params[:privilege_set_id])
    end
    render :partial => "cbac/permissions/update_context_role.html", :locals => {:context_role => params[:context_role],
      :set_id => params[:privilege_set_id], :update_partial => true}
  end

  def update_generic_role
    Cbac::Permission.find(:all, :conditions => ["generic_role_id = ? AND privilege_set_id = ?", params[:generic_role_id], params[:privilege_set_id]]).each{|p|p.delete}
    if params[:permission].to_s == "1"
      Cbac::Permission.create(:generic_role_id => params[:generic_role_id], :privilege_set_id => params[:privilege_set_id])
    end
    role = Cbac::GenericRole.find(params[:generic_role_id])
    render :partial => "cbac/permissions/update_generic_role.html", :locals => {:pristine_role =>role,
      :set_id => params[:privilege_set_id], :update_partial => true}
  end
end
