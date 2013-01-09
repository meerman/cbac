module Dating
  class DaughterController < ActionController::Base
    include Cbac

    def take_to_dinner; end
    def bring_home; end

  private
    attr_accessor :current_user
  end
end
