module Rouge
  module Lexers
    class Elixir < RegexLexer
      def self.tag_name : String
        "elixir"
      end

      def self.title_text : String
        "Elixir"
      end

      def self.desc_text : String
        "The Elixir programming language (elixir-lang.org)"
      end

      def self.file_exts : Array(String)
        ["*.ex", "*.exs"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(
          after and case catch cond def defcallback defdelegate defexception
          defimpl defmacro defmacrop defmodule defoverridable defp defprotocol
          defstruct do else end fn for if import in not or quote raise receive
          require rescue try unless unquote unquote_splicing use when with
        )

        constants = %w(true false nil)

        kw_pattern = keywords.join("|")
        const_pattern = constants.join("|")

        # :comment_single
        cs = State.new(:comment_single)
        cs.add_rule Rule.new(/[^\n]*/, Tokens::CommentSingle, pop: true)
        states[:comment_single] = cs

        # :string_double
        sd = State.new(:string_double)
        sd.add_rule Rule.new(/#\{/, Tokens::StrInterpol, next_state: :string_interp)
        sd.add_rule Rule.new(/\\./, Tokens::StrEscape)
        sd.add_rule Rule.new(/[^"\\#]+/, Tokens::StrDouble)
        sd.add_rule Rule.new(/#/, Tokens::StrDouble)
        sd.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        states[:string_double] = sd

        # :string_interp
        si = State.new(:string_interp)
        si.add_rule Rule.new(/[^}]+/, Tokens::StrInterpol)
        si.add_rule Rule.new(/\}/, Tokens::StrInterpol, pop: true)
        states[:string_interp] = si

        # :root
        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/#/, Tokens::CommentSingle, next_state: :comment_single)

        root.add_rule Rule.new(Regex.new("\\b(?:#{kw_pattern})\\b"), Tokens::Keyword)
        root.add_rule Rule.new(Regex.new("\\b(?:#{const_pattern})\\b"), Tokens::KeywordConstant)

        # Atoms
        root.add_rule Rule.new(/:[a-zA-Z_]\w*[?!]?/, Tokens::StrSymbol)

        # Sigils
        root.add_rule Rule.new(/~[rswRSW](?:\/[^\/]*\/|"[^"]*"|'[^']*'|\([^)]*\)|\[[^\]]*\]|\{[^}]*\}|\|[^|]*\|)[a-z]*/, Tokens::StrOther)

        # Numbers
        root.add_rule Rule.new(/0[xX][0-9a-fA-F_]+/, Tokens::NumHex)
        root.add_rule Rule.new(/0[bB][01_]+/, Tokens::NumBin)
        root.add_rule Rule.new(/0[oO][0-7_]+/, Tokens::NumOct)
        root.add_rule Rule.new(/\d[\d_]*\.\d[\d_]*(?:[eE][+-]?\d[\d_]*)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d[\d_]*/, Tokens::NumInteger)

        # Strings
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)

        # Operators (including pipe)
        root.add_rule Rule.new(/\|>|->|<-|\\\\|&&|\|\||<>|::|\.\.\.|[+\-*\/%&|^~!=<>]+/, Tokens::Operator)

        # Punctuation
        root.add_rule Rule.new(/[{}()\[\];,.:@]/, Tokens::Punctuation)

        # Module names (capitalized)
        root.add_rule Rule.new(/[A-Z]\w*/, Tokens::NameClass)

        # Function names
        root.add_rule Rule.new(/[a-zA-Z_]\w*[?!]?(?=\s*\()/, Tokens::NameFunction)

        # Identifiers
        root.add_rule Rule.new(/[a-zA-Z_]\w*[?!]?/, Tokens::Name)

        states[:root] = root

        states
      end
    end

    RegexLexer.register("elixir", Elixir)
    RegexLexer.register("ex", Elixir)
  end
end
