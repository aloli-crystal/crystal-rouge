module Rouge
  module Lexers
    class Perl < RegexLexer
      def self.tag_name : String
        "perl"
      end

      def self.title_text : String
        "Perl"
      end

      def self.desc_text : String
        "The Perl programming language (perl.org)"
      end

      def self.file_exts : Array(String)
        ["*.pl", "*.pm", "*.t"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(
          bless caller cmp continue die do dump else elsif eq eval exit for
          foreach ge goto grep gt if import last le local lt map my ne next no
          our package print printf redo require return say sort sub tie tied
          unless until untie use wantarray warn while
        )

        builtins = %w(
          chomp chop chr close defined delete each exists fileno hex index int
          join keys lc lcfirst length oct open ord pack pop pos push quotemeta
          read ref reverse rindex scalar seek shift splice split sprintf substr
          system tell uc ucfirst unlink unpack unshift values write
        )

        kw_pattern = keywords.join("|")
        builtin_pattern = builtins.join("|")

        # :comment_single
        cs = State.new(:comment_single)
        cs.add_rule Rule.new(/[^\n]*/, Tokens::CommentSingle, pop: true)
        states[:comment_single] = cs

        # :string_double
        sd = State.new(:string_double)
        sd.add_rule Rule.new(/\\./, Tokens::StrEscape)
        sd.add_rule Rule.new(/\$[a-zA-Z_]\w*(?:::[a-zA-Z_]\w*)*/, Tokens::NameVariable)
        sd.add_rule Rule.new(/@[a-zA-Z_]\w*/, Tokens::NameVariable)
        sd.add_rule Rule.new(/[^"\\$@]+/, Tokens::StrDouble)
        sd.add_rule Rule.new(/[$@]/, Tokens::StrDouble)
        sd.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        states[:string_double] = sd

        # :string_single
        ss = State.new(:string_single)
        ss.add_rule Rule.new(/\\./, Tokens::StrEscape)
        ss.add_rule Rule.new(/[^'\\]+/, Tokens::StrSingle)
        ss.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        states[:string_single] = ss

        # :regex
        rx = State.new(:regex)
        rx.add_rule Rule.new(/\\./, Tokens::StrEscape)
        rx.add_rule Rule.new(/[^\/\\]+/, Tokens::StrRegex)
        rx.add_rule Rule.new(/\/[msixpodualngc]*/, Tokens::StrRegex, pop: true)
        states[:regex] = rx

        # :root
        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/#/, Tokens::CommentSingle, next_state: :comment_single)

        root.add_rule Rule.new(Regex.new("\\b(?:#{kw_pattern})\\b"), Tokens::Keyword)
        root.add_rule Rule.new(Regex.new("\\b(?:#{builtin_pattern})\\b"), Tokens::NameBuiltin)

        # Special variables
        root.add_rule Rule.new(/\$[_!@\/\\,;.<>*$?:&`'+\-~^|%="]/, Tokens::NameVariableGlobal)
        root.add_rule Rule.new(/\$\d+/, Tokens::NameVariableGlobal)

        # Variables
        root.add_rule Rule.new(/\$[a-zA-Z_]\w*(?:::[a-zA-Z_]\w*)*/, Tokens::NameVariable)
        root.add_rule Rule.new(/@[a-zA-Z_]\w*/, Tokens::NameVariable)
        root.add_rule Rule.new(/%[a-zA-Z_]\w*/, Tokens::NameVariable)

        # Numbers
        root.add_rule Rule.new(/0[xX][0-9a-fA-F_]+/, Tokens::NumHex)
        root.add_rule Rule.new(/0[bB][01_]+/, Tokens::NumBin)
        root.add_rule Rule.new(/0[0-7_]+/, Tokens::NumOct)
        root.add_rule Rule.new(/\d+\.\d+(?:[eE][+-]?\d+)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        # Strings
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)

        # Regex: /pattern/ and m/pattern/
        root.add_rule Rule.new(/m?\/(?=[^\s*\/])/, Tokens::StrRegex, next_state: :regex)

        # Operators
        root.add_rule Rule.new(/=>|->|=~|!~|\.\.|[+\-*\/%&|^~!=<>]=?|&&|\|\|/, Tokens::Operator)

        # Punctuation
        root.add_rule Rule.new(/[{}()\[\];,.:?\\]/, Tokens::Punctuation)

        # Function names
        root.add_rule Rule.new(/[a-zA-Z_]\w*(?=\s*\()/, Tokens::NameFunction)

        # Identifiers
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)

        states[:root] = root

        states
      end
    end

    RegexLexer.register("perl", Perl)
    RegexLexer.register("pl", Perl)
  end
end
