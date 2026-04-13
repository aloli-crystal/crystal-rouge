module Rouge
  module Lexers
    class JSL < RegexLexer
      def self.tag_name : String
        "jsl"
      end

      def self.title_text : String
        "JSL"
      end

      def self.desc_text : String
        "JMP Scripting Language"
      end

      def self.file_exts : Array(String)
        ["*.jsl"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(If Then Else For While Break Continue Return Function Try Catch Throw Local Include)
        builtins = %w(Show Print Write Eval Substitute Expr Match Contains StartsWith EndsWith Trim Concat Insert Remove)

        comment_multi = State.new(:comment_multi)
        comment_multi.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        comment_multi.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        comment_multi.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment_multi] = comment_multi

        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multi)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/Names Default To Here/, Tokens::Keyword)
        root.add_rule Rule.new(/New Window|New Table|New Column/, Tokens::NameBuiltin)
        root.add_rule Rule.new(/(?:#{builtins.join("|")})\b/, Tokens::NameBuiltin)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/, Tokens::Keyword)
        root.add_rule Rule.new(/\d+\.\d*(?:[eE][+-]?\d+)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/%&|^~<>=!:]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("jsl", JSL)
  end
end
