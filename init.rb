# Configuration file
require File.dirname(__FILE__) + '/lib/cbac/config.rb'

# The following code contains configuration options. You can turn them on for
# gem development. For actual usage, it is advisable to set the configuration
# options in the environment files.
Cbac::Config.verbose = false

# Include CBAC core file
require File.dirname(__FILE__) + '/lib/cbac.rb'

