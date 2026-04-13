module Rouge
  module Lexers
    class INI < RegexLexer
      def self.tag_name : String
        "ini"
      end

      def self.title_text : String
        "INI"
      end

      def self.desc_text : String
        "INI configuration file format"
      end

      def self.file_exts : Array(String)
        ["*.ini", "*.cfg", "*.properties"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        # :value
        value = State.new(:value)
        value.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        value.add_rule Rule.new(/[;#][^\n]*/, Tokens::CommentSingle, pop: true)
        value.add_rule Rule.new(/"[^"]*"/, Tokens::StrDouble)
        value.add_rule Rule.new(/'[^']*'/, Tokens::StrSingle)
        value.add_rule Rule.new(/\b(?:true|false|yes|no|on|off)\b/i, Tokens::KeywordConstant)
        value.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        value.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        value.add_rule Rule.new(/$/, Tokens::TextWhitespace, pop: true)
        value.add_rule Rule.new(/[^\s;#"']+/, Tokens::Str)
        states[:value] = value

        # :root
        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)

        # Comments
        root.add_rule Rule.new(/[;#][^\n]*/, Tokens::CommentSingle)

        # Sections
        root.add_rule Rule.new(
          /(\[)([^\]]+)(\])/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::Punctuation, m[1]},
              {Tokens::NameNamespace, m[2]},
              {Tokens::Punctuation, m[3]},
            ] of TokenPair
          }
        )

        # Key = value or Key : value
        root.add_rule Rule.new(
          /([^\s=:;\[#][^=:]*?)\s*([=:])/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::NameLabel, m[1].strip},
              {Tokens::Operator, m[2]},
            ] of TokenPair
          },
          next_state: :value
        )

        states[:root] = root

        states
      end
    end

    RegexLexer.register("ini", INI)
    RegexLexer.register("cfg", INI)
    RegexLexer.register("properties", INI)
  end
end
