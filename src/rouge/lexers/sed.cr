module Rouge
  module Lexers
    class Sed < RegexLexer
      def self.tag_name : String
        "sed"
      end

      def self.title_text : String
        "Sed"
      end

      def self.desc_text : String
        "sed stream editor"
      end

      def self.file_exts : Array(String)
        ["*.sed"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/#.*/, Tokens::CommentSingle)
        # Addresses: line numbers and /regex/
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/\/(?:[^\/\\]|\\.)*\//, Tokens::StrRegex)
        # Substitution command s/pat/repl/flags
        root.add_rule Rule.new(
          /(s)(.)(.+?)(\2)(.+?)(\2)([gimspx]*)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::Keyword, m[1]},
              {Tokens::Punctuation, m[2]},
              {Tokens::StrRegex, m[3]},
              {Tokens::Punctuation, m[4]},
              {Tokens::Str, m[5]},
              {Tokens::Punctuation, m[6]},
              {Tokens::Keyword, m[7]},
            ] of TokenPair
          }
        )
        # Transliterate y/src/dst/
        root.add_rule Rule.new(
          /(y)(.)(.+?)(\2)(.+?)(\2)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::Keyword, m[1]},
              {Tokens::Punctuation, m[2]},
              {Tokens::Str, m[3]},
              {Tokens::Punctuation, m[4]},
              {Tokens::Str, m[5]},
              {Tokens::Punctuation, m[6]},
            ] of TokenPair
          }
        )
        # Single-char commands
        root.add_rule Rule.new(/[dpqaicbrwt]/, Tokens::Keyword)
        root.add_rule Rule.new(/[{}();,]/, Tokens::Punctuation)
        root.add_rule Rule.new(/"[^"]*"/, Tokens::StrDouble)
        root.add_rule Rule.new(/./, Tokens::Text)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("sed", Sed)
  end
end
