module Rouge
  module Lexers
    class HQL < RegexLexer
      def self.tag_name : String
        "hql"
      end

      def self.title_text : String
        "HQL"
      end

      def self.desc_text : String
        "Hive Query Language"
      end

      def self.file_exts : Array(String)
        ["*.hql", "*.q"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(SELECT FROM WHERE INSERT INTO VALUES UPDATE DELETE CREATE DROP ALTER TABLE DATABASE SCHEMA IF EXISTS NOT NULL DEFAULT PRIMARY KEY FOREIGN REFERENCES INDEX UNIQUE GRANT REVOKE AS ON SET ORDER BY GROUP HAVING LIMIT UNION ALL DISTINCT JOIN INNER LEFT RIGHT OUTER FULL CROSS BETWEEN LIKE IN AND OR IS CASE WHEN THEN ELSE END ASC DESC WITH OVER PARTITION ROWS RANGE PRECEDING FOLLOWING UNBOUNDED CURRENT ROW)
        hive_keywords = %w(PARTITIONED CLUSTERED BUCKETS SORTED STORED SEQUENCEFILE TEXTFILE RCFILE ORC PARQUET AVRO INPUTFORMAT OUTPUTFORMAT SERDE SERDEPROPERTIES TBLPROPERTIES LOCATION LATERAL VIEW EXPLODE POSEXPLODE DISTRIBUTE CLUSTER TRANSFORM MAP REDUCE LOAD DATA OVERWRITE DIRECTORY LOCAL EXTERNAL TEMPORARY)
        types = %w(INT BIGINT SMALLINT TINYINT FLOAT DOUBLE DECIMAL STRING VARCHAR CHAR BOOLEAN DATE TIMESTAMP BINARY ARRAY STRUCT MAP UNIONTYPE)

        comment_multi = State.new(:comment_multi)
        comment_multi.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        comment_multi.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        comment_multi.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment_multi] = comment_multi

        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        string_single = State.new(:string_single)
        string_single.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_single.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        string_single.add_rule Rule.new(/[^'\\]+/, Tokens::StrSingle)
        states[:string_single] = string_single

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/--[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multi)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)
        root.add_rule Rule.new(/(?:TRUE|FALSE|NULL)\b/i, Tokens::KeywordConstant)
        root.add_rule Rule.new(/(?:#{types.join("|")})\b/i, Tokens::KeywordType)
        root.add_rule Rule.new(/(?:#{hive_keywords.join("|")})\b/i, Tokens::Keyword)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/i, Tokens::Keyword)
        root.add_rule Rule.new(/\d+\.\d*/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/%&|^~<>=!]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("hql", HQL)
  end
end
