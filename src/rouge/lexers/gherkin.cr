module Rouge
  module Lexers
    class Gherkin < RegexLexer
      def self.tag_name : String
        "gherkin"
      end

      def self.title_text : String
        "Gherkin"
      end

      def self.desc_text : String
        "Gherkin BDD feature files"
      end

      def self.file_exts : Array(String)
        ["*.feature"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/#[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/@[\w]+/, Tokens::NameDecorator)
        root.add_rule Rule.new(/(?:Feature|Background|Scenario Outline|Scenario|Examples|Rule):/, Tokens::Keyword)
        root.add_rule Rule.new(/(?:Given|When|Then|And|But)\b/, Tokens::Keyword)
        root.add_rule Rule.new(/"[^"]*"/, Tokens::StrDouble)
        root.add_rule Rule.new(/<[^>]+>/, Tokens::NameVariable)
        root.add_rule Rule.new(/\|/, Tokens::Punctuation)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[^\n]+/, Tokens::Text)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("gherkin", Gherkin)
    RegexLexer.register("cucumber", Gherkin)
    RegexLexer.register("feature", Gherkin)
  end
end
