module Rouge
  module Lexers
    class Smalltalk < RegexLexer
      def self.tag_name : String
        "smalltalk"
      end

      def self.title_text : String
        "Smalltalk"
      end

      def self.desc_text : String
        "The Smalltalk programming language"
      end

      def self.file_exts : Array(String)
        ["*.st"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        # :comment
        c = State.new(:comment)
        c.add_rule Rule.new(/[^"]+/, Tokens::Comment)
        c.add_rule Rule.new(/"/, Tokens::Comment, pop: true)
        states[:comment] = c

        # :string_single
        ss = State.new(:string_single)
        ss.add_rule Rule.new(/''/, Tokens::StrEscape)
        ss.add_rule Rule.new(/[^']+/, Tokens::StrSingle)
        ss.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        states[:string_single] = ss

        # :root
        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/"/, Tokens::Comment, next_state: :comment)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)

        # Symbols
        root.add_rule Rule.new(/#'[^']*'/, Tokens::StrSymbol)
        root.add_rule Rule.new(/#[a-zA-Z_]\w*(?::[a-zA-Z_]\w*)*:?/, Tokens::StrSymbol)

        # Characters
        root.add_rule Rule.new(/\$./, Tokens::StrChar)

        root.add_rule Rule.new(/\b(?:self|super|true|false|nil|thisContext)\b/, Tokens::KeywordConstant)

        # Assignment
        root.add_rule Rule.new(/:=/, Tokens::Operator)

        # Numbers (radix)
        root.add_rule Rule.new(/\d+r[0-9a-zA-Z]+/, Tokens::NumHex)
        root.add_rule Rule.new(/\d+\.\d+(?:e[+-]?\d+)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        # Block args
        root.add_rule Rule.new(/:[a-zA-Z_]\w*/, Tokens::NameVariable)

        # Cascade and other operators
        root.add_rule Rule.new(/[+\-*\/%<>=~&|@,!?\\]+/, Tokens::Operator)
        root.add_rule Rule.new(/;/, Tokens::Punctuation)
        root.add_rule Rule.new(/[{}()\[\]\.^]+/, Tokens::Punctuation)

        # Keyword messages (word followed by colon, not :=)
        root.add_rule Rule.new(/[a-zA-Z_]\w*:(?!=)/, Tokens::NameFunction)

        # Identifiers
        root.add_rule Rule.new(/[A-Z]\w*/, Tokens::NameClass)
        root.add_rule Rule.new(/[a-z_]\w*/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("smalltalk", Smalltalk)
    RegexLexer.register("st", Smalltalk)
  end
end
