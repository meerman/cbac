### Privileges.rb
#
# Defines the privilegesets and privileges for the CBAC system
#
include Cbac

# Defining privilegesets
PrivilegeSet.add :cbac_administration, "Allows administration of CBAC modules"

# Defining privileges on controller methods (REST resources)
Privilege.resource :cbac_administration, "cbac/permissions/index"
Privilege.resource :cbac_administration, "cbac/permissions/update", :post
Privilege.resource :cbac_administration, "cbac/memberships/index"
Privilege.resource :cbac_administration, "cbac/memberships/update", :post
Privilege.resource :cbac_administration, "cbac/generic_roles/index"
Privilege.resource :cbac_administration, "cbac/generic_roles/update", :post
Privilege.resource :cbac_administration, "cbac/generic_roles/create", :post
Privilege.resource :cbac_administration, "cbac/generic_roles/delete", :post

# model attributes
#Privilege.model_attribute :blog_update, :blog, :author, :write
#privilege.model_attribute :blog_update, :blog, :author, :w
#privilege.model_attribute :blog_update, :blog, :author, :rw
# Models
# Enforcing mode
#Privilege.model :blog_read, :blog, :load
#Privilege.model :blog_create, :blog, :save
#Privilege.model :blog_update, :blog, :update
#Privilege.model :blog_update, :blog, :delete

