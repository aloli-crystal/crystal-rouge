module Rouge
  module Lexers
    class CSharp < RegexLexer
      def self.tag_name : String
        "csharp"
      end

      def self.title_text : String
        "C#"
      end

      def self.desc_text : String
        "C# programming language"
      end

      def self.file_exts : Array(String)
        ["*.cs"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(abstract as base break case catch checked class const continue default delegate do else enum event explicit extern finally fixed for foreach goto if implicit in interface internal is lock namespace new operator out override params partial private protected public readonly ref return sealed sizeof stackalloc static struct switch this throw try typeof unchecked unsafe using var virtual volatile while yield async await dynamic nameof record init required global where when with)
        types = %w(bool byte char decimal double float int long object sbyte short string uint ulong ushort void)
        constants = %w(true false null)

        comment = State.new(:comment)
        comment.add_rule Rule.new(/[^\n]*/, Tokens::CommentSingle, pop: true)
        states[:comment] = comment

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
        root.add_rule Rule.new(/\/\//, Tokens::CommentSingle, next_state: :comment)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multi)
        root.add_rule Rule.new(/#\s*(?:if|else|elif|endif|region|endregion|pragma|define|undef|warning|error|line|nullable)\b[^\n]*/, Tokens::CommentPreproc)
        root.add_rule Rule.new(/@"(?:[^"]|"")*"/, Tokens::StrDouble)
        root.add_rule Rule.new(/\$"(?:[^"\\]|\\.)*"/, Tokens::StrDouble)
        root.add_rule Rule.new(/'(?:\\.|[^'\\])'/, Tokens::StrChar)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/(?:#{constants.join("|")})\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/(?:#{types.join("|")})\b/, Tokens::KeywordType)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/, Tokens::Keyword)
        root.add_rule Rule.new(/0[xX][0-9a-fA-F]+(?:u|l|ul|lu)?/i, Tokens::NumHex)
        root.add_rule Rule.new(/\d+\.\d*(?:[eE][+-]?\d+)?[fdm]?/i, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+(?:u|l|ul|lu)?/i, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_@]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/%&|^~<>=!?:]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("csharp", CSharp)
    RegexLexer.register("cs", CSharp)
    RegexLexer.register("c#", CSharp)
  end
end
