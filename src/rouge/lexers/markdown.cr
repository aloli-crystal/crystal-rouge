module Rouge
  module Lexers
    class Markdown < RegexLexer
      def self.tag_name : String
        "markdown"
      end

      def self.title_text : String
        "Markdown"
      end

      def self.desc_text : String
        "Markdown lightweight markup language"
      end

      def self.file_exts : Array(String)
        ["*.md", "*.markdown"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        # :root
        root = State.new(:root)

        # Fenced code blocks
        root.add_rule Rule.new(/^```[^\n]*\n[\s\S]*?^```\s*$/m, Tokens::StrBacktick)

        # Headings
        root.add_rule Rule.new(/^\#{1,6}\s+[^\n]+/m, Tokens::GenericHeading)

        # Horizontal rules
        root.add_rule Rule.new(/^(?:---|\*\*\*|___)\s*$/m, Tokens::Punctuation)

        # Blockquotes
        root.add_rule Rule.new(/^>\s+[^\n]*/m, Tokens::GenericTraceback)

        # Unordered list items
        root.add_rule Rule.new(/^[ \t]*[*-]\s+/m, Tokens::Punctuation)

        # Ordered list items
        root.add_rule Rule.new(/^[ \t]*\d+\.\s+/m, Tokens::Punctuation)

        # Images: ![alt](url)
        root.add_rule Rule.new(
          /!\[([^\]]*)\]\(([^)]*)\)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::Punctuation, "!["},
              {Tokens::StrDouble, m[1]},
              {Tokens::Punctuation, "]("},
              {Tokens::NameAttribute, m[2]},
              {Tokens::Punctuation, ")"},
            ] of TokenPair
          }
        )

        # Links: [text](url)
        root.add_rule Rule.new(
          /\[([^\]]*)\]\(([^)]*)\)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::Punctuation, "["},
              {Tokens::NameLabel, m[1]},
              {Tokens::Punctuation, "]("},
              {Tokens::NameAttribute, m[2]},
              {Tokens::Punctuation, ")"},
            ] of TokenPair
          }
        )

        # Inline code
        root.add_rule Rule.new(/`[^`\n]+`/, Tokens::StrBacktick)

        # Bold **text** and __text__
        root.add_rule Rule.new(/\*\*[^*]+\*\*/, Tokens::GenericStrong)
        root.add_rule Rule.new(/__[^_]+__/, Tokens::GenericStrong)

        # Italic *text* and _text_
        root.add_rule Rule.new(/\*[^*\n]+\*/, Tokens::GenericEmph)
        root.add_rule Rule.new(/_[^_\n]+_/, Tokens::GenericEmph)

        # HTML entities
        root.add_rule Rule.new(/&\#?\w+;/, Tokens::NameEntity)

        # Whitespace
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)

        # Plain text
        root.add_rule Rule.new(/[^\s`*_\[!#>&\d-]+/, Tokens::Text)
        root.add_rule Rule.new(/./, Tokens::Text)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("markdown", Markdown)
    RegexLexer.register("md", Markdown)
  end
end
