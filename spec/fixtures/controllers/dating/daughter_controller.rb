module Dating
  class DaughterController < ActionController::Base
    include Cbac

    def take_to_dinner; end
    def bring_home; end

    def authorize
      authorization_check(params[:controller], params[:action], request.request_method.downcase, self)
    end
  end
end
