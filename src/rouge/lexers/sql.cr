module Rouge
  module Lexers
    class SQL < RegexLexer
      def self.tag_name : String
        "sql"
      end

      def self.title_text : String
        "SQL"
      end

      def self.desc_text : String
        "Structured Query Language"
      end

      def self.file_exts : Array(String)
        ["*.sql"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(
          SELECT FROM WHERE INSERT UPDATE DELETE CREATE DROP ALTER TABLE INDEX
          JOIN LEFT RIGHT INNER OUTER ON AND OR NOT IN IS NULL AS ORDER BY
          GROUP HAVING LIMIT OFFSET UNION EXISTS BETWEEN LIKE SET INTO VALUES
          DISTINCT COUNT SUM AVG MIN MAX CASE WHEN THEN ELSE END BEGIN COMMIT
          ROLLBACK GRANT REVOKE PRIMARY KEY FOREIGN REFERENCES CONSTRAINT
          DEFAULT CHECK UNIQUE VIEW TRIGGER PROCEDURE FUNCTION IF ELSE WHILE
          RETURN DECLARE EXEC WITH RECURSIVE OVER PARTITION WINDOW FETCH NEXT ROWS
        )

        types = %w(
          INT INTEGER SMALLINT BIGINT DECIMAL NUMERIC FLOAT REAL DOUBLE
          CHAR VARCHAR TEXT BLOB DATE TIME TIMESTAMP BOOLEAN SERIAL UUID
        )

        kw_pattern = keywords.join("|")
        type_pattern = types.join("|")

        # :root
        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/--.*$/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :multiline_comments)
        root.add_rule Rule.new(Regex.new("\\b(?:#{kw_pattern})\\b", Regex::Options::IGNORE_CASE), Tokens::Keyword)
        root.add_rule Rule.new(Regex.new("\\b(?:#{type_pattern})\\b", Regex::Options::IGNORE_CASE), Tokens::KeywordType)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :single_string)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :double_string)
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[+\-*\/=<>!]+/, Tokens::Operator)
        root.add_rule Rule.new(/[;,().]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        states[:root] = root

        # :multiline_comments
        mc = State.new(:multiline_comments)
        mc.add_rule Rule.new(/[^*\/]+/, Tokens::CommentMultiline)
        mc.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        mc.add_rule Rule.new(/[*\/]/, Tokens::CommentMultiline)
        states[:multiline_comments] = mc

        # :single_string
        ss = State.new(:single_string)
        ss.add_rule Rule.new(/[^'\\]+/, Tokens::StrSingle)
        ss.add_rule Rule.new(/\\./, Tokens::StrEscape)
        ss.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        states[:single_string] = ss

        # :double_string
        ds = State.new(:double_string)
        ds.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        ds.add_rule Rule.new(/\\./, Tokens::StrEscape)
        ds.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        states[:double_string] = ds

        states
      end
    end

    RegexLexer.register("sql", SQL)
  end
end
