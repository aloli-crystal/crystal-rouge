module Rouge
  module Lexers
    class Erlang < RegexLexer
      def self.tag_name : String
        "erlang"
      end

      def self.title_text : String
        "Erlang"
      end

      def self.desc_text : String
        "Erlang programming language"
      end

      def self.file_exts : Array(String)
        ["*.erl", "*.hrl"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(after begin case catch cond end fun if let of query receive try when)
        constants = %w(true false undefined)

        comment = State.new(:comment)
        comment.add_rule Rule.new(/[^\n]*/, Tokens::CommentSingle, pop: true)
        states[:comment] = comment

        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        atom_quoted = State.new(:atom_quoted)
        atom_quoted.add_rule Rule.new(/\\./, Tokens::StrEscape)
        atom_quoted.add_rule Rule.new(/'/, Tokens::StrSymbol, pop: true)
        atom_quoted.add_rule Rule.new(/[^'\\]+/, Tokens::StrSymbol)
        states[:atom_quoted] = atom_quoted

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/%/, Tokens::CommentSingle, next_state: :comment)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'/, Tokens::StrSymbol, next_state: :atom_quoted)
        root.add_rule Rule.new(/\$(?:\\.|.)/, Tokens::StrChar)
        root.add_rule Rule.new(/(?:#{constants.join("|")})\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/, Tokens::Keyword)
        root.add_rule Rule.new(/-(?:module|export|import|compile|define|include|include_lib|ifdef|ifndef|else|endif|undef|record|type|spec|callback|behaviour|behavior|opaque)\b/, Tokens::NameDecorator)
        root.add_rule Rule.new(/[A-Z_]\w*/, Tokens::NameVariable)
        root.add_rule Rule.new(/[a-z]\w*/, Tokens::Name)
        root.add_rule Rule.new(/\d+\.\d+(?:[eE][+-]?\d+)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+#[0-9a-fA-F]+/, Tokens::NumInteger)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/->|;|,|\.|!|\||\|\||[+\-*\/<>=:]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\]?#]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("erlang", Erlang)
    RegexLexer.register("erl", Erlang)
  end
end
