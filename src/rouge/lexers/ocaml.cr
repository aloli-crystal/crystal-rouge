module Rouge
  module Lexers
    class OCaml < RegexLexer
      def self.tag_name : String
        "ocaml"
      end

      def self.title_text : String
        "OCaml"
      end

      def self.desc_text : String
        "OCaml programming language"
      end

      def self.file_exts : Array(String)
        ["*.ml", "*.mli"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(and as assert asr begin class constraint do done downto else end exception external for fun function functor if in include inherit initializer land lazy let lor lsl lsr lxor match method mod module mutable new nonrec object of open or private rec sig struct then to try type val virtual when while with)
        types = %w(int float char string bool unit list array option ref exn)
        constants = %w(true false)

        comment_multi = State.new(:comment_multi)
        comment_multi.add_rule Rule.new(/\(\*/, Tokens::CommentMultiline, next_state: :comment_multi)
        comment_multi.add_rule Rule.new(/\*\)/, Tokens::CommentMultiline, pop: true)
        comment_multi.add_rule Rule.new(/[^(*]+/, Tokens::CommentMultiline)
        comment_multi.add_rule Rule.new(/[(*]/, Tokens::CommentMultiline)
        states[:comment_multi] = comment_multi

        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\(\*/, Tokens::CommentMultiline, next_state: :comment_multi)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'(?:\\.|[^'\\])'/, Tokens::StrChar)
        root.add_rule Rule.new(/(?:#{constants.join("|")})\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/(?:#{types.join("|")})\b/, Tokens::KeywordType)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/, Tokens::Keyword)
        root.add_rule Rule.new(/0[xX][0-9a-fA-F][0-9a-fA-F_]*/, Tokens::NumHex)
        root.add_rule Rule.new(/0[oO][0-7][0-7_]*/, Tokens::NumOct)
        root.add_rule Rule.new(/0[bB][01][01_]*/, Tokens::NumBin)
        root.add_rule Rule.new(/\d[\d_]*\.\d[\d_]*(?:[eE][+-]?\d[\d_]*)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d[\d_]*/, Tokens::NumInteger)
        root.add_rule Rule.new(/'[a-zA-Z_]\w*/, Tokens::NameVariable)
        root.add_rule Rule.new(/[A-Z]\w*/, Tokens::NameClass)
        root.add_rule Rule.new(/[a-z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/<>=@^|&~!:]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("ocaml", OCaml)
    RegexLexer.register("ml", OCaml)
  end
end
