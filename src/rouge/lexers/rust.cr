module Rouge
  module Lexers
    class Rust < RegexLexer
      def self.tag_name : String
        "rust"
      end

      def self.title_text : String
        "Rust"
      end

      def self.desc_text : String
        "The Rust programming language (rust-lang.org)"
      end

      def self.file_exts : Array(String)
        ["*.rs"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(
          as async await break const continue crate dyn else enum extern fn for
          if impl in let loop match mod move mut pub ref return self Self static
          struct super trait type unsafe use where while macro_rules
        )

        types = %w(
          i8 i16 i32 i64 i128 isize u8 u16 u32 u64 u128 usize f32 f64
          bool char str String Vec Option Result Box Rc Arc HashMap HashSet
        )

        builtins_raw = %w(
          println print eprintln eprint format vec panic todo unimplemented
          unreachable assert assert_eq assert_ne dbg cfg include include_str
          include_bytes concat stringify env file line column module_path
        )

        kw_pattern = keywords.join("|")
        type_pattern = types.join("|")

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
        sr.add_rule Rule.new(/"#*/, Tokens::StrDouble, pop: true)
        sr.add_rule Rule.new(/[^"]+/, Tokens::StrDouble)
        states[:string_raw] = sr

        # :char
        ch = State.new(:char)
        ch.add_rule Rule.new(/\\./, Tokens::StrEscape)
        ch.add_rule Rule.new(/'/, Tokens::StrChar, pop: true)
        ch.add_rule Rule.new(/[^'\\]/, Tokens::StrChar)
        states[:char] = ch

        # :attribute
        attr = State.new(:attribute)
        attr.add_rule Rule.new(/[^\]]+/, Tokens::NameDecorator)
        attr.add_rule Rule.new(/\]/, Tokens::NameDecorator, pop: true)
        states[:attribute] = attr

        # :root
        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)

        # Comments (doc comments first)
        root.add_rule Rule.new(/\/\/\/.*/, Tokens::CommentDoc)
        root.add_rule Rule.new(/\/\/!.*/, Tokens::CommentDoc)
        root.add_rule Rule.new(/\/\//, Tokens::CommentSingle, next_state: :comment_single)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multi)

        # Attributes
        root.add_rule Rule.new(/#!\[/, Tokens::NameDecorator, next_state: :attribute)
        root.add_rule Rule.new(/#\[/, Tokens::NameDecorator, next_state: :attribute)

        # Constants
        root.add_rule Rule.new(/\b(?:true|false)\b/, Tokens::KeywordConstant)

        root.add_rule Rule.new(Regex.new("\\b(?:#{kw_pattern})\\b"), Tokens::Keyword)
        root.add_rule Rule.new(Regex.new("\\b(?:#{type_pattern})\\b"), Tokens::KeywordType)

        # Macro builtins (name followed by !)
        builtin_macro_pattern = builtins_raw.join("|")
        root.add_rule Rule.new(Regex.new("\\b(?:#{builtin_macro_pattern})!"), Tokens::NameBuiltin)

        # Lifetimes (after non-alpha: 'a, 'static, etc.)
        root.add_rule Rule.new(/'[a-zA-Z_]\w*/, Tokens::NameLabel)

        # Numbers
        root.add_rule Rule.new(/0[xX][0-9a-fA-F_]+(?:_?(?:i|u)(?:8|16|32|64|128|size))?/, Tokens::NumHex)
        root.add_rule Rule.new(/0[bB][01_]+(?:_?(?:i|u)(?:8|16|32|64|128|size))?/, Tokens::NumBin)
        root.add_rule Rule.new(/0[oO][0-7_]+(?:_?(?:i|u)(?:8|16|32|64|128|size))?/, Tokens::NumOct)
        root.add_rule Rule.new(/\d[\d_]*\.\d[\d_]*(?:[eE][+-]?\d[\d_]*)?(?:_?f(?:32|64))?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d[\d_]*[eE][+-]?\d[\d_]*(?:_?f(?:32|64))?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d[\d_]*(?:_?(?:i|u)(?:8|16|32|64|128|size)|_?f(?:32|64))?/, Tokens::NumInteger)

        # Strings
        root.add_rule Rule.new(/r#+"/, Tokens::StrDouble, next_state: :string_raw)
        root.add_rule Rule.new(/r"/, Tokens::StrDouble, next_state: :string_raw)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/b?'/, Tokens::StrChar, next_state: :char)

        # Operators
        root.add_rule Rule.new(/=>|->|&&|\|\||<<=?|>>=?|\.\.=?|[+\-*\/%&|^!=<>]=?|@/, Tokens::Operator)

        # Punctuation
        root.add_rule Rule.new(/[{}()\[\];,.::#&?]/, Tokens::Punctuation)

        # Macro invocations (identifier!)
        root.add_rule Rule.new(/[a-zA-Z_]\w*!/, Tokens::NameFunction)

        # Function names
        root.add_rule Rule.new(/[a-zA-Z_]\w*(?=\s*\()/, Tokens::NameFunction)

        # Type names (uppercase start)
        root.add_rule Rule.new(/[A-Z]\w*/, Tokens::NameClass)

        # Identifiers
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)

        states[:root] = root

        states
      end
    end

    RegexLexer.register("rust", Rust)
    RegexLexer.register("rs", Rust)
  end
end
