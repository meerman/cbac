### Privileges.rb
#
# Defines the privilegesets and privileges for the CBAC system
#
include Cbac

# Defining privilegesets
PrivilegeSet.add :cbac_administration, "Allows administration of CBAC modules"
PrivilegeSet.add :login, "Allows users to log onto the system"
PrivilegeSet.add :news_item_read, "Allows reading news_item items"
PrivilegeSet.add :news_item_create, "Allows creating news_item items"
PrivilegeSet.add :news_item_update, "Allows changing existing news_item items"
PrivilegeSet.add :news_item_administrator, "Allows administration of news items"
PrivilegeSet.add :news_item_moderator, "Moderator"

# Defining privileges
Privilege.resource :cbac_administration, "cbac/permissions/index"
Privilege.resource :cbac_administration, "cbac/permissions/update", :post
Privilege.resource :cbac_administration, "cbac/generic_roles/index"
Privilege.resource :cbac_administration, "cbac/generic_roles/update", :post
Privilege.resource :cbac_administration, "cbac/generic_roles/create", :post
Privilege.resource :cbac_administration, "cbac/generic_roles/delete", :post
Privilege.resource :cbac_administration, "cbac/memberships/index"
Privilege.resource :cbac_administration, "cbac/memberships/update", :post
Privilege.resource :login, "news_items/login", :POST
Privilege.resource :news_item_read, "news_items/index"
Privilege.resource :news_item_read, "news_items/show"
Privilege.resource :news_item_create, "news_items/new"
Privilege.resource :news_item_create, "news_items/create", :POST
Privilege.resource :news_item_create, "news_items/create", :idempotent
Privilege.resource :news_item_update, "news_items/edit"
Privilege.resource :news_item_update, "news_items/update", :POST

# Recursive privilegesets
Privilege.include :news_item_moderator, :news_item_update
Privilege.include :news_item_administrator, [:news_item_read, :news_item_create, :news_item_update]

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

