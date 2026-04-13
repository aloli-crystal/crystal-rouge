module Rouge
  module Lexers
    class JSON5 < RegexLexer
      def self.tag_name : String
        "json5"
      end

      def self.title_text : String
        "JSON5"
      end

      def self.desc_text : String
        "JSON5 data interchange format"
      end

      def self.file_exts : Array(String)
        ["*.json5"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/\/.*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :multiline_comment)
        root.add_rule Rule.new(/(?:true|false|null|Infinity|NaN)\b/, Tokens::KeywordConstant)
        # Key: value pair with unquoted keys
        root.add_rule Rule.new(
          /([a-zA-Z_$][\w$]*)(\s*)(:)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::NameLabel, m[1]},
              {Tokens::TextWhitespace, m[2]},
              {Tokens::Punctuation, m[3]},
            ] of TokenPair
          }
        )
        # Quoted key
        root.add_rule Rule.new(
          /("(?:\\.|[^"\\\n])*?")(\s*)(:)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::NameLabel, m[1]},
              {Tokens::TextWhitespace, m[2]},
              {Tokens::Punctuation, m[3]},
            ] of TokenPair
          }
        )
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :double_string)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :single_string)
        root.add_rule Rule.new(/0[xX][0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/[+-]?\d+\.\d*(?:e[+-]?\d+)?/i, Tokens::NumFloat)
        root.add_rule Rule.new(/[+-]?\d+(?:e[+-]?\d+)?/i, Tokens::NumInteger)
        root.add_rule Rule.new(/[{}\[\]:,]/, Tokens::Punctuation)
        states[:root] = root

        mc = State.new(:multiline_comment)
        mc.add_rule Rule.new(/[^*\/]+/, Tokens::CommentMultiline)
        mc.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        mc.add_rule Rule.new(/[*\/]/, Tokens::CommentMultiline)
        states[:multiline_comment] = mc

        ds = State.new(:double_string)
        ds.add_rule Rule.new(/\\./, Tokens::StrEscape)
        ds.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        ds.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:double_string] = ds

        ss = State.new(:single_string)
        ss.add_rule Rule.new(/\\./, Tokens::StrEscape)
        ss.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        ss.add_rule Rule.new(/[^'\\]+/, Tokens::StrSingle)
        states[:single_string] = ss

        states
      end
    end

    RegexLexer.register("json5", JSON5)
  end
end
