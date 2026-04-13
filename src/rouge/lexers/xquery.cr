module Rouge
  module Lexers
    class XQuery < RegexLexer
      def self.tag_name : String
        "xquery"
      end

      def self.title_text : String
        "XQuery"
      end

      def self.desc_text : String
        "XQuery query language"
      end

      def self.file_exts : Array(String)
        ["*.xq", "*.xql", "*.xqm", "*.xqy", "*.xquery"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)

        # Comments (: :)
        root.add_rule Rule.new(/\(:/, Tokens::CommentMultiline, next_state: :xq_comment)

        # Strings
        root.add_rule Rule.new(/"(?:[^"])*"/, Tokens::StrDouble)
        root.add_rule Rule.new(/'(?:[^'])*'/, Tokens::StrSingle)

        # Declaration keywords
        root.add_rule Rule.new(/\b(?:xquery|version|module|namespace|declare|import|at|as|schema-element|schema-attribute|function|variable|option|construction|ordering|empty|default|collation|base-uri|copy-namespaces|boundary-space)\b/, Tokens::KeywordDeclaration)

        # Flow keywords
        root.add_rule Rule.new(/\b(?:for|let|where|order|by|return|if|then|else|typeswitch|case|validate|some|every|satisfies|switch|try|catch)\b/, Tokens::Keyword)

        # Operators
        root.add_rule Rule.new(/\b(?:cast|castable|treat|instance|of|intersect|union|except|to|div|idiv|mod|and|or|eq|ne|lt|le|gt|ge|is)\b/, Tokens::OperatorWord)

        # Axes
        root.add_rule Rule.new(/\b(?:preceding|following|ancestor|descendant|self|child|parent|ascending|descending|stable|external)\b/, Tokens::KeywordPseudo)

        # Node types
        root.add_rule Rule.new(/\b(?:element|attribute|text|comment|node|document|processing-instruction)\b/, Tokens::KeywordType)

        # Constants
        root.add_rule Rule.new(/\b(?:true|false|empty-sequence)\b/, Tokens::KeywordConstant)

        # Variables
        root.add_rule Rule.new(/\$[a-zA-Z_][a-zA-Z0-9_-]*/, Tokens::NameVariable)

        # Numbers
        root.add_rule Rule.new(/\d+\.\d+(?:e[+-]?\d+)?/i, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        # XML tags
        root.add_rule Rule.new(/<\/[a-zA-Z_][a-zA-Z0-9_:-]*>/, Tokens::NameTag)
        root.add_rule Rule.new(/<[a-zA-Z_][a-zA-Z0-9_:-]*/, Tokens::NameTag)
        root.add_rule Rule.new(/\/?>/, Tokens::NameTag)

        # Path operators
        root.add_rule Rule.new(/\/\//, Tokens::Operator)
        root.add_rule Rule.new(/\//, Tokens::Operator)
        root.add_rule Rule.new(/@/, Tokens::Operator)
        root.add_rule Rule.new(/[=!<>+\-*|]+/, Tokens::Operator)

        # Punctuation
        root.add_rule Rule.new(/[{}\[\]();,.]/, Tokens::Punctuation)
        root.add_rule Rule.new(/::/, Tokens::Punctuation)

        # Function names
        root.add_rule Rule.new(/[a-zA-Z_][a-zA-Z0-9_-]*:[a-zA-Z_][a-zA-Z0-9_-]*/, Tokens::NameFunction)

        # Identifiers
        root.add_rule Rule.new(/[a-zA-Z_][a-zA-Z0-9_-]*/, Tokens::Name)

        root.add_rule Rule.new(/./, Tokens::Text)

        states[:root] = root

        xqc = State.new(:xq_comment)
        xqc.add_rule Rule.new(/:\)/, Tokens::CommentMultiline, pop: true)
        xqc.add_rule Rule.new(/[^:]+/, Tokens::CommentMultiline)
        xqc.add_rule Rule.new(/:/, Tokens::CommentMultiline)
        states[:xq_comment] = xqc

        states
      end
    end

    RegexLexer.register("xquery", XQuery)
  end
end
