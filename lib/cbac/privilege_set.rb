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
      # Create record if privilege set doesn't exist
      record = Cbac::PrivilegeSetRecord.find_or_create_by(name: symbol.to_s)
      record.set_comment(comment)
      record.save

      @sets[symbol] = record
    end
  end
end
