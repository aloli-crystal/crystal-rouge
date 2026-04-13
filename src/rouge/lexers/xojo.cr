module Rouge
  module Lexers
    class Xojo < RegexLexer
      def self.tag_name : String
        "xojo"
      end

      def self.title_text : String
        "Xojo"
      end

      def self.desc_text : String
        "Xojo (REALbasic) programming language"
      end

      def self.file_exts : Array(String)
        ["*.xojo_code"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)

        # Comments (// and ' and REM, case insensitive)
        root.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/'[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\bREM\b[^\n]*/i, Tokens::CommentSingle)

        # Strings
        root.add_rule Rule.new(/"(?:[^"]|"")*"/, Tokens::StrDouble)

        # Keywords (case insensitive)
        root.add_rule Rule.new(/\b(?:As|Boolean|ByRef|ByVal|Call|Case|Catch|Class|Const|Continue|Dim|Do|Double|Each|Else|ElseIf|End|Enum|Event|Exception|Exit|Extends|Finally|For|Function|GoTo|Handles|If|Implements|In|Integer|Interface|Is|IsA|Let|Loop|Me|Module|Namespace|New|Next|Nil|Not|Object|Of|Optional|Or|ParamArray|Private|Property|Protected|Public|Raise|RaiseEvent|Redim|RemoveHandler|Return|Select|Self|Set|Shared|Single|Soft|Static|Step|String|Structure|Sub|Super|Then|To|Try|Until|Using|Var|Wend|While|With|Xor)\b/i, Tokens::Keyword)

        # Constants
        root.add_rule Rule.new(/\b(?:True|False|Nil)\b/i, Tokens::KeywordConstant)

        # Numbers
        root.add_rule Rule.new(/&h[0-9a-fA-F]+/i, Tokens::NumHex)
        root.add_rule Rule.new(/&o[0-7]+/i, Tokens::NumOct)
        root.add_rule Rule.new(/&b[01]+/i, Tokens::NumBin)
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        # Operators
        root.add_rule Rule.new(/[+\-*\/%=<>&\\^]+/, Tokens::Operator)

        # Punctuation
        root.add_rule Rule.new(/[{}\[\]();,.]/, Tokens::Punctuation)

        # Identifiers
        root.add_rule Rule.new(/[a-zA-Z_][a-zA-Z0-9_]*/, Tokens::Name)

        root.add_rule Rule.new(/./, Tokens::Text)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("xojo", Xojo)
  end
end
