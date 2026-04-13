module Rouge
  module Lexers
    class PlainText < RegexLexer
      def self.tag_name : String
        "plaintext"
      end

      def self.title_text : String
        "Plain Text"
      end

      def self.desc_text : String
        "Plain text with no highlighting"
      end

      def self.file_exts : Array(String)
        ["*.txt"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        root = State.new(:root)
        root.add_rule Rule.new(/.+/m, Tokens::Text)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("plaintext", PlainText)
    RegexLexer.register("text", PlainText)
    RegexLexer.register("plain", PlainText)
  end
end
