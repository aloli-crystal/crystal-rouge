module Rouge
  module Lexers
    class Twig < RegexLexer
      def self.tag_name : String
        "twig"
      end

      def self.title_text : String
        "Twig"
      end

      def self.desc_text : String
        "Twig template engine for PHP"
      end

      def self.file_exts : Array(String)
        ["*.twig"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        # Expression state (inside {{ }})
        expr = State.new(:expr)
        expr.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        expr.add_rule Rule.new(/\}\}/, Tokens::CommentPreproc, pop: true)
        expr.add_rule Rule.new(/"(?:\\.|[^"\\])*"/, Tokens::StrDouble)
        expr.add_rule Rule.new(/'(?:\\.|[^'\\])*'/, Tokens::StrSingle)
        expr.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        expr.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        expr.add_rule Rule.new(/\b(?:true|false|none|null)\b/, Tokens::KeywordConstant)
        expr.add_rule Rule.new(/\b(?:and|or|not|in|is|as|b-and|b-or|b-xor)\b/, Tokens::OperatorWord)
        expr.add_rule Rule.new(/\|/, Tokens::Operator)
        expr.add_rule Rule.new(/[+\-*\/%=!<>&^~?:]+/, Tokens::Operator)
        expr.add_rule Rule.new(/[(),.\[\]]/, Tokens::Punctuation)
        expr.add_rule Rule.new(/[a-zA-Z_][a-zA-Z0-9_]*/, Tokens::Name)
        expr.add_rule Rule.new(/./, Tokens::Text)
        states[:expr] = expr

        # Tag state (inside {% %})
        tag = State.new(:tag)
        tag.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        tag.add_rule Rule.new(/-?%\}/, Tokens::CommentPreproc, pop: true)
        tag.add_rule Rule.new(/"(?:\\.|[^"\\])*"/, Tokens::StrDouble)
        tag.add_rule Rule.new(/'(?:\\.|[^'\\])*'/, Tokens::StrSingle)
        tag.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        tag.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        tag.add_rule Rule.new(/\b(?:true|false|none|null)\b/, Tokens::KeywordConstant)
        tag.add_rule Rule.new(/\b(?:block|endblock|for|endfor|if|elif|else|endif|macro|endmacro|set|extends|include|import|from|as|with|filter|endfilter|embed|endembed|autoescape|endautoescape|do|flush|sandbox|endsandbox|verbatim|endverbatim|apply|endapply|deprecated|spaceless|endspaceless)\b/, Tokens::Keyword)
        tag.add_rule Rule.new(/\b(?:and|or|not|in|is)\b/, Tokens::OperatorWord)
        tag.add_rule Rule.new(/[+\-*\/%=!<>&|^~?:]+/, Tokens::Operator)
        tag.add_rule Rule.new(/[(),.\[\]]/, Tokens::Punctuation)
        tag.add_rule Rule.new(/[a-zA-Z_][a-zA-Z0-9_]*/, Tokens::Name)
        tag.add_rule Rule.new(/./, Tokens::Text)
        states[:tag] = tag

        root = State.new(:root)

        # Comment tags
        root.add_rule Rule.new(/\{#/, Tokens::CommentMultiline, next_state: :twig_comment)

        # Expression tags
        root.add_rule Rule.new(/\{\{-?/, Tokens::CommentPreproc, next_state: :expr)

        # Block tags
        root.add_rule Rule.new(/\{%-?/, Tokens::CommentPreproc, next_state: :tag)

        # Plain text
        root.add_rule Rule.new(/[^{]+/, Tokens::Text)
        root.add_rule Rule.new(/\{/, Tokens::Text)

        states[:root] = root

        tc = State.new(:twig_comment)
        tc.add_rule Rule.new(/#\}/, Tokens::CommentMultiline, pop: true)
        tc.add_rule Rule.new(/[^#]+/, Tokens::CommentMultiline)
        tc.add_rule Rule.new(/#/, Tokens::CommentMultiline)
        states[:twig_comment] = tc

        states
      end
    end

    RegexLexer.register("twig", Twig)
  end
end
