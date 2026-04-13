module Rouge
  module Lexers
    class Email < RegexLexer
      def self.tag_name : String
        "email"
      end

      def self.title_text : String
        "Email"
      end

      def self.desc_text : String
        "Email/MIME message format"
      end

      def self.file_exts : Array(String)
        ["*.eml", "*.msg"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(
          /^([\w\-]+)(:)(\s*)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::NameAttribute, m[1]},
              {Tokens::Punctuation, m[2]},
              {Tokens::TextWhitespace, m[3]},
            ] of TokenPair
          }
        )
        root.add_rule Rule.new(/<[^>\s]+>/, Tokens::NameLabel)
        root.add_rule Rule.new(/[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}/, Tokens::NameLabel)
        root.add_rule Rule.new(/"[^"]*"/, Tokens::StrDouble)
        root.add_rule Rule.new(/[^\s<>"@]+/, Tokens::Text)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("email", Email)
  end
end
