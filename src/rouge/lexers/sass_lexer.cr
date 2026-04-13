module Rouge
  module Lexers
    class SassLexer < RegexLexer
      def self.tag_name : String
        "sass"
      end

      def self.title_text : String
        "Sass"
      end

      def self.desc_text : String
        "Sass (indented syntax)"
      end

      def self.file_exts : Array(String)
        ["*.sass"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)

        # Single-line comments
        root.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)

        # Multi-line comments
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :multiline_comment)

        # Variables
        root.add_rule Rule.new(/\$[a-zA-Z_][a-zA-Z0-9_-]*/, Tokens::NameVariable)

        # Mixin definition (=name)
        root.add_rule Rule.new(/=[a-zA-Z_][a-zA-Z0-9_-]*/, Tokens::NameFunction)

        # Mixin include (+name)
        root.add_rule Rule.new(/\+[a-zA-Z_][a-zA-Z0-9_-]*/, Tokens::NameDecorator)

        # Directives
        root.add_rule Rule.new(/@(?:import|extend|include|mixin|if|else|for|each|while|media|charset|font-face|keyframes|content|warn|debug|error|use|forward|at-root)\b/, Tokens::KeywordNamespace)

        # Property name: value
        root.add_rule Rule.new(
          /([a-zA-Z-][a-zA-Z0-9-]*)(\s*:\s*)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::NameAttribute, m[1]},
              {Tokens::Punctuation, m[2]},
            ] of TokenPair
          }
        )

        # Colors
        root.add_rule Rule.new(/#[0-9a-fA-F]{3,8}\b/, Tokens::NumHex)

        # Numbers with units
        root.add_rule Rule.new(/\d+\.\d+(?:px|em|rem|%|pt|cm|mm|in|ex|vh|vw)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+(?:px|em|rem|%|pt|cm|mm|in|ex|vh|vw)?/, Tokens::NumInteger)

        # Strings
        root.add_rule Rule.new(/"[^"]*"/, Tokens::StrDouble)
        root.add_rule Rule.new(/'[^']*'/, Tokens::StrSingle)

        # Selectors / identifiers
        root.add_rule Rule.new(/&/, Tokens::Keyword)
        root.add_rule Rule.new(/\.[a-zA-Z_][a-zA-Z0-9_-]*/, Tokens::NameClass)
        root.add_rule Rule.new(/#[a-zA-Z_][a-zA-Z0-9_-]*/, Tokens::NameNamespace)
        root.add_rule Rule.new(/[a-zA-Z_][a-zA-Z0-9_-]*/, Tokens::NameTag)

        # Operators
        root.add_rule Rule.new(/[+\-*\/%=!<>]+/, Tokens::Operator)

        # Punctuation
        root.add_rule Rule.new(/[(),;:]/, Tokens::Punctuation)

        root.add_rule Rule.new(/./, Tokens::Text)

        states[:root] = root

        # Multiline comment state
        mc = State.new(:multiline_comment)
        mc.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        mc.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        mc.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:multiline_comment] = mc

        states
      end
    end

    RegexLexer.register("sass", SassLexer)
  end
end
