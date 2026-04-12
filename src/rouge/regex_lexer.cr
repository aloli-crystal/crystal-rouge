# Port of Rouge::RegexLexer
# Stack-based state machine for tokenizing source code.

module Rouge
  # A token with its matched text
  alias TokenPair = {Token, String}

  # A rule: regex + action to produce tokens
  class Rule
    getter regex : Regex
    getter token : Token?
    getter next_state : Symbol?
    getter pop : Bool
    getter block : (Regex::MatchData -> Array(TokenPair))?

    def initialize(@regex : Regex, @token : Token? = nil, @next_state : Symbol? = nil, @pop : Bool = false, @block : (Regex::MatchData -> Array(TokenPair))? = nil)
    end
  end

  # A named state containing an ordered list of rules
  class State
    getter name : Symbol
    getter rules : Array(Rule)
    getter mixins : Array(Symbol)

    def initialize(@name : Symbol)
      @rules = [] of Rule
      @mixins = [] of Symbol
    end

    def add_rule(rule : Rule)
      @rules << rule
    end

    def add_mixin(state_name : Symbol)
      @mixins << state_name
    end
  end

  # Base class for all regex-based lexers
  abstract class RegexLexer
    @@states = {} of String => Hash(Symbol, State)
    @@tags = {} of String => RegexLexer.class
    @@titles = {} of String => String
    @@descriptions = {} of String => String
    @@file_extensions = {} of String => Array(String)

    # Class-level DSL methods implemented via macros

    macro inherited
      @@my_states = {} of Symbol => Rouge::State

      def self.states : Hash(Symbol, Rouge::State)
        @@my_states
      end

      def self.tag_name : String
        ""
      end

      def self.title_text : String
        ""
      end

      def self.desc_text : String
        ""
      end

      def self.file_exts : Array(String)
        [] of String
      end
    end

    # ── Instance methods ─────────────────────────────────────────

    getter stack : Array(Symbol)

    def initialize
      @stack = [:root]
    end

    # Tokenize the input string, returns array of {Token, String}
    def lex(input : String) : Array(TokenPair)
      tokens = [] of TokenPair
      lex(input) { |tok, val| tokens << {tok, val} }
      tokens
    end

    # Tokenize with block
    def lex(input : String, &block : Token, String ->) : Nil
      @stack = [:root]
      pos = 0
      max_null = 5
      null_count = 0

      while pos < input.size
        matched = false
        current_state = get_state(@stack.last)

        # Try rules from current state (including mixins)
        all_rules = collect_rules(current_state)

        all_rules.each do |rule|
          match = rule.regex.match(input, pos)
          next unless match
          next unless match.byte_begin(0) == pos

          matched_text = match[0]

          if matched_text.empty?
            null_count += 1
            if null_count >= max_null
              # Skip one char to avoid infinite loop
              yield Tokens::Error, input[pos].to_s
              pos += 1
              null_count = 0
              matched = true
              break
            end
          else
            null_count = 0
          end

          # Execute action
          if b = rule.block
            pairs = b.call(match)
            pairs.each { |tok, val| yield tok, val }
          elsif tok = rule.token
            yield tok, matched_text unless matched_text.empty?
          end

          # State transitions
          if rule.pop
            @stack.pop if @stack.size > 1
          elsif ns = rule.next_state
            @stack.push(ns)
          end

          pos += matched_text.size
          matched = true
          break
        end

        unless matched
          # No rule matched: emit one char as Error
          yield Tokens::Error, input[pos].to_s
          pos += 1
          null_count = 0
        end
      end
    end

    # ── Lookup ─────────────────────────────────────────────────────

    # Find a lexer by tag name
    def self.find(tag : String) : RegexLexer?
      klass = @@tags[tag]?
      klass.try(&.new)
    end

    # Register a lexer class
    def self.register(tag : String, klass : RegexLexer.class)
      @@tags[tag] = klass
    end

    # List all registered lexer tags
    def self.registered_tags : Array(String)
      @@tags.keys
    end

    # ── State resolution ───────────────────────────────────────────

    private def get_state(name : Symbol) : State
      self.class.states[name]? || raise "Unknown state: #{name}"
    end

    private def collect_rules(state : State) : Array(Rule)
      rules = [] of Rule
      state.mixins.each do |mixin_name|
        if mixin_state = self.class.states[mixin_name]?
          rules.concat(collect_rules(mixin_state))
        end
      end
      rules.concat(state.rules)
      rules
    end
  end
end
