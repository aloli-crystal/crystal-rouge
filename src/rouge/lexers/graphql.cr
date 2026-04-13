module Rouge
  module Lexers
    class GraphQL < RegexLexer
      def self.tag_name : String
        "graphql"
      end

      def self.title_text : String
        "GraphQL"
      end

      def self.desc_text : String
        "GraphQL query language"
      end

      def self.file_exts : Array(String)
        ["*.graphql", "*.gql"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        # :comment
        comment = State.new(:comment)
        comment.add_rule Rule.new(/#[^\n]*/, Tokens::CommentSingle)
        states[:comment] = comment

        # :whitespace
        ws = State.new(:whitespace)
        ws.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        states[:whitespace] = ws

        # :string_block
        string_block = State.new(:string_block)
        string_block.add_rule Rule.new(/"""/, Tokens::StrDoc, pop: true)
        string_block.add_rule Rule.new(/[^"]+/, Tokens::StrDoc)
        string_block.add_rule Rule.new(/"/, Tokens::StrDoc)
        states[:string_block] = string_block

        # :string_double
        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        # :root
        root = State.new(:root)
        root.add_mixin :whitespace
        root.add_mixin :comment
        # Block strings must come before regular strings
        root.add_rule Rule.new(/"""/, Tokens::StrDoc, next_state: :string_block)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        # Keywords
        root.add_rule Rule.new(/\b(?:query|mutation|subscription|fragment|on|type|interface|union|enum|input|extend|schema|directive|scalar|implements|repeatable)\b/, Tokens::Keyword)
        # Built-in types
        root.add_rule Rule.new(/\b(?:Int|Float|String|Boolean|ID)\b/, Tokens::KeywordType)
        # Constants
        root.add_rule Rule.new(/\b(?:true|false|null)\b/, Tokens::KeywordConstant)
        # Variables
        root.add_rule Rule.new(/\$[a-zA-Z_]\w*/, Tokens::NameVariable)
        # Directives
        root.add_rule Rule.new(/@[a-zA-Z_]\w*/, Tokens::NameDecorator)
        # Numbers
        root.add_rule Rule.new(/-?(?:\d+\.\d+(?:[eE][+-]?\d+)?)\b/, Tokens::NumFloat)
        root.add_rule Rule.new(/-?\d+\b/, Tokens::NumInteger)
        # Spread operator
        root.add_rule Rule.new(/\.\.\./, Tokens::Punctuation)
        # Operators
        root.add_rule Rule.new(/[!=:@&|]/, Tokens::Operator)
        # Punctuation
        root.add_rule Rule.new(/[{}()\[\]]/, Tokens::Punctuation)
        # Identifiers
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("graphql", GraphQL)
  end
end
