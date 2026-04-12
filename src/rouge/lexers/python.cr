module Rouge
  module Lexers
    class Python < RegexLexer
      def self.tag_name : String
        "python"
      end

      def self.title_text : String
        "Python"
      end

      def self.desc_text : String
        "Python programming language (python.org)"
      end

      def self.file_exts : Array(String)
        ["*.py", "*.pyw", "*.pyi"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(and as assert async await break class continue def del elif else except finally for from global if import in is lambda nonlocal not or pass raise return try while with yield)
        builtins = %w(print len range type int str float bool list dict tuple set input open map filter zip enumerate sorted reversed abs min max sum round isinstance issubclass hasattr getattr setattr super property staticmethod classmethod object bytes bytearray memoryview frozenset complex hex oct bin chr ord repr format hash id iter next vars dir help any all)
        constants = %w(None True False NotImplemented Ellipsis __debug__)

        # :comment
        comment = State.new(:comment)
        comment.add_rule Rule.new(/[^\n]*/, Tokens::CommentSingle, pop: true)
        states[:comment] = comment

        # :string_double
        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        # :string_single
        string_single = State.new(:string_single)
        string_single.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_single.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        string_single.add_rule Rule.new(/[^'\\]+/, Tokens::StrSingle)
        states[:string_single] = string_single

        # :string_triple_double
        string_triple_double = State.new(:string_triple_double)
        string_triple_double.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_triple_double.add_rule Rule.new(/"""/, Tokens::StrDoc, pop: true)
        string_triple_double.add_rule Rule.new(/[^"\\]+/, Tokens::StrDoc)
        string_triple_double.add_rule Rule.new(/"/, Tokens::StrDoc)
        states[:string_triple_double] = string_triple_double

        # :string_triple_single
        string_triple_single = State.new(:string_triple_single)
        string_triple_single.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_triple_single.add_rule Rule.new(/'''/, Tokens::StrDoc, pop: true)
        string_triple_single.add_rule Rule.new(/[^'\\]+/, Tokens::StrDoc)
        string_triple_single.add_rule Rule.new(/'/, Tokens::StrDoc)
        states[:string_triple_single] = string_triple_single

        # :root
        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/#/, Tokens::CommentSingle, next_state: :comment)

        # Decorators
        root.add_rule Rule.new(/@[\w.]+/, Tokens::NameDecorator)

        # Keywords
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/, Tokens::Keyword)

        # Constants
        root.add_rule Rule.new(/(?:#{constants.join("|")})\b/, Tokens::KeywordConstant)

        # Builtins
        root.add_rule Rule.new(/(?:#{builtins.join("|")})\b/, Tokens::NameBuiltin)

        # Magic methods/attributes
        root.add_rule Rule.new(/__\w+__/, Tokens::NameFunctionMagic)

        # f-strings / prefixed strings (must be before identifiers)
        root.add_rule Rule.new(/[fFbBrRuU]{1,2}"""/, Tokens::StrAffix, next_state: :string_triple_double)
        root.add_rule Rule.new(/[fFbBrRuU]{1,2}'''/, Tokens::StrAffix, next_state: :string_triple_single)
        root.add_rule Rule.new(/[fFbBrRuU]{1,2}"/, Tokens::StrAffix, next_state: :string_double)
        root.add_rule Rule.new(/[fFbBrRuU]{1,2}'/, Tokens::StrAffix, next_state: :string_single)

        # Triple-quoted strings (must be before single-quoted)
        root.add_rule Rule.new(/"""/, Tokens::StrDoc, next_state: :string_triple_double)
        root.add_rule Rule.new(/'''/, Tokens::StrDoc, next_state: :string_triple_single)

        # Strings
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)

        # Function calls
        root.add_rule Rule.new(/[a-zA-Z_]\w*(?=\s*\()/, Tokens::NameFunction)

        # Identifiers
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)

        # Numbers
        root.add_rule Rule.new(/0[bB][01]+(?:_[01]+)*/, Tokens::NumBin)
        root.add_rule Rule.new(/0[oO][0-7]+(?:_[0-7]+)*/, Tokens::NumOct)
        root.add_rule Rule.new(/0[xX][0-9a-fA-F]+(?:_[0-9a-fA-F]+)*/, Tokens::NumHex)
        root.add_rule Rule.new(/(?:\d+(?:_\d+)*\.?\d*(?:_\d+)*|\.\d+(?:_\d+)*)(?:[eE][+-]?\d+(?:_\d+)*)?[jJ]/, Tokens::NumOther)
        root.add_rule Rule.new(/(?:\d+(?:_\d+)*\.\d*(?:_\d+)*|\.\d+(?:_\d+)*)(?:[eE][+-]?\d+(?:_\d+)*)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+(?:_\d+)*[eE][+-]?\d+(?:_\d+)*/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+(?:_\d+)*/, Tokens::NumInteger)

        # Operators
        root.add_rule Rule.new(/(?:!=|==|<=|>=|<<=|>>=|\*\*=|\/\/=|<<|>>|\*\*|\/\/|:=|[+\-*\/%&|^~<>=@!])/, Tokens::Operator)

        # Punctuation
        root.add_rule Rule.new(/[{}()\[\];,.:@]/, Tokens::Punctuation)

        states[:root] = root

        states
      end
    end

    # Register
    RegexLexer.register("python", Python)
    RegexLexer.register("py", Python)
  end
end
