module Rouge
  module Lexers
    class CMHG < RegexLexer
      def self.tag_name : String
        "cmhg"
      end

      def self.title_text : String
        "CMHG"
      end

      def self.desc_text : String
        "C Module Header Generator"
      end

      def self.file_exts : Array(String)
        ["*.cmhg"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(title help-string initialisation-code finalisation-code service-call-handler command-keyword-table swi-chunk-base-number swi-handler-code swi-decoding-table irq-handlers vector-handlers event-handler generic-veneers date-string)

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/;[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"[^"]*"/, Tokens::StrDouble)
        root.add_rule Rule.new(/(?:#{keywords.map { |k| Regex.escape(k) }.join("|")})\b/i, Tokens::Keyword)
        root.add_rule Rule.new(/0x[0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_][\w-]*/, Tokens::Name)
        root.add_rule Rule.new(/[=:,()]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("cmhg", CMHG)
  end
end
