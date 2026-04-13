module Rouge
  module Lexers
    class Console < RegexLexer
      def self.tag_name : String
        "console"
      end

      def self.title_text : String
        "Console"
      end

      def self.desc_text : String
        "Shell console/terminal sessions"
      end

      def self.file_exts : Array(String)
        [] of String
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        root = State.new(:root)
        root.add_rule Rule.new(
          /(\$|>) ([^\n]*)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::GenericPrompt, m[1]},
              {Tokens::Text, " " + m[2]},
            ] of TokenPair
          }
        )
        root.add_rule Rule.new(/[^\n$>]+/, Tokens::GenericOutput)
        root.add_rule Rule.new(/\n/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/./, Tokens::GenericOutput)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("console", Console)
    RegexLexer.register("terminal", Console)
  end
end
