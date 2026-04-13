module Rouge
  module Lexers
    class Scheme < RegexLexer
      def self.tag_name : String
        "scheme"
      end

      def self.title_text : String
        "Scheme"
      end

      def self.desc_text : String
        "Scheme programming language"
      end

      def self.file_exts : Array(String)
        ["*.scm", "*.ss"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(
          define lambda let let\\* letrec if cond else case and or not begin do
          set! quote quasiquote unquote unquote-splicing define-syntax
          syntax-rules define-macro when unless delay force
          call-with-current-continuation call/cc values call-with-values
          dynamic-wind import export library
        )

        kw_pattern = keywords.join("|")

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/#\|/, Tokens::CommentMultiline, next_state: :multiline_comment)
        root.add_rule Rule.new(/;.*/, Tokens::CommentSingle)
        root.add_rule Rule.new(Regex.new("\\b(?:#{kw_pattern})\\b"), Tokens::Keyword)
        root.add_rule Rule.new(/#[tf]\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/#\\[a-zA-Z]+\b/, Tokens::StrChar)
        root.add_rule Rule.new(/#\\./, Tokens::StrChar)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string)
        root.add_rule Rule.new(/[+-]?\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/[+-]?\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/#x[0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/#b[01]+/, Tokens::NumBin)
        root.add_rule Rule.new(/'/, Tokens::Operator)
        root.add_rule Rule.new(/`/, Tokens::Operator)
        root.add_rule Rule.new(/,@?/, Tokens::Operator)
        root.add_rule Rule.new(/[()]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z!$%&*\/:<=>?^_~][\w!$%&*+\-.\/:<=>\?@^~]*/, Tokens::Name)
        states[:root] = root

        mc = State.new(:multiline_comment)
        mc.add_rule Rule.new(/#\|/, Tokens::CommentMultiline, next_state: :multiline_comment)
        mc.add_rule Rule.new(/\|#/, Tokens::CommentMultiline, pop: true)
        mc.add_rule Rule.new(/[^#|]+/, Tokens::CommentMultiline)
        mc.add_rule Rule.new(/[#|]/, Tokens::CommentMultiline)
        states[:multiline_comment] = mc

        str = State.new(:string)
        str.add_rule Rule.new(/\\./, Tokens::StrEscape)
        str.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        str.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string] = str

        states
      end
    end

    RegexLexer.register("scheme", Scheme)
    RegexLexer.register("scm", Scheme)
  end
end
