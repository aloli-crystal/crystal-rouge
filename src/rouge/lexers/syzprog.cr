module Rouge
  module Lexers
    class Syzprog < RegexLexer
      def self.tag_name : String
        "syzprog"
      end

      def self.title_text : String
        "Syzprog"
      end

      def self.desc_text : String
        "Syzkaller prog format"
      end

      def self.file_exts : Array(String)
        [] of String
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

        # Return value assignment
        root.add_rule Rule.new(
          /([a-zA-Z_][a-zA-Z0-9_\$]*)(\()/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::NameFunction, m[1]},
              {Tokens::Punctuation, m[2]},
            ] of TokenPair
          }
        )

        # Result variable r0, r1, etc.
        root.add_rule Rule.new(/r\d+/, Tokens::NameVariable)

        # Hex numbers
        root.add_rule Rule.new(/0x[0-9a-fA-F]+/, Tokens::NumHex)

        # Numbers
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        # Strings
        root.add_rule Rule.new(/"(?:\\.|[^"\\])*"/, Tokens::StrDouble)

        # Operators
        root.add_rule Rule.new(/=/, Tokens::Operator)

        # Punctuation
        root.add_rule Rule.new(/[(),\[\]{}]/, Tokens::Punctuation)

        # Identifiers
        root.add_rule Rule.new(/[a-zA-Z_][a-zA-Z0-9_\$]*/, Tokens::Name)

        root.add_rule Rule.new(/./, Tokens::Text)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("syzprog", Syzprog)
  end
end
