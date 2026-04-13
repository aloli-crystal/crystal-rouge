module Rouge
  module Lexers
    class J < RegexLexer
      def self.tag_name : String
        "j"
      end

      def self.title_text : String
        "J"
      end

      def self.desc_text : String
        "The J programming language (jsoftware.com)"
      end

      def self.file_exts : Array(String)
        ["*.ijs", "*.ijt"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        # :string_single
        ss = State.new(:string_single)
        ss.add_rule Rule.new(/''/, Tokens::StrEscape)
        ss.add_rule Rule.new(/[^']+/, Tokens::StrSingle)
        ss.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        states[:string_single] = ss

        # :root
        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/NB\.[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)
        root.add_rule Rule.new(/_?\d+\.?\d*(?:e[+-]?\d+)?(?:j_?\d+\.?\d*(?:e[+-]?\d+)?)?/i, Tokens::Num)
        root.add_rule Rule.new(/\b(?:if|do|else|elseif|end|for|select|case|fcase|while|whilst|try|catch|catchd|catcht|throw|return|assert|break|continue|goto|label)\b\./, Tokens::Keyword)
        root.add_rule Rule.new(/\b(?:define|noun|verb|adverb|conjunction|monad|dyad)\b/, Tokens::KeywordDeclaration)
        # Verbs (primitives)
        root.add_rule Rule.new(/[=<>_+*\-!%^$~|][\.:]*/, Tokens::Operator)
        root.add_rule Rule.new(/[{}\[\/\\#,;][\.:]*/, Tokens::Operator)
        root.add_rule Rule.new(/[()]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z]\w*/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("j", J)
  end
end
