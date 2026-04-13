module Rouge
  module Lexers
    class SuperCollider < RegexLexer
      def self.tag_name : String
        "supercollider"
      end

      def self.title_text : String
        "SuperCollider"
      end

      def self.desc_text : String
        "SuperCollider audio programming language"
      end

      def self.file_exts : Array(String)
        ["*.sc", "*.scd"]
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

        # Symbols
        root.add_rule Rule.new(/'[a-zA-Z_][a-zA-Z0-9_]*'/, Tokens::StrSymbol)
        root.add_rule Rule.new(/\\[a-zA-Z_][a-zA-Z0-9_]*/, Tokens::StrSymbol)

        # Characters
        root.add_rule Rule.new(/\$\\./, Tokens::StrChar)
        root.add_rule Rule.new(/\$./, Tokens::StrChar)

        # Keywords
        root.add_rule Rule.new(/\b(?:var|arg|classvar|const|this|super|if|while|for|forBy|do|collect|select|reject|detect|case|switch|loop|protect|try|catch)\b/, Tokens::Keyword)

        # Constants
        root.add_rule Rule.new(/\b(?:true|false|nil|inf)\b/, Tokens::KeywordConstant)

        # Class names (start with uppercase)
        root.add_rule Rule.new(/\b[A-Z][a-zA-Z0-9_]*\b/, Tokens::NameClass)

        # Numbers
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/0x[0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        # Operators
        root.add_rule Rule.new(/[+\-*\/%=!<>&|@^~]+/, Tokens::Operator)

        # Punctuation
        root.add_rule Rule.new(/[{}\[\]();,.]/, Tokens::Punctuation)

        # Identifiers
        root.add_rule Rule.new(/[a-z_][a-zA-Z0-9_]*/, Tokens::Name)

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

    RegexLexer.register("supercollider", SuperCollider)
    RegexLexer.register("sc", SuperCollider)
  end
end
