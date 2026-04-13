module Rouge
  module Lexers
    class LiterateHaskell < RegexLexer
      def self.tag_name : String
        "literate_haskell"
      end

      def self.title_text : String
        "Literate Haskell"
      end

      def self.desc_text : String
        "Literate Haskell (Bird-style or LaTeX)"
      end

      def self.file_exts : Array(String)
        ["*.lhs"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        haskell_keywords = %w(module import where let in do case of if then else class instance data type newtype deriving infixl infixr infix default foreign)

        code_line = State.new(:code_line)
        code_line.add_rule Rule.new(/\n/, Tokens::TextWhitespace, pop: true)
        code_line.add_rule Rule.new(/--[^\n]*/, Tokens::CommentSingle)
        code_line.add_rule Rule.new(/"(?:[^"\\]|\\.)*"/, Tokens::StrDouble)
        code_line.add_rule Rule.new(/'(?:[^'\\]|\\.)'/, Tokens::StrChar)
        code_line.add_rule Rule.new(/(?:#{haskell_keywords.join("|")})\b/, Tokens::Keyword)
        code_line.add_rule Rule.new(/[A-Z][a-zA-Z0-9_']*/, Tokens::NameClass)
        code_line.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        code_line.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        code_line.add_rule Rule.new(/[a-z_][a-zA-Z0-9_']*/, Tokens::Name)
        code_line.add_rule Rule.new(/[+\-*\/%&|^~<>=!@#$:.\\]+/, Tokens::Operator)
        code_line.add_rule Rule.new(/[{}()\[\];,]/, Tokens::Punctuation)
        code_line.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        states[:code_line] = code_line

        root = State.new(:root)
        root.add_rule Rule.new(/>/, Tokens::GenericPrompt, next_state: :code_line)
        root.add_rule Rule.new(/\\begin\{code\}/, Tokens::CommentPreproc)
        root.add_rule Rule.new(/\\end\{code\}/, Tokens::CommentPreproc)
        root.add_rule Rule.new(/[^\n]+/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\n/, Tokens::TextWhitespace)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("literate_haskell", LiterateHaskell)
    RegexLexer.register("lhs", LiterateHaskell)
  end
end
