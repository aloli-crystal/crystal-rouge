module Rouge
  module Lexers
    class Dylan < RegexLexer
      def self.tag_name : String
        "dylan"
      end

      def self.title_text : String
        "Dylan"
      end

      def self.desc_text : String
        "Dylan programming language"
      end

      def self.file_exts : Array(String)
        ["*.dylan", "*.dyl"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(above abstract afterwards begin below block by case class cleanup constant create define domain else elseif end exception export finally for from generic handler if in inherited instance let library local method module open otherwise rename required seal select signal slot subclass then to unless until use variable virtual when while)

        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_block)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'[^'\\]'/, Tokens::StrChar)
        root.add_rule Rule.new(/'\\.'/, Tokens::StrChar)
        root.add_rule Rule.new(/#"[^"]*"/, Tokens::StrSymbol)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/i, Tokens::Keyword)
        root.add_rule Rule.new(/(?:#t|#f|#next|#rest|#key|#all-keys)\b/i, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\d+\.\d*/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_][\w\-]*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/<>=!&|^~?:]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        states[:root] = root

        comment_block = State.new(:comment_block)
        comment_block.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        comment_block.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        comment_block.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment_block] = comment_block

        states
      end
    end

    RegexLexer.register("dylan", Dylan)
  end
end
