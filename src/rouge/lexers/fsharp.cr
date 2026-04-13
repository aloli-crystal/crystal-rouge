module Rouge
  module Lexers
    class FSharp < RegexLexer
      def self.tag_name : String
        "fsharp"
      end

      def self.title_text : String
        "F#"
      end

      def self.desc_text : String
        "F# programming language"
      end

      def self.file_exts : Array(String)
        ["*.fs", "*.fsi", "*.fsx"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(abstract and as assert base begin class default delegate do done downcast downto elif else end exception extern finally for fun function global if in inherit inline interface internal lazy let match member module mutable namespace new not null of open or override private public rec return select static struct then to try type upcast use val void when while with yield)
        types = %w(bool byte char decimal double float int int16 int32 int64 nativeint sbyte single string uint16 uint32 uint64 unativeint unit)
        constants = %w(true false)

        comment = State.new(:comment)
        comment.add_rule Rule.new(/[^\n]*/, Tokens::CommentSingle, pop: true)
        states[:comment] = comment

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
        root.add_rule Rule.new(/\/\//, Tokens::CommentSingle, next_state: :comment)
        root.add_rule Rule.new(/\(\*/, Tokens::CommentMultiline, next_state: :comment_multi)
        root.add_rule Rule.new(/"""(?:[^"]|"(?!""))*"""/, Tokens::StrDoc)
        root.add_rule Rule.new(/@"(?:[^"]|"")*"/, Tokens::StrDouble)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'(?:\\.|[^'\\])'/, Tokens::StrChar)
        root.add_rule Rule.new(/(?:#{constants.join("|")})\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/(?:#{types.join("|")})\b/, Tokens::KeywordType)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})(?:!?)\b/, Tokens::Keyword)
        root.add_rule Rule.new(/\[<[^\]]*>\]/, Tokens::NameDecorator)
        root.add_rule Rule.new(/0[xX][0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/0[bB][01]+/, Tokens::NumBin)
        root.add_rule Rule.new(/\d+\.\d*(?:[eE][+-]?\d+)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/\|>|->|<-|>>|<<|::|[+\-*\/%&|^~<>=!?:@]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("fsharp", FSharp)
    RegexLexer.register("fs", FSharp)
  end
end
