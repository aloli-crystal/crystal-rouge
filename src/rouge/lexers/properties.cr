module Rouge
  module Lexers
    class Properties < RegexLexer
      def self.tag_name : String
        "properties"
      end

      def self.title_text : String
        "Properties"
      end

      def self.desc_text : String
        "Java .properties files"
      end

      def self.file_exts : Array(String)
        ["*.properties"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/[#!].*/, Tokens::CommentSingle)
        root.add_rule Rule.new(
          /([^\s:=]+)(\s*[=:]\s*)(.*)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::NameProperty, m[1]},
              {Tokens::Operator, m[2]},
              {Tokens::Str, m[3]},
            ] of TokenPair
          }
        )
        root.add_rule Rule.new(/.+/, Tokens::Text)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("java-properties", Properties)
  end
end
