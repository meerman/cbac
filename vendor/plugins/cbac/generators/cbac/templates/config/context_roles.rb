### context_roles.rb
#
# Defines the context roles for the CBAC system
#
include Cbac

# Defining context roles
ContextRole.add :everybody, 'true'
ContextRole.add :not_logged_in_user, 'current_user.to_i == 0'
ContextRole.add :logged_in_user, 'current_user.to_i > 0'
