module Rouge
  module Lexers
    class DLang < RegexLexer
      def self.tag_name : String
        "d"
      end

      def self.title_text : String
        "D"
      end

      def self.desc_text : String
        "D programming language"
      end

      def self.file_exts : Array(String)
        ["*.d", "*.di"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(abstract alias align asm assert auto body break case cast catch class const continue debug default delegate delete deprecated do else enum export extern final finally for foreach foreach_reverse function goto if immutable import in inout interface invariant is lazy mixin module new nothrow out override package pragma private protected public pure ref return scope shared static struct super switch synchronized template this throw try typedef typeid typeof union unittest version void while with __FILE__ __LINE__ __MODULE__ __FUNCTION__ __PRETTY_FUNCTION__)
        types = %w(bool byte char dchar double float idouble ifloat int ireal long real short ubyte ucent uint ulong ushort wchar string size_t ptrdiff_t)
        constants = %w(true false null)

        comment = State.new(:comment)
        comment.add_rule Rule.new(/[^\n]*/, Tokens::CommentSingle, pop: true)
        states[:comment] = comment

        comment_multi = State.new(:comment_multi)
        comment_multi.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        comment_multi.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        comment_multi.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment_multi] = comment_multi

        comment_nested = State.new(:comment_nested)
        comment_nested.add_rule Rule.new(/\/\+/, Tokens::CommentMultiline, next_state: :comment_nested)
        comment_nested.add_rule Rule.new(/\+\//, Tokens::CommentMultiline, pop: true)
        comment_nested.add_rule Rule.new(/[^\/+]+/, Tokens::CommentMultiline)
        comment_nested.add_rule Rule.new(/[\/+]/, Tokens::CommentMultiline)
        states[:comment_nested] = comment_nested

        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/\//, Tokens::CommentSingle, next_state: :comment)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multi)
        root.add_rule Rule.new(/\/\+/, Tokens::CommentMultiline, next_state: :comment_nested)
        root.add_rule Rule.new(/'(?:\\.|[^'\\])'/, Tokens::StrChar)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/`[^`]*`/, Tokens::StrBacktick)
        root.add_rule Rule.new(/(?:#{constants.join("|")})\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/(?:#{types.join("|")})\b/, Tokens::KeywordType)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/, Tokens::Keyword)
        root.add_rule Rule.new(/0[xX][0-9a-fA-F_]+/, Tokens::NumHex)
        root.add_rule Rule.new(/0[bB][01_]+/, Tokens::NumBin)
        root.add_rule Rule.new(/\d[0-9_]*\.\d[0-9_]*(?:[eE][+-]?\d[0-9_]*)?[fFL]?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d[0-9_]*(?:[uUL]+)?/, Tokens::NumInteger)
        root.add_rule Rule.new(/@[a-zA-Z_]\w*/, Tokens::NameDecorator)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/%&|^~<>=!?:]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("d", DLang)
    RegexLexer.register("dlang", DLang)
  end
end
