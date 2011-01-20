### Privileges.rb
#
# Defines the privilegesets and privileges for the CBAC system
#
include Cbac
puts "Loading privilegesets"

cbac do
  set :public, "Stuff that is always accessible" do
    # Insert public conroller/methods here
  end

  set :cbac_administration, "Allows administration of CBAC modules" do
    in_module :cbac do
      get "permissions", :index
      post "permissions", :create
      get "memberships", :index
      post "memberships", :create
      get "generic_roles", :index
      post "generic_roles", :update, :create, :delete
      get "upgrade", :index
      post "upgrade", :update
    end
  end
end
