module Rouge
  module Lexers
    class PLSQL < RegexLexer
      def self.tag_name : String
        "plsql"
      end

      def self.title_text : String
        "PL/SQL"
      end

      def self.desc_text : String
        "Oracle PL/SQL"
      end

      def self.file_exts : Array(String)
        ["*.sql", "*.pls", "*.pkb", "*.pks"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        ss = State.new(:string_single)
        ss.add_rule Rule.new(/''/, Tokens::StrEscape)
        ss.add_rule Rule.new(/[^']+/, Tokens::StrSingle)
        ss.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        states[:string_single] = ss

        cm = State.new(:comment_multi)
        cm.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        cm.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        cm.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment_multi] = cm

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/--[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multi)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)

        root.add_rule Rule.new(/\b(?:TRUE|FALSE|NULL)\b/i, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\b(?:NUMBER|VARCHAR2|VARCHAR|CHAR|INTEGER|INT|SMALLINT|DATE|TIMESTAMP|BOOLEAN|CLOB|BLOB|BINARY_INTEGER|PLS_INTEGER|LONG|RAW|ROWID|REAL|FLOAT)\b/i, Tokens::KeywordType)
        root.add_rule Rule.new(/\b(?:DECLARE|BEGIN|END|EXCEPTION|RAISE|LOOP|EXIT|WHEN|CURSOR|OPEN|FETCH|CLOSE|IS|AS|TYPE|SUBTYPE|RECORD|TABLE|INDEX|BY|CONSTANT|PROCEDURE|FUNCTION|RETURN|PACKAGE|BODY|CREATE|REPLACE|OR|TRIGGER|BEFORE|AFTER|INSTEAD|OF|INSERT|UPDATE|DELETE|SELECT|FROM|WHERE|INTO|SET|VALUES|AND|OR|NOT|IN|EXISTS|BETWEEN|LIKE|ORDER|GROUP|HAVING|UNION|ALL|DISTINCT|FOR|EACH|ROW|EXECUTE|IMMEDIATE|BULK|COLLECT|FORALL|PRAGMA|EXCEPTION_INIT|AUTONOMOUS_TRANSACTION|RESTRICT_REFERENCES|IF|THEN|ELSE|ELSIF|CASE|WHILE|GOTO|COMMIT|ROLLBACK|SAVEPOINT|GRANT|REVOKE|ALTER|DROP|TRUNCATE)\b/i, Tokens::Keyword)

        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        root.add_rule Rule.new(/:=|=>|\.\./, Tokens::Operator)
        root.add_rule Rule.new(/[+\-*\/<>=!|]+/, Tokens::Operator)
        root.add_rule Rule.new(/[(){};\[\],:.%@]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("plsql", PLSQL)
  end
end
