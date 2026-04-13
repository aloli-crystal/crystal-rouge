module Rouge
  module Lexers
    class Diff < RegexLexer
      def self.tag_name : String
        "diff"
      end

      def self.title_text : String
        "Diff"
      end

      def self.desc_text : String
        "Unified diff/patch format"
      end

      def self.file_exts : Array(String)
        ["*.diff", "*.patch"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        # :root
        root = State.new(:root)

        # Index and git metadata lines
        root.add_rule Rule.new(/index [0-9a-f]+\.\.[0-9a-f]+[^\n]*/, Tokens::GenericHeading)
        root.add_rule Rule.new(/diff --git [^\n]*/, Tokens::GenericHeading)

        # File headers (--- and +++ lines)
        root.add_rule Rule.new(/--- [^\n]*/, Tokens::GenericDeleted)
        root.add_rule Rule.new(/\+\+\+ [^\n]*/, Tokens::GenericInserted)

        # Hunk headers
        root.add_rule Rule.new(/@@\s[^\n]*?@@[^\n]*/, Tokens::GenericSubheading)

        # Added lines
        root.add_rule Rule.new(/\+[^\n]*/, Tokens::GenericInserted)

        # Removed lines
        root.add_rule Rule.new(/-[^\n]*/, Tokens::GenericDeleted)

        # "No newline at end of file" message
        root.add_rule Rule.new(/\\ [^\n]*/, Tokens::Comment)

        # Context lines (unchanged, starting with space)
        root.add_rule Rule.new(/ [^\n]*/, Tokens::Text)

        # Whitespace (newlines)
        root.add_rule Rule.new(/\n/, Tokens::TextWhitespace)

        # Anything else
        root.add_rule Rule.new(/[^\n]+/, Tokens::Text)

        states[:root] = root

        states
      end
    end

    RegexLexer.register("diff", Diff)
    RegexLexer.register("patch", Diff)
  end
end
