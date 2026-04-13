module Rouge
  module Lexers
    class DataStudio < RegexLexer
      def self.tag_name : String
        "datastudio"
      end

      def self.title_text : String
        "Data Studio"
      end

      def self.desc_text : String
        "Google Data Studio formula language"
      end

      def self.file_exts : Array(String)
        [] of String
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        functions = %w(SUM AVG COUNT COUNT_DISTINCT MAX MIN MEDIAN PERCENTILE STDDEV VARIANCE CASE WHEN THEN ELSE END IF AND OR NOT IN CAST CONCAT CONTAINS ENDS_WITH STARTS_WITH LENGTH LOWER UPPER TRIM LEFT RIGHT REPLACE REGEXP_MATCH REGEXP_EXTRACT REGEXP_REPLACE ROUND FLOOR CEIL ABS POWER SQRT LOG MOD YEAR MONTH DAY HOUR MINUTE SECOND NOW TODAY DATE DATETIME TODATE FORMAT_DATETIME PARSE_DATETIME DATE_DIFF NARY_MAX NARY_MIN HYPERLINK IMAGE)

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/"[^"]*"/, Tokens::StrDouble)
        root.add_rule Rule.new(/'[^']*'/, Tokens::StrSingle)
        root.add_rule Rule.new(/(?:#{functions.join("|")})\b/i, Tokens::NameBuiltin)
        root.add_rule Rule.new(/(?:true|false|null)\b/i, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\d+\.\d*/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/%=<>!&|]+/, Tokens::Operator)
        root.add_rule Rule.new(/[(),]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("datastudio", DataStudio)
  end
end
