module Rouge
  module Lexers
    class Lean < RegexLexer
      def self.tag_name : String
        "lean"
      end

      def self.title_text : String
        "Lean"
      end

      def self.desc_text : String
        "The Lean theorem prover and programming language (lean-lang.org)"
      end

      def self.file_exts : Array(String)
        ["*.lean"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        # :string_double
        sd = State.new(:string_double)
        sd.add_rule Rule.new(/\\./, Tokens::StrEscape)
        sd.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        sd.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        states[:string_double] = sd

        # :comment_multi
        cm = State.new(:comment_multi)
        cm.add_rule Rule.new(/-\//, Tokens::CommentMultiline, pop: true)
        cm.add_rule Rule.new(/[^-]+/, Tokens::CommentMultiline)
        cm.add_rule Rule.new(/-/, Tokens::CommentMultiline)
        states[:comment_multi] = cm

        # :root
        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/-/, Tokens::CommentMultiline, next_state: :comment_multi)
        root.add_rule Rule.new(/--[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'[^'\\]'/, Tokens::StrChar)
        root.add_rule Rule.new(/'\\.'/, Tokens::StrChar)

        root.add_rule Rule.new(/\b(?:true|false)\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\b(?:theorem|lemma|def|definition|structure|class|instance|where|extends|open|section|namespace|variable|universe|inductive|example|noncomputable|private|protected|partial|unsafe|mutual|axiom|constant|abbrev|set_option|attribute|macro|syntax|elab_rules|declare_syntax_cat|import|prelude|match|with|do|let|have|show|calc|by|fun|if|then|else|return|for|in|unless|while|try|catch|throw|deriving)\b/, Tokens::Keyword)

        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        root.add_rule Rule.new(/[+\-*\/%<>=!&|^~@#$?:]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,]+/, Tokens::Punctuation)
        root.add_rule Rule.new(/[A-Z]\w*/, Tokens::NameClass)
        root.add_rule Rule.new(/[a-z_]\w*/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("lean", Lean)
  end
end
