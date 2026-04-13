module Rouge
  module Lexers
    class Coq < RegexLexer
      def self.tag_name : String
        "coq"
      end

      def self.title_text : String
        "Coq"
      end

      def self.desc_text : String
        "Coq proof assistant"
      end

      def self.file_exts : Array(String)
        ["*.v"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(Axiom CoFixpoint CoInductive Definition Example Fixpoint Function Hypothesis Inductive Lemma Ltac Parameter Proof Qed Record Section Structure Theorem Type Variable as at cofix else end exists fix for forall fun if in let match return then with Require Import Export Open Scope Notation Set Unset Compute Eval Check Print Admitted)
        constants = %w(True False)

        comment_multi = State.new(:comment_multi)
        comment_multi.add_rule Rule.new(/\(\*/, Tokens::CommentMultiline, next_state: :comment_multi)
        comment_multi.add_rule Rule.new(/\*\)/, Tokens::CommentMultiline, pop: true)
        comment_multi.add_rule Rule.new(/[^(*]+/, Tokens::CommentMultiline)
        comment_multi.add_rule Rule.new(/[(*]/, Tokens::CommentMultiline)
        states[:comment_multi] = comment_multi

        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/""/, Tokens::StrEscape)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\(\*/, Tokens::CommentMultiline, next_state: :comment_multi)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/(?:#{constants.join("|")})\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/, Tokens::Keyword)
        root.add_rule Rule.new(/\d+\.\d*/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/<>=:!|&~^]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("coq", Coq)
  end
end
