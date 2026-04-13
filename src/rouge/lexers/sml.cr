module Rouge
  module Lexers
    class SML < RegexLexer
      def self.tag_name : String
        "sml"
      end

      def self.title_text : String
        "Standard ML"
      end

      def self.desc_text : String
        "Standard ML programming language"
      end

      def self.file_exts : Array(String)
        ["*.sml", "*.sig", "*.fun"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(
          abstype and andalso as case datatype do else end eqtype exception fn
          fun functor handle if in include infix infixr let local nonfix of op
          open orelse raise rec sharing sig signature struct structure then type
          val where while with withtype
        )

        kw_pattern = keywords.join("|")

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\(\*/, Tokens::CommentMultiline, next_state: :comment)
        root.add_rule Rule.new(Regex.new("\\b(?:#{kw_pattern})\\b"), Tokens::Keyword)
        root.add_rule Rule.new(/(?:true|false|nil|NONE|SOME)\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/#"[^"\\]"/, Tokens::StrChar)
        root.add_rule Rule.new(/#"\\.?"/, Tokens::StrChar)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string)
        root.add_rule Rule.new(/~?\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/~?\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/0x[0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/[=<>!+\-*\/]+|::|=>|->/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.:_|]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_']\w*/, Tokens::Name)
        states[:root] = root

        comment = State.new(:comment)
        comment.add_rule Rule.new(/\(\*/, Tokens::CommentMultiline, next_state: :comment)
        comment.add_rule Rule.new(/\*\)/, Tokens::CommentMultiline, pop: true)
        comment.add_rule Rule.new(/[^(*)+]+/, Tokens::CommentMultiline)
        comment.add_rule Rule.new(/[(*)]/, Tokens::CommentMultiline)
        states[:comment] = comment

        str = State.new(:string)
        str.add_rule Rule.new(/\\./, Tokens::StrEscape)
        str.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        str.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string] = str

        states
      end
    end

    RegexLexer.register("sml", SML)
    RegexLexer.register("standard-ml", SML)
  end
end
