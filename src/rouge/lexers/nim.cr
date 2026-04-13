module Rouge
  module Lexers
    class Nim < RegexLexer
      def self.tag_name : String
        "nim"
      end

      def self.title_text : String
        "Nim"
      end

      def self.desc_text : String
        "Nim programming language"
      end

      def self.file_exts : Array(String)
        ["*.nim", "*.nims", "*.nimble"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(addr and as asm bind block break case cast concept const continue converter defer discard distinct div do elif else end enum except export finally for from func if import in include interface is isnot iterator let macro method mixin mod not notin object of or out proc ptr raise ref return shl shr static template try tuple type using var when while xor yield)
        constants = %w(true false nil)
        types = %w(int int8 int16 int32 int64 uint uint8 uint16 uint32 uint64 float float32 float64 bool char string cstring pointer range array seq set tuple void auto any)

        comment = State.new(:comment)
        comment.add_rule Rule.new(/[^\n]*/, Tokens::CommentSingle, pop: true)
        states[:comment] = comment

        comment_multi = State.new(:comment_multi)
        comment_multi.add_rule Rule.new(/#\[/, Tokens::CommentMultiline, next_state: :comment_multi)
        comment_multi.add_rule Rule.new(/\]#/, Tokens::CommentMultiline, pop: true)
        comment_multi.add_rule Rule.new(/[^\]#]+/, Tokens::CommentMultiline)
        comment_multi.add_rule Rule.new(/[\]#]/, Tokens::CommentMultiline)
        states[:comment_multi] = comment_multi

        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/#\[/, Tokens::CommentMultiline, next_state: :comment_multi)
        root.add_rule Rule.new(/#/, Tokens::CommentSingle, next_state: :comment)
        root.add_rule Rule.new(/"""(?:[^"]|"(?!""))*"""/m, Tokens::StrDoc)
        root.add_rule Rule.new(/r"[^"]*"/, Tokens::StrDouble)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'(?:\\.|[^'\\])'/, Tokens::StrChar)
        root.add_rule Rule.new(/(?:#{constants.join("|")})\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/(?:#{types.join("|")})\b/, Tokens::KeywordType)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/, Tokens::Keyword)
        root.add_rule Rule.new(/\{\..*?\.\}/, Tokens::NameDecorator)
        root.add_rule Rule.new(/0[xX][0-9a-fA-F][0-9a-fA-F_]*/, Tokens::NumHex)
        root.add_rule Rule.new(/0[bB][01][01_]*/, Tokens::NumBin)
        root.add_rule Rule.new(/0o[0-7][0-7_]*/, Tokens::NumOct)
        root.add_rule Rule.new(/\d[0-9_]*\.\d[0-9_]*(?:[eE][+-]?\d[0-9_]*)?(?:'?[fFdD]\d+)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d[0-9_]*(?:'?[iIuU]\d+)?/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/<>=@$~&%|!?^.:\\]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("nim", Nim)
    RegexLexer.register("nimrod", Nim)
  end
end
