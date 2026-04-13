module Rouge
  module Lexers
    class CSVS < RegexLexer
      def self.tag_name : String
        "csvs"
      end

      def self.title_text : String
        "CSV Schema"
      end

      def self.desc_text : String
        "CSV Schema definition language"
      end

      def self.file_exts : Array(String)
        ["*.csvs"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(version totalColumns noHeader permitEmpty is not in starts ends regex range length unique checksum fileExists integrityCheck if or and)

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"[^"]*"/, Tokens::StrDouble)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/i, Tokens::Keyword)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[(),:@]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[+\-*\/%=<>!]+/, Tokens::Operator)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("csvs", CSVS)
  end
end
