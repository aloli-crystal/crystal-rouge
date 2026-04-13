module Rouge
  module Lexers
    class Cython < RegexLexer
      def self.tag_name : String
        "cython"
      end

      def self.title_text : String
        "Cython"
      end

      def self.desc_text : String
        "Cython programming language"
      end

      def self.file_exts : Array(String)
        ["*.pyx", "*.pxd", "*.pxi"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(and as assert async await break class continue def del elif else except exec finally for from global if import in is lambda not or pass print raise return try while with yield)
        cython_kw = %w(cdef cpdef ctypedef cimport DEF IF ELIF ELSE include by fused nogil gil property)
        types = %w(int float double char void bint Py_ssize_t size_t long short unsigned signed object str list dict tuple set frozenset bool bytes)

        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        string_single = State.new(:string_single)
        string_single.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_single.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        string_single.add_rule Rule.new(/[^'\\]+/, Tokens::StrSingle)
        states[:string_single] = string_single

        string_tdouble = State.new(:string_tdouble)
        string_tdouble.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_tdouble.add_rule Rule.new(/"""/, Tokens::StrDoc, pop: true)
        string_tdouble.add_rule Rule.new(/[^"\\]+/, Tokens::StrDoc)
        string_tdouble.add_rule Rule.new(/"/, Tokens::StrDoc)
        states[:string_tdouble] = string_tdouble

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/#[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"""/, Tokens::StrDoc, next_state: :string_tdouble)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)
        root.add_rule Rule.new(/(?:#{cython_kw.join("|")})\b/, Tokens::KeywordReserved)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/, Tokens::Keyword)
        root.add_rule Rule.new(/(?:#{types.join("|")})\b/, Tokens::KeywordType)
        root.add_rule Rule.new(/(?:True|False|None)\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/@[a-zA-Z_]\w*/, Tokens::NameDecorator)
        root.add_rule Rule.new(/0x[0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/\d+\.\d*/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/%=<>!&|^~@:]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("cython", Cython)
    RegexLexer.register("pyx", Cython)
  end
end
