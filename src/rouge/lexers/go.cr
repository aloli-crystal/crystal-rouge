module Rouge
  module Lexers
    class Go < RegexLexer
      def self.tag_name : String
        "go"
      end

      def self.title_text : String
        "Go"
      end

      def self.desc_text : String
        "The Go programming language (golang.org)"
      end

      def self.file_exts : Array(String)
        ["*.go"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(
          break case chan const continue default defer else fallthrough for
          func go goto if import interface map package range return select
          struct switch type var
        )

        types = %w(
          bool byte complex64 complex128 error float32 float64
          int int8 int16 int32 int64 rune string
          uint uint8 uint16 uint32 uint64 uintptr
        )

        constants = %w(true false nil iota)

        builtins = %w(
          append cap close complex copy delete imag len make new panic
          print println real recover
        )

        kw_pattern = keywords.join("|")
        type_pattern = types.join("|")
        const_pattern = constants.join("|")
        builtin_pattern = builtins.join("|")

        # :comment_single
        cs = State.new(:comment_single)
        cs.add_rule Rule.new(/[^\n]*/, Tokens::CommentSingle, pop: true)
        states[:comment_single] = cs

        # :comment_multi
        cm = State.new(:comment_multi)
        cm.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        cm.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        cm.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment_multi] = cm

        # :string_double
        sd = State.new(:string_double)
        sd.add_rule Rule.new(/\\./, Tokens::StrEscape)
        sd.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        sd.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string_double] = sd

        # :string_raw
        sr = State.new(:string_raw)
        sr.add_rule Rule.new(/[^`]+/, Tokens::StrBacktick)
        sr.add_rule Rule.new(/`/, Tokens::StrBacktick, pop: true)
        states[:string_raw] = sr

        # :char
        ch = State.new(:char)
        ch.add_rule Rule.new(/\\./, Tokens::StrEscape)
        ch.add_rule Rule.new(/'/, Tokens::StrChar, pop: true)
        ch.add_rule Rule.new(/[^'\\]+/, Tokens::StrChar)
        states[:char] = ch

        # :root
        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/\//, Tokens::CommentSingle, next_state: :comment_single)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multi)

        root.add_rule Rule.new(Regex.new("\\b(?:#{const_pattern})\\b"), Tokens::KeywordConstant)
        root.add_rule Rule.new(Regex.new("\\b(?:#{kw_pattern})\\b"), Tokens::Keyword)
        root.add_rule Rule.new(Regex.new("\\b(?:#{type_pattern})\\b"), Tokens::KeywordType)
        root.add_rule Rule.new(Regex.new("\\b(?:#{builtin_pattern})\\b"), Tokens::NameBuiltin)

        # Numbers
        root.add_rule Rule.new(/0[xX][0-9a-fA-F_]+/, Tokens::NumHex)
        root.add_rule Rule.new(/0[bB][01_]+/, Tokens::NumBin)
        root.add_rule Rule.new(/0[oO]?[0-7_]+/, Tokens::NumOct)
        root.add_rule Rule.new(/\d[\d_]*\.\d[\d_]*(?:[eE][+-]?\d[\d_]*)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d[\d_]*[eE][+-]?\d[\d_]*/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d[\d_]*/, Tokens::NumInteger)

        # Strings
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/`/, Tokens::StrBacktick, next_state: :string_raw)
        root.add_rule Rule.new(/'/, Tokens::StrChar, next_state: :char)

        # Operators
        root.add_rule Rule.new(/:=|<-|&&|\|\||<<=?|>>=?|&\^=?|[+\-*\/%&|^]=?|[=!<>]=?|\.\.\./, Tokens::Operator)

        # Punctuation
        root.add_rule Rule.new(/[{}()\[\];,.:&*]/, Tokens::Punctuation)

        # Function names
        root.add_rule Rule.new(/[a-zA-Z_]\w*(?=\s*\()/, Tokens::NameFunction)

        # Identifiers
        root.add_rule Rule.new(/[A-Z]\w*/, Tokens::NameClass)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)

        states[:root] = root

        states
      end
    end

    RegexLexer.register("go", Go)
    RegexLexer.register("golang", Go)
  end
end
