module Rouge
  module Lexers
    class Crystal < RegexLexer
      def self.tag_name : String
        "crystal"
      end

      def self.title_text : String
        "Crystal"
      end

      def self.desc_text : String
        "The Crystal programming language (crystal-lang.org)"
      end

      def self.file_exts : Array(String)
        ["*.cr"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(
          abstract alias annotation as asm begin break case class def do else elsif
          end ensure enum extend for forall fun if in include instance_sizeof
          lib macro module next of out pointerof private protected puts raise
          require rescue return select self sizeof struct super then typeof type
          uninitialized union unless until verbatim when while with yield
        )

        builtin_types = %w(
          Int8 Int16 Int32 Int64 Int128 UInt8 UInt16 UInt32 UInt64 UInt128
          Float32 Float64 Bool String Char Nil Array Hash Range Tuple NamedTuple
          Proc Symbol Regex IO File Dir Time Exception Fiber Channel
        )

        kw_pattern = keywords.join("|")
        # is_a? nil? responds_to? need special regex handling
        type_pattern = builtin_types.join("|")

        # :root
        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/#.*$/, Tokens::CommentSingle)
        root.add_rule Rule.new(/(?:true|false)\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/nil\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/(?:is_a\?|nil\?|responds_to\?)\b/, Tokens::Keyword)
        root.add_rule Rule.new(Regex.new("\\b(?:#{kw_pattern})\\b"), Tokens::Keyword)
        root.add_rule Rule.new(Regex.new("\\b(?:#{type_pattern})\\b"), Tokens::NameBuiltin)
        root.add_rule Rule.new(/@\[/, Tokens::NameDecorator, next_state: :annotation)
        root.add_rule Rule.new(/@@[a-zA-Z_]\w*/, Tokens::NameVariableClass)
        root.add_rule Rule.new(/@[a-zA-Z_]\w*/, Tokens::NameVariableInstance)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string)
        root.add_rule Rule.new(/:[a-zA-Z_]\w*[?!]?/, Tokens::StrSymbol)
        root.add_rule Rule.new(/\/(?=[^\s*\/])/, Tokens::StrRegex, next_state: :regex)
        root.add_rule Rule.new(/0x[0-9a-fA-F_]+/, Tokens::NumHex)
        root.add_rule Rule.new(/0b[01_]+/, Tokens::NumBin)
        root.add_rule Rule.new(/0o[0-7_]+/, Tokens::NumOct)
        root.add_rule Rule.new(/\d[\d_]*\.\d[\d_]*(?:e[+-]?\d[\d_]*)?(?:_f(?:32|64))?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d[\d_]*(?:_(?:i|u)(?:8|16|32|64|128))?/, Tokens::NumInteger)
        root.add_rule Rule.new(/[+\-*\/%]=?|[!=<>]=?|<=>|&&|\|\||[&|^~]|<<|>>/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[A-Z]\w*/, Tokens::NameClass)
        root.add_rule Rule.new(/[a-z_]\w*[?!]?/, Tokens::Name)
        states[:root] = root

        # :string
        str = State.new(:string)
        str.add_rule Rule.new(/#\{/, Tokens::StrInterpol, next_state: :string_interp)
        str.add_rule Rule.new(/\\./, Tokens::StrEscape)
        str.add_rule Rule.new(/[^"\\#]+/, Tokens::StrDouble)
        str.add_rule Rule.new(/#/, Tokens::StrDouble)
        str.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        states[:string] = str

        # :string_interp (used within string interpolation)
        si = State.new(:string_interp)
        si.add_rule Rule.new(/[^}]+/, Tokens::StrInterpol)
        si.add_rule Rule.new(/\}/, Tokens::StrInterpol, pop: true)
        states[:string_interp] = si

        # :symbol
        sym = State.new(:symbol)
        sym.add_rule Rule.new(/[a-zA-Z_]\w*[?!]?/, Tokens::StrSymbol, pop: true)
        states[:symbol] = sym

        # :regex
        rx = State.new(:regex)
        rx.add_rule Rule.new(/\\./, Tokens::StrEscape)
        rx.add_rule Rule.new(/[^\/\\]+/, Tokens::StrRegex)
        rx.add_rule Rule.new(/\/[imx]*/, Tokens::StrRegex, pop: true)
        states[:regex] = rx

        # :annotation
        ann = State.new(:annotation)
        ann.add_rule Rule.new(/[^\]]+/, Tokens::NameDecorator)
        ann.add_rule Rule.new(/\]/, Tokens::NameDecorator, pop: true)
        states[:annotation] = ann

        # :comment (kept as a state for potential multiline doc comments)
        comment = State.new(:comment)
        comment.add_rule Rule.new(/.*$/, Tokens::CommentSingle, pop: true)
        states[:comment] = comment

        # :heredoc
        heredoc = State.new(:heredoc)
        heredoc.add_rule Rule.new(/.+/, Tokens::StrHeredoc)
        states[:heredoc] = heredoc

        states
      end
    end

    RegexLexer.register("crystal", Crystal)
  end
end
