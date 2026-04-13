module Rouge
  module Lexers
    class Slim < RegexLexer
      def self.tag_name : String
        "slim"
      end

      def self.title_text : String
        "Slim"
      end

      def self.desc_text : String
        "Slim templating language"
      end

      def self.file_exts : Array(String)
        ["*.slim"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        root = State.new(:root)
        root.add_rule Rule.new(/^(\s*)(\/\/.*)$/, block: ->(m : Regex::MatchData) {
          [
            {Tokens::TextWhitespace, m[1]},
            {Tokens::CommentSingle, m[2]},
          ] of TokenPair
        })
        root.add_rule Rule.new(/^(\s*)(\/[^\n]*)$/, block: ->(m : Regex::MatchData) {
          [
            {Tokens::TextWhitespace, m[1]},
            {Tokens::CommentSingle, m[2]},
          ] of TokenPair
        })
        root.add_rule Rule.new(/^(\s*)(-)(.*)$/, block: ->(m : Regex::MatchData) {
          [
            {Tokens::TextWhitespace, m[1]},
            {Tokens::Punctuation, m[2]},
            {Tokens::Text, m[3]},
          ] of TokenPair
        })
        root.add_rule Rule.new(/^(\s*)(=)(.*)$/, block: ->(m : Regex::MatchData) {
          [
            {Tokens::TextWhitespace, m[1]},
            {Tokens::Punctuation, m[2]},
            {Tokens::Text, m[3]},
          ] of TokenPair
        })
        root.add_rule Rule.new(/^(\s*)(\|)(.*)$/, block: ->(m : Regex::MatchData) {
          [
            {Tokens::TextWhitespace, m[1]},
            {Tokens::Punctuation, m[2]},
            {Tokens::Str, m[3]},
          ] of TokenPair
        })
        root.add_rule Rule.new(/#\{[^}]*\}/, Tokens::StrInterpol)
        root.add_rule Rule.new(/\.[a-zA-Z_][\w-]*/, Tokens::NameClass)
        root.add_rule Rule.new(/#[a-zA-Z_][\w-]*/, Tokens::NameOther)
        root.add_rule Rule.new(/\b(?:doctype|html|head|body|div|span|a|p|ul|ol|li|h[1-6]|form|input|button|table|tr|td|th|img|br|hr|link|meta|script|style|section|header|footer|nav|main|article|aside)\b/, Tokens::NameTag)
        root.add_rule Rule.new(/"[^"]*"/, Tokens::StrDouble)
        root.add_rule Rule.new(/'[^']*'/, Tokens::StrSingle)
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[=(),]/, Tokens::Punctuation)
        root.add_rule Rule.new(/./, Tokens::Text)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("slim", Slim)
  end
end
