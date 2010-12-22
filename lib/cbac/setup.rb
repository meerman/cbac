
module Cbac
  # Class performs various functions specific to the CBAC system itself. Most
  # important function is to check if the system is initialized; without proper
  # initialization, the bootstrapper will crash.
  class Setup
    class << self

      # Check to see if the tables are correctly migrated. If the tables are not
      # migrated, CBAC should terminate immediately.
      def check_tables
        # It is possible that there is no database connection yet. In that case, the table_exist call will fail
        begin
          return false unless Cbac::PrivilegeSetRecord.table_exists?
        rescue ActiveRecord::ConnectionNotEstablished
          puts "CBAC: Connection to database not established when initializing Cbac. Cbac is *not* running."
          return false
        end
        return false unless Cbac::GenericRole.table_exists?
        return false unless Cbac::Membership.table_exists?
        return false unless Cbac::Permission.table_exists?
        true
      end

      # Checks if the system is properly setup. This method is used by the
      # bootstrapper to see if the system should be initialized. If the system
      # is not properly setup, the bootstrapper will crash. Checks are performed
      # to see if all the tables exists.
      def check
        if check_tables == false
          puts "CBAC: not properly initialized: one or more tables are missing. Did you install it correctly? (run generate)"
          return false
        end
        true
      end
    end
  end
end