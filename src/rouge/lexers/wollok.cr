module Rouge
  module Lexers
    class Wollok < RegexLexer
      def self.tag_name : String
        "wollok"
      end

      def self.title_text : String
        "Wollok"
      end

      def self.desc_text : String
        "Wollok educational programming language"
      end

      def self.file_exts : Array(String)
        ["*.wlk", "*.wtest", "*.wpgm"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(
          class inherits object mixin program test package import method override
          var const self super return if else throw try catch then always new not
          and or constructor
        )

        constants = %w(null true false)

        kw_pattern = keywords.join("|")
        const_pattern = constants.join("|")

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/\/.*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :multiline_comment)
        root.add_rule Rule.new(Regex.new("\\b(?:#{kw_pattern})\\b"), Tokens::Keyword)
        root.add_rule Rule.new(Regex.new("\\b(?:#{const_pattern})\\b"), Tokens::KeywordConstant)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string)
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[=!<>]+|&&|\|\||\+|-|\*|\//, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        states[:root] = root

        mc = State.new(:multiline_comment)
        mc.add_rule Rule.new(/[^*\/]+/, Tokens::CommentMultiline)
        mc.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        mc.add_rule Rule.new(/[*\/]/, Tokens::CommentMultiline)
        states[:multiline_comment] = mc

        str = State.new(:string)
        str.add_rule Rule.new(/\\./, Tokens::StrEscape)
        str.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        str.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string] = str

        states
      end
    end

    RegexLexer.register("wollok", Wollok)
  end
end
