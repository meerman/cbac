# ContextRole is the class containing the context role definitions
#
# Usage: ContextRole.add :logged_in_user, "!session[:currentuser].nil?"
class ContextRole
  class << self
    # Hash containing all the context roles. Keys are the role names Values are
    # the Ruby eval strings Eval strings must result in true or false
    attr_reader :roles

    # Adds a context role to the list of context roles. @symbol defines the name
    # of the context role @context_rule defines the ruby code to be evaluated
    # when determining role membership
    #
    # If the context role already exists, an exception is thrown.
    def add(symbol, context_rule = "", &block)
      symbol = symbol.to_sym
      @roles = Hash.new if @roles.nil?
      raise ArgumentError, "CBAC: ContextRole was already defined" if @roles.keys.include?(symbol)
      # TODO following code
      #raise ArgumentError, "CBAC: cannot specify both string rule and block rule" unless context_rule.nil? and block.nil?
      # TODO context parameter in block statement is not explicitly tested
      block = eval("Proc.new {|context| " + context_rule + "}") if block.nil?
      @roles[symbol] = block
    end
  end
end

