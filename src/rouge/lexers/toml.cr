module Rouge
  module Lexers
    class TOML < RegexLexer
      def self.tag_name : String
        "toml"
      end

      def self.title_text : String
        "TOML"
      end

      def self.desc_text : String
        "Tom's Obvious Minimal Language"
      end

      def self.file_exts : Array(String)
        ["*.toml"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        # :string_basic
        sb = State.new(:string_basic)
        sb.add_rule Rule.new(/\\[btnfr"\\uU]/, Tokens::StrEscape)
        sb.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        sb.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        states[:string_basic] = sb

        # :string_literal
        sl = State.new(:string_literal)
        sl.add_rule Rule.new(/[^']+/, Tokens::StrSingle)
        sl.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        states[:string_literal] = sl

        # :root
        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)

        # Comments
        root.add_rule Rule.new(/#.*$/, Tokens::CommentSingle)

        # Array of tables
        root.add_rule Rule.new(
          /(\[\[)([\w.-]+)(\]\])/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::Punctuation, m[1]},
              {Tokens::NameNamespace, m[2]},
              {Tokens::Punctuation, m[3]},
            ] of TokenPair
          }
        )

        # Tables
        root.add_rule Rule.new(
          /(\[)([\w.-]+)(\])/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::Punctuation, m[1]},
              {Tokens::NameNamespace, m[2]},
              {Tokens::Punctuation, m[3]},
            ] of TokenPair
          }
        )

        # Key = value (bare keys)
        root.add_rule Rule.new(
          /([\w-]+)(\s*=\s*)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::NameLabel, m[1]},
              {Tokens::Operator, m[2]},
            ] of TokenPair
          }
        )

        # Quoted keys
        root.add_rule Rule.new(
          /("(?:\\.|[^"\\])*?")(\s*=\s*)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::NameLabel, m[1]},
              {Tokens::Operator, m[2]},
            ] of TokenPair
          }
        )

        # Multi-line basic strings
        root.add_rule Rule.new(/"""[\s\S]*?"""/, Tokens::StrDouble)

        # Multi-line literal strings
        root.add_rule Rule.new(/'''[\s\S]*?'''/, Tokens::StrSingle)

        # Basic strings
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_basic)

        # Literal strings
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_literal)

        # Booleans
        root.add_rule Rule.new(/\b(?:true|false)\b/, Tokens::KeywordConstant)

        # Dates/datetimes
        root.add_rule Rule.new(/\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:\d{2})?/, Tokens::LiteralDate)
        root.add_rule Rule.new(/\d{4}-\d{2}-\d{2}/, Tokens::LiteralDate)
        root.add_rule Rule.new(/\d{2}:\d{2}:\d{2}(?:\.\d+)?/, Tokens::LiteralDate)

        # Numbers: hex, octal, binary
        root.add_rule Rule.new(/0x[0-9a-fA-F_]+/, Tokens::NumHex)
        root.add_rule Rule.new(/0o[0-7_]+/, Tokens::NumOct)
        root.add_rule Rule.new(/0b[01_]+/, Tokens::NumBin)

        # Special float values
        root.add_rule Rule.new(/[+-]?(?:inf|nan)\b/, Tokens::NumFloat)

        # Float
        root.add_rule Rule.new(/[+-]?\d[\d_]*\.\d[\d_]*(?:[eE][+-]?\d[\d_]*)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/[+-]?\d[\d_]*[eE][+-]?\d[\d_]*/, Tokens::NumFloat)

        # Integer
        root.add_rule Rule.new(/[+-]?\d[\d_]*/, Tokens::NumInteger)

        # Punctuation
        root.add_rule Rule.new(/[{}\[\],.]/, Tokens::Punctuation)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("toml", TOML)
  end
end
