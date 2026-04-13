module Rouge
  module Lexers
    class EscapeSequence < RegexLexer
      def self.tag_name : String
        "escape"
      end

      def self.title_text : String
        "Escape"
      end

      def self.desc_text : String
        "ANSI escape sequences"
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
        root.add_rule Rule.new(/\x1b\[[0-9;]*[a-zA-Z]/, Tokens::Escape)
        root.add_rule Rule.new(/\x1b\][^\x07]*\x07/, Tokens::Escape)
        root.add_rule Rule.new(/\x1b[^[\]\s]/, Tokens::Escape)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/[^\x1b\s]+/, Tokens::Text)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("escape", EscapeSequence)
  end
end
