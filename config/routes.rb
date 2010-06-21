ActionController::Routing::Routes.draw do |map|
  map.resources :news_items
  map.root :controller => "news_items"
  map.login "/login", :controller => "news_items", :action => "login"
  map.namespace(:cbac) do |cbac|
    cbac.permissions 'permissions', :controller => "permissions", :action => "index"
    cbac.permissions_update 'permissions/update', :controller => "permissions", :action => "update", :conditions => { :method => :post }
    cbac.resources :generic_roles
    cbac.memberships 'memberships', :controller => "memberships", :action => "index"
    cbac.memberships_update 'memberships/update', :controller => "memberships", :action => "update", :conditions => { :method => :post }
    cbac.upgrade 'upgrade', :controller => 'upgrade', :action => "index"
    cbac.process_changes 'upgrade/process_changes', :controller => 'upgrade', :action => 'process_changes', :conditions => { :method => :post }
  end
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
# The priority is based upon order of creation: first created -> highest
# priority.

# Sample of regular route:
#   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
# Keep in mind you can assign values other than :controller and :action

# Sample of named route:
#   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
# This route can be invoked with purchase_url(:id => product.id)
# #map.cbac_permissions_index "/cbac/permissions", :controller =>
# "cbac/permissions", :action => "index" Sample resource route (maps HTTP verbs
# to controller actions automatically):
#   map.resources :products

# Sample resource route with options:
#   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

# Sample resource route with sub-resources:
#   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
# Sample resource route with more complex sub-resources
#   map.resources :products do |products|
#     products.resources :comments
#     products.resources :sales, :collection => { :recent => :get }
#   end

# Sample resource route within a namespace:
#   map.namespace :admin do |admin|
#     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
#     admin.resources :products
#   end

# You can have the root of your site routed with map.root -- just remember to
# delete public/index.html.

# See how all your routes lay out with "rake routes"

# Install the default routes as the lowest priority. Note: These default routes
# make all actions in every controller accessible via GET requests. You should
# consider removing or commenting them out if you're using named routes and
# resources. #map.connect ':controller/:action/:id' #map.connect
# ':controller/:action/:id.:format'
