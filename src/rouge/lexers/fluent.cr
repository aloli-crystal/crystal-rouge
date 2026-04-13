module Rouge
  module Lexers
    class Fluent < RegexLexer
      def self.tag_name : String
        "fluent"
      end

      def self.title_text : String
        "Fluent"
      end

      def self.desc_text : String
        "Mozilla Fluent localization format"
      end

      def self.file_exts : Array(String)
        ["*.ftl"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/###[^\n]*/, Tokens::CommentSpecial)
        root.add_rule Rule.new(/##[^\n]*/, Tokens::CommentDoc)
        root.add_rule Rule.new(/#[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\{/, Tokens::Punctuation, next_state: :placeable)
        root.add_rule Rule.new(/\.[a-zA-Z][\w-]*/, Tokens::NameAttribute)
        root.add_rule Rule.new(/([a-zA-Z][\w-]*)(\s*)(=)/, block: ->(m : Regex::MatchData) {
          [
            {Tokens::NameFunction, m[1]},
            {Tokens::TextWhitespace, m[2]},
            {Tokens::Operator, m[3]},
          ] of TokenPair
        })
        root.add_rule Rule.new(/\*\[/, Tokens::Punctuation)
        root.add_rule Rule.new(/\[/, Tokens::Punctuation)
        root.add_rule Rule.new(/\]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[^\n{}\[\]#.=]+/, Tokens::Str)
        root.add_rule Rule.new(/./, Tokens::Text)
        states[:root] = root

        placeable = State.new(:placeable)
        placeable.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        placeable.add_rule Rule.new(/\}/, Tokens::Punctuation, pop: true)
        placeable.add_rule Rule.new(/\$[a-zA-Z][\w-]*/, Tokens::NameVariable)
        placeable.add_rule Rule.new(/[A-Z][A-Z_0-9]*(?=\s*\()/, Tokens::NameFunction)
        placeable.add_rule Rule.new(/->/, Tokens::Operator)
        placeable.add_rule Rule.new(/\*\[/, Tokens::Punctuation)
        placeable.add_rule Rule.new(/\[/, Tokens::Punctuation)
        placeable.add_rule Rule.new(/\]/, Tokens::Punctuation)
        placeable.add_rule Rule.new(/[(),]/, Tokens::Punctuation)
        placeable.add_rule Rule.new(/"[^"]*"/, Tokens::StrDouble)
        placeable.add_rule Rule.new(/-?\d+\.\d+/, Tokens::NumFloat)
        placeable.add_rule Rule.new(/-?\d+/, Tokens::NumInteger)
        placeable.add_rule Rule.new(/[a-zA-Z][\w-]*/, Tokens::Name)
        states[:placeable] = placeable

        states
      end
    end

    RegexLexer.register("fluent", Fluent)
  end
end
