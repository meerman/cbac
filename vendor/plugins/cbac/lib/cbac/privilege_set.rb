# Defines sets of privileges
#
# To create a new set: PrivilegeSet.add :set_name, "Some comment on what this
# set does"
#
# To retrieve a privilegeset, use the sets attribute. This is a Hash containing
# PrivilegeSetRecords. Usage: PrivilegeSet.sets(:set_name). If the PrivilegeSet
# already exists, an ArgumentError is thrown stating the set was already
# defined.
class Cbac::PrivilegeSet
  class << self
    # Hash containing all the PrivilegeSetRecords
    attr_reader :sets

    # Create a new PrivilegeSet
    def add(symbol, comment)
      # initialize variables (if applicable)
      @sets = Hash.new if @sets.nil?
      # check for double creation
      raise ArgumentError, "CBAC: PrivilegeSet was already defined: #{symbol.to_s}" if @sets.include?(symbol)
      # Create record if privilegeset Cdoesn't exist
      Cbac::PrivilegeSetRecord.create(:name => symbol.to_s, :comment => comment) if Cbac::PrivilegeSetRecord.find(:first, :conditions => ["name = ?", symbol.to_s]).nil?
      record = Cbac::PrivilegeSetRecord.find(:first, :conditions => ["name = ?", symbol.to_s])
      @sets[symbol] = record
    end
  end
end
