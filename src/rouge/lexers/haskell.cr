module Rouge
  module Lexers
    class Haskell < RegexLexer
      def self.tag_name : String
        "haskell"
      end

      def self.title_text : String
        "Haskell"
      end

      def self.desc_text : String
        "The Haskell purely functional programming language (haskell.org)"
      end

      def self.file_exts : Array(String)
        ["*.hs", "*.lhs"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        # :whitespace
        ws = State.new(:whitespace)
        ws.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        states[:whitespace] = ws

        # :comment_block
        cb = State.new(:comment_block)
        cb.add_rule Rule.new(/-\}/, Tokens::CommentMultiline, pop: true)
        cb.add_rule Rule.new(/\{-/, Tokens::CommentMultiline, next_state: :comment_block)
        cb.add_rule Rule.new(/[^{}\-]+/, Tokens::CommentMultiline)
        cb.add_rule Rule.new(/[-{}]/, Tokens::CommentMultiline)
        states[:comment_block] = cb

        # :string
        string = State.new(:string)
        string.add_rule Rule.new(/\\(?:[abfnrtv\\"']|x[0-9a-fA-F]+|o[0-7]+|\d+|&)/, Tokens::StrEscape)
        string.add_rule Rule.new(/[^\\"]+/, Tokens::StrDouble)
        string.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        states[:string] = string

        # :root
        root = State.new(:root)
        root.add_mixin :whitespace

        # Comments
        root.add_rule Rule.new(/--[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\{-/, Tokens::CommentMultiline, next_state: :comment_block)

        # Strings and characters
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string)
        root.add_rule Rule.new(/'(?:\\(?:[abfnrtv\\"']|x[0-9a-fA-F]+|o[0-7]+|\d+)|[^'\\])'/, Tokens::StrChar)

        # Constants (before types to match specific names)
        root.add_rule Rule.new(/\b(?:True|False|Nothing|Just|Left|Right|LT|GT|EQ)\b/, Tokens::KeywordConstant)

        # Types (uppercase identifiers that are known types)
        root.add_rule Rule.new(/\b(?:Int|Integer|Float|Double|Char|String|Bool|IO|Maybe|Either|Ordering|Word|Map|Set|List|Show|Eq|Ord|Num|Functor|Applicative|Monad|Monoid|Semigroup)\b/, Tokens::KeywordType)

        # Keywords
        root.add_rule Rule.new(/\b(?:as|case|class|data|default|deriving|do|else|family|forall|foreign|hiding|if|import|in|infix|infixl|infixr|instance|let|mdo|module|newtype|of|proc|qualified|rec|then|type|where)\b/, Tokens::Keyword)

        # Type names (uppercase start)
        root.add_rule Rule.new(/\b[A-Z][a-zA-Z0-9_']*/, Tokens::NameClass)

        # Operators
        root.add_rule Rule.new(/::/, Tokens::Operator)
        root.add_rule Rule.new(/->/, Tokens::Operator)
        root.add_rule Rule.new(/=>/, Tokens::Operator)
        root.add_rule Rule.new(/<-/, Tokens::Operator)
        root.add_rule Rule.new(/\.\./, Tokens::Operator)
        root.add_rule Rule.new(/`[a-z][a-zA-Z0-9_']*`/, Tokens::Operator)
        root.add_rule Rule.new(/[!#$%&*+.\/<=>?@\\^|\-~:]+/, Tokens::Operator)

        # Numbers
        root.add_rule Rule.new(/0[xX][0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/0[oO][0-7]+/, Tokens::NumOct)
        root.add_rule Rule.new(/\d+\.\d+(?:[eE][+-]?\d+)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+[eE][+-]?\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        # Function names (lowercase start)
        root.add_rule Rule.new(/[a-z_][a-zA-Z0-9_']*/, Tokens::NameFunction)

        # Punctuation
        root.add_rule Rule.new(/[(){}\[\],;]/, Tokens::Punctuation)

        states[:root] = root

        states
      end
    end

    RegexLexer.register("haskell", Haskell)
    RegexLexer.register("hs", Haskell)
  end
end
