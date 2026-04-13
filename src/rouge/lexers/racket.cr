module Rouge
  module Lexers
    class Racket < RegexLexer
      def self.tag_name : String
        "racket"
      end

      def self.title_text : String
        "Racket"
      end

      def self.desc_text : String
        "Racket programming language"
      end

      def self.file_exts : Array(String)
        ["*.rkt"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(
          #lang define let let\\* letrec lambda if cond case when unless begin
          for for/list for/fold struct class interface provide require module
          match syntax-parse define-syntax
        )

        kw_pattern = keywords.join("|")

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/#\|/, Tokens::CommentMultiline, next_state: :multiline_comment)
        root.add_rule Rule.new(/;.*/, Tokens::CommentSingle)
        root.add_rule Rule.new(Regex.new("(?:#{kw_pattern})\\b"), Tokens::Keyword)
        root.add_rule Rule.new(/#(?:true|false|t|f)\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/#\\[a-zA-Z]+\b/, Tokens::StrChar)
        root.add_rule Rule.new(/#\\./, Tokens::StrChar)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string)
        root.add_rule Rule.new(/[+-]?\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/[+-]?\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/#x[0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/'/, Tokens::Operator)
        root.add_rule Rule.new(/`/, Tokens::Operator)
        root.add_rule Rule.new(/,@?/, Tokens::Operator)
        root.add_rule Rule.new(/[()]/, Tokens::Punctuation)
        root.add_rule Rule.new(/\[/, Tokens::Punctuation)
        root.add_rule Rule.new(/\]/, Tokens::Punctuation)
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

    RegexLexer.register("racket", Racket)
    RegexLexer.register("rkt", Racket)
  end
end
