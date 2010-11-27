module Cbac
  # Class containing configuration options for the Cbac system. The following
  # configuration options are supported: verbose. Determines whether or not to
  # output results to the console. All outputs are processed as puts commands.
  class Config
    class << self
      attr_accessor :verbose
    end
  end
end