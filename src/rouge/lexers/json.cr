module Rouge
  module Lexers
    class JSON < RegexLexer
      def self.tag_name : String
        "json"
      end

      def self.title_text : String
        "JSON"
      end

      def self.desc_text : String
        "JavaScript Object Notation (json.org)"
      end

      def self.file_exts : Array(String)
        ["*.json"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        # :whitespace
        ws = State.new(:whitespace)
        ws.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        states[:whitespace] = ws

        # :constants
        constants = State.new(:constants)
        constants.add_rule Rule.new(/(?:true|false|null)\b/, Tokens::KeywordConstant)
        constants.add_rule Rule.new(/-?(?:0|[1-9]\d*)\.\d+(?:e[+-]?\d+)?/i, Tokens::NumFloat)
        constants.add_rule Rule.new(/-?(?:0|[1-9]\d*)(?:e[+-]?\d+)?/i, Tokens::NumInteger)
        states[:constants] = constants

        # :string
        string = State.new(:string)
        string.add_rule Rule.new(/[^\\"]+/, Tokens::StrDouble)
        string.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        states[:string] = string

        # :name
        name = State.new(:name)
        name.add_rule Rule.new(
          /("(?:\\.|[^"\\\n])*?")(\s*)(:)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::NameLabel, m[1]},
              {Tokens::TextWhitespace, m[2]},
              {Tokens::Punctuation, m[3]},
            ] of TokenPair
          }
        )
        states[:name] = name

        # :value
        value = State.new(:value)
        value.add_mixin :whitespace
        value.add_mixin :constants
        value.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string)
        value.add_rule Rule.new(/\[/, Tokens::Punctuation, next_state: :array)
        value.add_rule Rule.new(/\{/, Tokens::Punctuation, next_state: :object)
        states[:value] = value

        # :array
        array = State.new(:array)
        array.add_mixin :value
        array.add_rule Rule.new(/\]/, Tokens::Punctuation, pop: true)
        array.add_rule Rule.new(/,/, Tokens::Punctuation)
        states[:array] = array

        # :object
        object = State.new(:object)
        object.add_mixin :whitespace
        object.add_mixin :name
        object.add_mixin :value
        object.add_rule Rule.new(/\}/, Tokens::Punctuation, pop: true)
        object.add_rule Rule.new(/,/, Tokens::Punctuation)
        states[:object] = object

        # :root
        root = State.new(:root)
        root.add_mixin :whitespace
        root.add_rule Rule.new(/\{/, Tokens::Punctuation, next_state: :object)
        root.add_rule Rule.new(/\[/, Tokens::Punctuation, next_state: :array)
        root.add_mixin :name
        root.add_mixin :value
        root.add_rule Rule.new(/[\]\}]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    # Register
    RegexLexer.register("json", JSON)
  end
end
