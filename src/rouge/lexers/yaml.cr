module Rouge
  module Lexers
    class YAML < RegexLexer
      def self.tag_name : String
        "yaml"
      end

      def self.title_text : String
        "YAML"
      end

      def self.desc_text : String
        "YAML Ain't Markup Language (yaml.org)"
      end

      def self.file_exts : Array(String)
        ["*.yaml", "*.yml"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        # :string_double
        sd = State.new(:string_double)
        sd.add_rule Rule.new(/\\./, Tokens::StrEscape)
        sd.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        sd.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        states[:string_double] = sd

        # :string_single
        ss = State.new(:string_single)
        ss.add_rule Rule.new(/''/, Tokens::StrEscape)
        ss.add_rule Rule.new(/[^']+/, Tokens::StrSingle)
        ss.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        states[:string_single] = ss

        # :root
        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)

        # Comments
        root.add_rule Rule.new(/#.*$/, Tokens::CommentSingle)

        # Document markers
        root.add_rule Rule.new(/^---(?:\s|$)/, Tokens::NameNamespace)
        root.add_rule Rule.new(/^\.\.\.(?:\s|$)/, Tokens::NameNamespace)

        # Tags
        root.add_rule Rule.new(/!![a-zA-Z_][\w-]*/, Tokens::KeywordType)
        root.add_rule Rule.new(/![a-zA-Z_][\w-]*/, Tokens::KeywordType)

        # Anchors and aliases
        root.add_rule Rule.new(/&[a-zA-Z_][\w-]*/, Tokens::NameLabel)
        root.add_rule Rule.new(/\*[a-zA-Z_][\w-]*/, Tokens::NameVariable)

        # Block scalars
        root.add_rule Rule.new(/[|>][+-]?/, Tokens::Punctuation)

        # Key: value (key before colon)
        root.add_rule Rule.new(
          /([a-zA-Z_][\w.-]*)(\s*)(:)(?=\s|$)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::NameLabel, m[1]},
              {Tokens::TextWhitespace, m[2]},
              {Tokens::Punctuation, m[3]},
            ] of TokenPair
          }
        )

        # Quoted key: value
        root.add_rule Rule.new(
          /("(?:\\.|[^"\\])*?")(\s*)(:)(?=\s|$)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::NameLabel, m[1]},
              {Tokens::TextWhitespace, m[2]},
              {Tokens::Punctuation, m[3]},
            ] of TokenPair
          }
        )

        # List indicator
        root.add_rule Rule.new(/^[\t ]*-(?=\s)/, Tokens::Punctuation)

        # Strings
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)

        # Boolean values
        root.add_rule Rule.new(/\b(?:true|false|yes|no|on|off)\b/i, Tokens::KeywordConstant)

        # Null
        root.add_rule Rule.new(/\b(?:null|~)\b/, Tokens::KeywordConstant)

        # Numbers
        root.add_rule Rule.new(/[-+]?0x[0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/[-+]?\d+\.\d+(?:[eE][+-]?\d+)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/[-+]?\.\d+(?:[eE][+-]?\d+)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/[-+]?(?:\.inf|\.Inf|\.INF)\b/, Tokens::NumFloat)
        root.add_rule Rule.new(/\.(?:nan|NaN|NAN)\b/, Tokens::NumFloat)
        root.add_rule Rule.new(/[-+]?\d+/, Tokens::NumInteger)

        # Punctuation
        root.add_rule Rule.new(/[{}\[\],]/, Tokens::Punctuation)
        root.add_rule Rule.new(/:(?=\s)/, Tokens::Punctuation)

        # Unquoted strings / values
        root.add_rule Rule.new(/[^\s#"',\[\]{}:&*!|>]+/, Tokens::Str)

        states[:root] = root

        states
      end
    end

    RegexLexer.register("yaml", YAML)
    RegexLexer.register("yml", YAML)
  end
end
