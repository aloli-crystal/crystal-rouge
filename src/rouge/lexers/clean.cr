module Rouge
  module Lexers
    class Clean < RegexLexer
      def self.tag_name : String
        "clean"
      end

      def self.title_text : String
        "Clean"
      end

      def self.desc_text : String
        "Clean programming language"
      end

      def self.file_exts : Array(String)
        ["*.icl", "*.dcl"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(module import from definition implementation system class instance where let in if case of otherwise with infix infixl infixr special dynamic code inline derive generic)
        types = %w(Start Bool Char Int Real String True False Nothing)

        comment_block = State.new(:comment_block)
        comment_block.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        comment_block.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        comment_block.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment_block] = comment_block

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
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/, Tokens::Keyword)
        root.add_rule Rule.new(/(?:#{types.join("|")})\b/, Tokens::KeywordType)
        root.add_rule Rule.new(/\d+\.\d*/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[A-Z]\w*/, Tokens::NameClass)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/%=<>!&|^~?:#@\\]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("clean", Clean)
  end
end
