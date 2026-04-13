module Rouge
  module Lexers
    class Julia < RegexLexer
      def self.tag_name : String
        "julia"
      end

      def self.title_text : String
        "Julia"
      end

      def self.desc_text : String
        "Julia programming language"
      end

      def self.file_exts : Array(String)
        ["*.jl"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(abstract baremodule begin break catch ccall const continue do else elseif end export finally for function global if import in isa let local macro module mutable new primitive quote return struct try type typealias using where while)
        types = %w(Int8 Int16 Int32 Int64 Int128 UInt8 UInt16 UInt32 UInt64 UInt128 Float16 Float32 Float64 Bool Char String Symbol Array Dict Set Tuple Nothing Any Union Type Function IO Number Integer AbstractFloat Real Complex Rational BigInt BigFloat Vector Matrix Regex SubString IOBuffer Channel Task Ref Ptr)
        constants = %w(true false nothing missing Inf NaN pi)

        comment = State.new(:comment)
        comment.add_rule Rule.new(/[^\n]*/, Tokens::CommentSingle, pop: true)
        states[:comment] = comment

        comment_multi = State.new(:comment_multi)
        comment_multi.add_rule Rule.new(/#=/, Tokens::CommentMultiline, next_state: :comment_multi)
        comment_multi.add_rule Rule.new(/=#/, Tokens::CommentMultiline, pop: true)
        comment_multi.add_rule Rule.new(/[^#=]+/, Tokens::CommentMultiline)
        comment_multi.add_rule Rule.new(/[#=]/, Tokens::CommentMultiline)
        states[:comment_multi] = comment_multi

        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_double.add_rule Rule.new(/\$(?:\([^)]*\)|[a-zA-Z_]\w*)/, Tokens::StrInterpol)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\$]+/, Tokens::StrDouble)
        string_double.add_rule Rule.new(/\$/, Tokens::StrDouble)
        states[:string_double] = string_double

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/#=/, Tokens::CommentMultiline, next_state: :comment_multi)
        root.add_rule Rule.new(/#/, Tokens::CommentSingle, next_state: :comment)
        root.add_rule Rule.new(/"""(?:[^"\\]|\\.)*"""/m, Tokens::StrDoc)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'(?:\\.|[^'\\])'/, Tokens::StrChar)
        root.add_rule Rule.new(/@[a-zA-Z_]\w*/, Tokens::NameDecorator)
        root.add_rule Rule.new(/(?:#{constants.join("|")})\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/(?:#{types.join("|")})\b/, Tokens::KeywordType)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/, Tokens::Keyword)
        root.add_rule Rule.new(/0[xX][0-9a-fA-F_]+/, Tokens::NumHex)
        root.add_rule Rule.new(/0[bB][01_]+/, Tokens::NumBin)
        root.add_rule Rule.new(/0[oO][0-7_]+/, Tokens::NumOct)
        root.add_rule Rule.new(/\d+\.\d*(?:[eE][+-]?\d+)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+[eE][+-]?\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/%&|^~<>=!:÷⊻∈∉∋∌⊆⊇⊂⊃∩∪]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("julia", Julia)
    RegexLexer.register("jl", Julia)
  end
end
