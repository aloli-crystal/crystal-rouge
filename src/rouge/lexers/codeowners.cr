module Rouge
  module Lexers
    class Codeowners < RegexLexer
      def self.tag_name : String
        "codeowners"
      end

      def self.title_text : String
        "CODEOWNERS"
      end

      def self.desc_text : String
        "GitHub CODEOWNERS file format"
      end

      def self.file_exts : Array(String)
        ["CODEOWNERS"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/#[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/@[\w\-\/]+/, Tokens::NameBuiltin)
        root.add_rule Rule.new(/[^\s@#]+/, Tokens::Str)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("codeowners", Codeowners)
  end
end
