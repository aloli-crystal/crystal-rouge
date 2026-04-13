module Rouge
  module Lexers
    class Mojo < RegexLexer
      def self.tag_name : String
        "mojo"
      end

      def self.title_text : String
        "Mojo"
      end

      def self.desc_text : String
        "Mojo programming language"
      end

      def self.file_exts : Array(String)
        ["*.mojo", "*.🔥"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(
          and as assert async await break class continue def del elif else except
          finally for from global if import in is lambda not or pass raise return
          try while with yield
          fn struct alias var let owned borrowed inout raises capturing parameter
          always_inline register_passable trait
        )

        builtins = %w(
          SIMD DType Tensor String Int Float Bool True False None self Self
          print len range type isinstance hasattr getattr setattr
          __mlir_type __mlir_op __mlir_attr
        )

        kw_pattern = keywords.join("|")
        bi_pattern = builtins.join("|")

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/#.*/, Tokens::CommentSingle)
        root.add_rule Rule.new(Regex.new("\\b(?:#{kw_pattern})\\b"), Tokens::Keyword)
        root.add_rule Rule.new(Regex.new("\\b(?:#{bi_pattern})\\b"), Tokens::NameBuiltin)
        root.add_rule Rule.new(/"""/, Tokens::StrDoc, next_state: :triple_dq)
        root.add_rule Rule.new(/'''/, Tokens::StrDoc, next_state: :triple_sq)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :double_string)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :single_string)
        root.add_rule Rule.new(/\d+\.\d*(?:e[+-]?\d+)?/i, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+e[+-]?\d+/i, Tokens::NumFloat)
        root.add_rule Rule.new(/0[xX][0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/0[oO][0-7]+/, Tokens::NumOct)
        root.add_rule Rule.new(/0[bB][01]+/, Tokens::NumBin)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/@[a-zA-Z_]\w*/, Tokens::NameDecorator)
        root.add_rule Rule.new(/[+\-*\/%=!<>&|^~]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.:->]+/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        states[:root] = root

        ds = State.new(:double_string)
        ds.add_rule Rule.new(/\\./, Tokens::StrEscape)
        ds.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        ds.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:double_string] = ds

        ss = State.new(:single_string)
        ss.add_rule Rule.new(/\\./, Tokens::StrEscape)
        ss.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        ss.add_rule Rule.new(/[^'\\]+/, Tokens::StrSingle)
        states[:single_string] = ss

        tdq = State.new(:triple_dq)
        tdq.add_rule Rule.new(/"""/, Tokens::StrDoc, pop: true)
        tdq.add_rule Rule.new(/\\./, Tokens::StrEscape)
        tdq.add_rule Rule.new(/[^"\\]+/, Tokens::StrDoc)
        tdq.add_rule Rule.new(/"/, Tokens::StrDoc)
        states[:triple_dq] = tdq

        tsq = State.new(:triple_sq)
        tsq.add_rule Rule.new(/'''/, Tokens::StrDoc, pop: true)
        tsq.add_rule Rule.new(/\\./, Tokens::StrEscape)
        tsq.add_rule Rule.new(/[^'\\]+/, Tokens::StrDoc)
        tsq.add_rule Rule.new(/'/, Tokens::StrDoc)
        states[:triple_sq] = tsq

        states
      end
    end

    RegexLexer.register("mojo", Mojo)
  end
end
