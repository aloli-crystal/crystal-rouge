module Rouge
  module Lexers
    class APIBlueprint < RegexLexer
      def self.tag_name : String
        "apiblueprint"
      end

      def self.title_text : String
        "API Blueprint"
      end

      def self.desc_text : String
        "API Blueprint documentation format"
      end

      def self.file_exts : Array(String)
        ["*.apib"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/^\#{1,6}\s+[^\n]*/, Tokens::GenericHeading)
        root.add_rule Rule.new(/^>\s+[^\n]*/, Tokens::GenericEmph)
        root.add_rule Rule.new(/^(\+\s+(?:Request|Response|Parameters|Attributes|Body|Headers|Schema|Model|Values|Members))[^\n]*/i, Tokens::Keyword)
        root.add_rule Rule.new(/^(\s*[\+\-\*]\s+)/, Tokens::Punctuation)
        root.add_rule Rule.new(/`[^`\n]+`/, Tokens::StrBacktick)
        root.add_rule Rule.new(/```/, Tokens::StrBacktick, next_state: :codeblock)
        root.add_rule Rule.new(/(?:GET|POST|PUT|PATCH|DELETE|HEAD|OPTIONS|TRACE)\b/, Tokens::KeywordReserved)
        root.add_rule Rule.new(/\b\d{3}\b/, Tokens::NumInteger)
        root.add_rule Rule.new(/https?:\/\/[^\s\n]+/, Tokens::StrOther)
        root.add_rule Rule.new(/[^\n]+/, Tokens::Text)
        states[:root] = root

        codeblock = State.new(:codeblock)
        codeblock.add_rule Rule.new(/```/, Tokens::StrBacktick, pop: true)
        codeblock.add_rule Rule.new(/[^`]+/, Tokens::Str)
        codeblock.add_rule Rule.new(/`/, Tokens::Str)
        states[:codeblock] = codeblock

        states
      end
    end

    RegexLexer.register("apiblueprint", APIBlueprint)
    RegexLexer.register("apib", APIBlueprint)
  end
end
