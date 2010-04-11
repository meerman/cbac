# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Cbac

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # TODO: check if this can be placed in the cbac module
  before_filter :authorize
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

   def current_user
     session[:currentuser].to_i
   end
end
