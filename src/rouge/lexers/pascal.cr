module Rouge
  module Lexers
    class Pascal < RegexLexer
      def self.tag_name : String
        "pascal"
      end

      def self.title_text : String
        "Pascal"
      end

      def self.desc_text : String
        "Pascal/Delphi/Object Pascal"
      end

      def self.file_exts : Array(String)
        ["*.pas", "*.pp", "*.dpr", "*.dpk", "*.lpr"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(and array begin case class const constructor destructor div do downto else end file for function goto if implementation in inherited interface label mod not object of or packed procedure program record repeat set shl shr string then to type unit until uses var while with xor)
        constants = %w(true false nil)
        types = %w(integer shortint smallint longint int64 byte word longword cardinal boolean bytebool wordbool longbool char ansichar widechar pchar real single double extended comp currency pointer variant)

        comment = State.new(:comment)
        comment.add_rule Rule.new(/[^\n]*/, Tokens::CommentSingle, pop: true)
        states[:comment] = comment

        comment_brace = State.new(:comment_brace)
        comment_brace.add_rule Rule.new(/\}/, Tokens::CommentMultiline, pop: true)
        comment_brace.add_rule Rule.new(/[^}]+/, Tokens::CommentMultiline)
        states[:comment_brace] = comment_brace

        comment_paren = State.new(:comment_paren)
        comment_paren.add_rule Rule.new(/\*\)/, Tokens::CommentMultiline, pop: true)
        comment_paren.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        comment_paren.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment_paren] = comment_paren

        string_single = State.new(:string_single)
        string_single.add_rule Rule.new(/''/, Tokens::StrEscape)
        string_single.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        string_single.add_rule Rule.new(/[^']+/, Tokens::StrSingle)
        states[:string_single] = string_single

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/\//, Tokens::CommentSingle, next_state: :comment)
        root.add_rule Rule.new(/\{/, Tokens::CommentMultiline, next_state: :comment_brace)
        root.add_rule Rule.new(/\(\*/, Tokens::CommentMultiline, next_state: :comment_paren)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)
        root.add_rule Rule.new(/#\d+/, Tokens::StrChar)
        root.add_rule Rule.new(/(?:#{constants.join("|")})\b/i, Tokens::KeywordConstant)
        root.add_rule Rule.new(/(?:#{types.join("|")})\b/i, Tokens::KeywordType)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/i, Tokens::Keyword)
        root.add_rule Rule.new(/\$[0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/\d+\.\d*(?:[eE][+-]?\d+)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/<>=:@^]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("pascal", Pascal)
    RegexLexer.register("delphi", Pascal)
    RegexLexer.register("objectpascal", Pascal)
  end
end
