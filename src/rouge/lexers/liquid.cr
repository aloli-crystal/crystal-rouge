module Rouge
  module Lexers
    class Liquid < RegexLexer
      def self.tag_name : String
        "liquid"
      end

      def self.title_text : String
        "Liquid"
      end

      def self.desc_text : String
        "Liquid template language (Shopify)"
      end

      def self.file_exts : Array(String)
        ["*.liquid"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(if elsif else endif unless endunless for endfor case when endcase tablerow endtablerow assign capture endcapture increment decrement include render raw endraw comment endcomment cycle break continue in)
        constants = %w(true false nil null blank empty)

        tag = State.new(:tag)
        tag.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        tag.add_rule Rule.new(/%\}/, Tokens::Punctuation, pop: true)
        tag.add_rule Rule.new(/"(?:[^"\\]|\\.)*"/, Tokens::StrDouble)
        tag.add_rule Rule.new(/'(?:[^'\\]|\\.)*'/, Tokens::StrSingle)
        tag.add_rule Rule.new(/(?:#{constants.join("|")})\b/, Tokens::KeywordConstant)
        tag.add_rule Rule.new(/(?:#{keywords.join("|")})\b/, Tokens::Keyword)
        tag.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        tag.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        tag.add_rule Rule.new(/\|/, Tokens::Operator)
        tag.add_rule Rule.new(/[a-zA-Z_][\w.-]*/, Tokens::Name)
        tag.add_rule Rule.new(/[=<>!:]+/, Tokens::Operator)
        tag.add_rule Rule.new(/[,()]/, Tokens::Punctuation)
        states[:tag] = tag

        output = State.new(:output)
        output.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        output.add_rule Rule.new(/\}\}/, Tokens::Punctuation, pop: true)
        output.add_rule Rule.new(/"(?:[^"\\]|\\.)*"/, Tokens::StrDouble)
        output.add_rule Rule.new(/'(?:[^'\\]|\\.)*'/, Tokens::StrSingle)
        output.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        output.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        output.add_rule Rule.new(/\|/, Tokens::Operator)
        output.add_rule Rule.new(/[a-zA-Z_][\w.-]*/, Tokens::Name)
        output.add_rule Rule.new(/[:]/, Tokens::Punctuation)
        states[:output] = output

        root = State.new(:root)
        root.add_rule Rule.new(/\{%[-]?\s*comment\s*[-]?%\}.*?\{%[-]?\s*endcomment\s*[-]?%\}/m, Tokens::CommentMultiline)
        root.add_rule Rule.new(/\{\{/, Tokens::Punctuation, next_state: :output)
        root.add_rule Rule.new(/\{%[-]?/, Tokens::Punctuation, next_state: :tag)
        root.add_rule Rule.new(/[^{]+/, Tokens::Text)
        root.add_rule Rule.new(/\{/, Tokens::Text)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("liquid", Liquid)
  end
end
