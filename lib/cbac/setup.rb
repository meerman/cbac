
module Cbac
  # Class performs various functions specific to the CBAC system itself. Most
  # important function is to check if the system is initialized; without proper
  # initialization, the bootstrapper will crash.
  class Setup
    class << self

      # Check to see if the tables are correctly migrated. If the tables are not
      # migrated, CBAC should terminate immediately.
      def check_tables
        begin
          classes = [ Cbac::PrivilegeSetRecord, Cbac::GenericRole, Cbac::Membership, Cbac::Permission ]
          return classes.all? do |c|
            c.table_exists?
          end
        rescue ActiveRecord::ConnectionNotEstablished
          # There is no database connection yet.
          puts "CBAC: Connection to database not established when initializing Cbac. Cbac is *not* running."
          return false
        end
      end

      # Checks if the system is properly setup. This method is used by the
      # bootstrapper to see if the system should be initialized. If the system
      # is not properly setup, the bootstrapper will crash. Checks are performed
      # to see if all the tables exists.
      def check
        unless check_tables
          puts "CBAC: not properly initialized: one or more tables are missing. Did you install it correctly? (run generate)"
          return false
        end

        return true
      end
    end
  end
end
