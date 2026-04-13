module Rouge
  module Lexers
    class Conf < RegexLexer
      def self.tag_name : String
        "conf"
      end

      def self.title_text : String
        "Config"
      end

      def self.desc_text : String
        "Generic configuration file format"
      end

      def self.file_exts : Array(String)
        ["*.conf", "*.cfg", "*.ini"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/[#;][^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\[[^\]\n]+\]/, Tokens::NameNamespace)
        root.add_rule Rule.new(
          /([\w.\-]+)(\s*[=:]\s*)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::NameAttribute, m[1]},
              {Tokens::Operator, m[2]},
            ] of TokenPair
          }
        )
        root.add_rule Rule.new(/"[^"]*"/, Tokens::StrDouble)
        root.add_rule Rule.new(/'[^']*'/, Tokens::StrSingle)
        root.add_rule Rule.new(/(?:true|false|yes|no|on|off)\b/i, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\d+\.\d*/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[^\s=:;#\[\]"']+/, Tokens::Str)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("conf", Conf)
    RegexLexer.register("config", Conf)
  end
end
