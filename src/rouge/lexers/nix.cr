module Rouge
  module Lexers
    class Nix < RegexLexer
      def self.tag_name : String
        "nix"
      end

      def self.title_text : String
        "Nix"
      end

      def self.desc_text : String
        "Nix expression language"
      end

      def self.file_exts : Array(String)
        ["*.nix"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(assert builtins else if import in inherit let or rec then with)
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
        string_double.add_rule Rule.new(/\$\{[^}]*\}/, Tokens::StrInterpol)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\$]+/, Tokens::StrDouble)
        string_double.add_rule Rule.new(/\$/, Tokens::StrDouble)
        states[:string_double] = string_double

        string_indent = State.new(:string_indent)
        string_indent.add_rule Rule.new(/''(?:''|\\.)/, Tokens::StrEscape)
        string_indent.add_rule Rule.new(/\$\{[^}]*\}/, Tokens::StrInterpol)
        string_indent.add_rule Rule.new(/''/, Tokens::StrSingle, pop: true)
        string_indent.add_rule Rule.new(/[^'$]+/, Tokens::StrSingle)
        string_indent.add_rule Rule.new(/['$]/, Tokens::StrSingle)
        states[:string_indent] = string_indent

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/#/, Tokens::CommentSingle, next_state: :comment)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multi)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/''/, Tokens::StrSingle, next_state: :string_indent)
        root.add_rule Rule.new(/<[a-zA-Z][a-zA-Z0-9._\/-]*>/, Tokens::StrOther)
        root.add_rule Rule.new(/(?:\.\/|\/)[a-zA-Z0-9._\/-]+/, Tokens::StrOther)
        root.add_rule Rule.new(/(?:#{constants.join("|")})\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/, Tokens::Keyword)
        root.add_rule Rule.new(/\d+\.\d*/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_][a-zA-Z0-9_'-]*/, Tokens::Name)
        root.add_rule Rule.new(/\/\/|->|[+\-*\/<>=!?@:]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("nix", Nix)
  end
end
