module Rouge
  module Lexers
    class TAP < RegexLexer
      def self.tag_name : String
        "tap"
      end

      def self.title_text : String
        "TAP"
      end

      def self.desc_text : String
        "Test Anything Protocol"
      end

      def self.file_exts : Array(String)
        ["*.tap"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)

        # Plan
        root.add_rule Rule.new(/\d+\.\.\d+/, Tokens::Keyword)

        # BAIL OUT!
        root.add_rule Rule.new(/Bail out![^\n]*/, Tokens::GenericError)

        # ok line
        root.add_rule Rule.new(
          /(ok)(\s+)(\d+)?(\s*)(#\s*(?:TODO|SKIP)[^\n]*)?/i,
          block: ->(m : Regex::MatchData) {
            result = [{Tokens::GenericInserted, m[1]}, {Tokens::TextWhitespace, m[2]}] of TokenPair
            result << {Tokens::NumInteger, m[3]} if m[3]?
            result << {Tokens::TextWhitespace, m[4]} if m[4]?
            result << {Tokens::CommentSpecial, m[5]} if m[5]?
            result
          }
        )

        # not ok line
        root.add_rule Rule.new(
          /(not ok)(\s+)(\d+)?(\s*)(#\s*(?:TODO|SKIP)[^\n]*)?/i,
          block: ->(m : Regex::MatchData) {
            result = [{Tokens::GenericError, m[1]}, {Tokens::TextWhitespace, m[2]}] of TokenPair
            result << {Tokens::NumInteger, m[3]} if m[3]?
            result << {Tokens::TextWhitespace, m[4]} if m[4]?
            result << {Tokens::CommentSpecial, m[5]} if m[5]?
            result
          }
        )

        # Diagnostics
        root.add_rule Rule.new(/#[^\n]*/, Tokens::CommentSingle)

        # Anything else
        root.add_rule Rule.new(/[^\n]+/, Tokens::Text)

        root.add_rule Rule.new(/./, Tokens::Text)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("tap", TAP)
  end
end
