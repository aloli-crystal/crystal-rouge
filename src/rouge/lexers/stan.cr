module Rouge
  module Lexers
    class Stan < RegexLexer
      def self.tag_name : String
        "stan"
      end

      def self.title_text : String
        "Stan"
      end

      def self.desc_text : String
        "Stan statistical modeling language"
      end

      def self.file_exts : Array(String)
        ["*.stan"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)

        # Comments
        root.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :multiline_comment)

        # Strings
        root.add_rule Rule.new(/"(?:\\.|[^"\\])*"/, Tokens::StrDouble)

        # Block declarations
        root.add_rule Rule.new(/\b(?:data|transformed\s+data|parameters|transformed\s+parameters|model|generated\s+quantities|functions)\b/, Tokens::KeywordNamespace)

        # Keywords
        root.add_rule Rule.new(/\b(?:for|in|while|if|else|return|break|continue|print|reject|target|increment_log_prob|integrate_ode|integrate_ode_rk45|algebra_solver)\b/, Tokens::Keyword)

        # Types
        root.add_rule Rule.new(/\b(?:int|real|vector|row_vector|matrix|ordered|positive_ordered|simplex|unit_vector|cholesky_factor_corr|cholesky_factor_cov|corr_matrix|cov_matrix|void|array)\b/, Tokens::KeywordType)

        # Numbers
        root.add_rule Rule.new(/\d+\.\d+(?:e[+-]?\d+)?/i, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        # Operators
        root.add_rule Rule.new(/[+\-*\/%=!<>&|^~?:]+/, Tokens::Operator)
        root.add_rule Rule.new(/~/, Tokens::Operator)

        # Punctuation
        root.add_rule Rule.new(/[{}\[\]();,]/, Tokens::Punctuation)

        # Identifiers
        root.add_rule Rule.new(/[a-zA-Z_][a-zA-Z0-9_]*/, Tokens::Name)

        root.add_rule Rule.new(/./, Tokens::Text)

        states[:root] = root

        mc = State.new(:multiline_comment)
        mc.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        mc.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        mc.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:multiline_comment] = mc

        states
      end
    end

    RegexLexer.register("stan", Stan)
  end
end
