module Rouge
  module Lexers
    class Turtle < RegexLexer
      def self.tag_name : String
        "turtle"
      end

      def self.title_text : String
        "Turtle"
      end

      def self.desc_text : String
        "RDF Turtle serialization format"
      end

      def self.file_exts : Array(String)
        ["*.ttl"]
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
        root.add_rule Rule.new(/#[^\n]*/, Tokens::CommentSingle)

        # Directives
        root.add_rule Rule.new(/@(?:prefix|base)\b/, Tokens::KeywordNamespace)

        # Boolean constants
        root.add_rule Rule.new(/\b(?:true|false)\b/, Tokens::KeywordConstant)

        # 'a' keyword (rdf:type)
        root.add_rule Rule.new(/\ba\b/, Tokens::Keyword)

        # URIs
        root.add_rule Rule.new(/<[^>]*>/, Tokens::NameLabel)

        # Triple-quoted strings
        root.add_rule Rule.new(/"""/, Tokens::StrDouble, next_state: :triple_string)

        # Strings with optional language tag or datatype
        root.add_rule Rule.new(/"(?:\\.|[^"\\])*"/, Tokens::StrDouble)

        # Language tags
        root.add_rule Rule.new(/@[a-zA-Z]+(?:-[a-zA-Z0-9]+)*/, Tokens::NameAttribute)

        # Datatype
        root.add_rule Rule.new(/\^\^/, Tokens::Operator)

        # Blank nodes
        root.add_rule Rule.new(/_:[a-zA-Z_][a-zA-Z0-9_.-]*/, Tokens::NameVariable)

        # Prefixed names
        root.add_rule Rule.new(/[a-zA-Z_][a-zA-Z0-9_.-]*:[a-zA-Z_][a-zA-Z0-9_.-]*/, Tokens::NameTag)

        # Prefix declarations
        root.add_rule Rule.new(/[a-zA-Z_][a-zA-Z0-9_.-]*:/, Tokens::NameNamespace)

        # Numbers
        root.add_rule Rule.new(/[+-]?\d+\.\d+(?:e[+-]?\d+)?/i, Tokens::NumFloat)
        root.add_rule Rule.new(/[+-]?\d+/, Tokens::NumInteger)

        # Punctuation
        root.add_rule Rule.new(/[;\[\](),.]/, Tokens::Punctuation)

        # Identifiers
        root.add_rule Rule.new(/[a-zA-Z_][a-zA-Z0-9_.-]*/, Tokens::Name)

        root.add_rule Rule.new(/./, Tokens::Text)

        states[:root] = root

        ts = State.new(:triple_string)
        ts.add_rule Rule.new(/"""/, Tokens::StrDouble, pop: true)
        ts.add_rule Rule.new(/[^"]+/, Tokens::StrDouble)
        ts.add_rule Rule.new(/"/, Tokens::StrDouble)
        states[:triple_string] = ts

        states
      end
    end

    RegexLexer.register("turtle", Turtle)
    RegexLexer.register("ttl", Turtle)
  end
end
