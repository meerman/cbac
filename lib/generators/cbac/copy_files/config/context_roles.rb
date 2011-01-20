### context_roles.rb
#
# Defines the context roles for the CBAC system
#
include Cbac
puts "Loading context_roles"

# Defining context roles
ContextRole.add :everybody do
  true
end
ContextRole.add :not_logged_in_user do |context|
  context.current_user.nil?
end
ContextRole.add :logged_in_user do |context|
  not context.current_user.nil?
end
