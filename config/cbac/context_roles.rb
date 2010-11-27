### context_roles.rb
#
# Defines the context roles for the CBAC system
#
include Cbac

# Defining context roles
ContextRole.add :not_logged_in_user, 'current_user == 0'
ContextRole.add :logged_in_user, 'current_user.to_i > 0'
ContextRole.add :everybody, "true"
ContextRole.add :news_owner do
  context[:post].user.id == current_user
end

ContextRole.add :news_owner_with_email do
  return false if News.find(params[:id]).author_id == current_user
  return false if User.find(current_user).email.nil?
  true
end


