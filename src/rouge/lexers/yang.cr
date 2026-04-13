module Rouge
  module Lexers
    class Yang < RegexLexer
      def self.tag_name : String
        "yang"
      end

      def self.title_text : String
        "YANG"
      end

      def self.desc_text : String
        "YANG data modeling language"
      end

      def self.file_exts : Array(String)
        ["*.yang"]
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
        root.add_rule Rule.new(/'[^']*'/, Tokens::StrSingle)

        # Keywords
        root.add_rule Rule.new(/\b(?:module|submodule|belongs-to|namespace|prefix|import|include|revision|organization|contact|description|reference|container|leaf|leaf-list|list|choice|anydata|anyxml|uses|grouping|augment|deviation|notification|rpc|action|input|output|typedef|type|range|length|pattern|enum|bit|path|require-instance|fraction-digits|base|error-message|error-app-tag|status|config|mandatory|presence|ordered-by|must|when|key|unique|refine|min-elements|max-elements|value|default|units|if-feature|feature|identity|extension|argument|yin-element)\b/, Tokens::Keyword)

        # Constants
        root.add_rule Rule.new(/\b(?:true|false|current|obsolete|deprecated)\b/, Tokens::KeywordConstant)

        # Numbers
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        # Operators
        root.add_rule Rule.new(/[+\-*\/=<>!&|]+/, Tokens::Operator)
        root.add_rule Rule.new(/\.\./, Tokens::Operator)

        # Punctuation
        root.add_rule Rule.new(/[{}\[\]();,]/, Tokens::Punctuation)

        # Identifiers
        root.add_rule Rule.new(/[a-zA-Z_][a-zA-Z0-9_.-]*/, Tokens::Name)

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

    RegexLexer.register("yang", Yang)
  end
end
