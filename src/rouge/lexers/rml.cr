module Rouge
  module Lexers
    class RML < RegexLexer
      def self.tag_name : String
        "rml"
      end

      def self.title_text : String
        "RML"
      end

      def self.desc_text : String
        "RML (RISC OS Markup Language)"
      end

      def self.file_exts : Array(String)
        ["*.rml"]
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

        # Strings
        root.add_rule Rule.new(/"[^"]*"/, Tokens::StrDouble)
        root.add_rule Rule.new(/'[^']*'/, Tokens::StrSingle)

        # Numbers
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        # Tags/keywords
        root.add_rule Rule.new(/<\/?[a-zA-Z_][a-zA-Z0-9_]*>?/, Tokens::NameTag)

        # Operators
        root.add_rule Rule.new(/[=<>!]+/, Tokens::Operator)

        # Punctuation
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)

        # Identifiers
        root.add_rule Rule.new(/[a-zA-Z_][a-zA-Z0-9_]*/, Tokens::Name)

        root.add_rule Rule.new(/./, Tokens::Text)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("rml", RML)
  end
end
