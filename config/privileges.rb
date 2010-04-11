### Privileges.rb
#
# Defines the privilegesets and privileges for the CBAC system
#
include Cbac

# Defining privilegesets
PrivilegeSet.add :cbac_administration, "Allows administration of CBAC modules"
PrivilegeSet.add :login, "Allows users to log onto the system"
PrivilegeSet.add :news_read, "Allows reading news items"
PrivilegeSet.add :news_create, "Allows creating news items"
PrivilegeSet.add :news_update, "Allows changing existing news items"

# Defining privileges
Privilege.resource :cbac_administration, "cbac/permissions/index"
Privilege.resource :cbac_administration, "cbac/permissions/update", :post
Privilege.resource :cbac_administration, "cbac/generic_roles/index"
Privilege.resource :cbac_administration, "cbac/generic_roles/update", :post
Privilege.resource :cbac_administration, "cbac/generic_roles/create", :post
Privilege.resource :cbac_administration, "cbac/generic_roles/delete", :post
Privilege.resource :cbac_administration, "cbac/memberships/index"
Privilege.resource :cbac_administration, "cbac/memberships/update", :post
Privilege.resource :login, "news/login", :POST
Privilege.resource :news_read, "news/index"
Privilege.resource :news_read, "news/show"
Privilege.resource :news_create, "news/new"
Privilege.resource :news_create, "news/create", :POST
Privilege.resource :news_create, "news/create", :idempotent
Privilege.resource :news_update, "news/edit"
Privilege.resource :news_update, "news/update", :POST


# Models
# Enforcing mode
#Privilege.model :blog_read, :blog, :load
#Privilege.model :blog_create, :blog, :save
#Privilege.model :blog_update, :blog, :update
#Privilege.model :blog_update, :blog, :delete
# model attributes
#Privilege.model_attribute :blog_update, :blog, :author, :write
#privilege.model_attribute :blog_update, :blog, :author, :w
#privilege.model_attribute :blog_update, :blog, :author, :rw

