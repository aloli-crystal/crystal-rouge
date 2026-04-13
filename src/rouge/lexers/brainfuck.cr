module Rouge
  module Lexers
    class Brainfuck < RegexLexer
      def self.tag_name : String
        "brainfuck"
      end

      def self.title_text : String
        "Brainfuck"
      end

      def self.desc_text : String
        "Brainfuck esoteric programming language"
      end

      def self.file_exts : Array(String)
        ["*.bf", "*.b"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        root = State.new(:root)
        root.add_rule Rule.new(/[><]/, Tokens::Keyword)
        root.add_rule Rule.new(/[+\-]/, Tokens::Operator)
        root.add_rule Rule.new(/[\[\]]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[.,]/, Tokens::NameBuiltin)
        root.add_rule Rule.new(/[^><+\-\[\].,]+/, Tokens::CommentSingle)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("brainfuck", Brainfuck)
    RegexLexer.register("bf", Brainfuck)
  end
end
