module Rouge
  module Lexers
    class Cypher < RegexLexer
      def self.tag_name : String
        "cypher"
      end

      def self.title_text : String
        "Cypher"
      end

      def self.desc_text : String
        "Neo4j Cypher query language"
      end

      def self.file_exts : Array(String)
        ["*.cypher", "*.cql"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(MATCH WHERE RETURN CREATE DELETE DETACH SET REMOVE MERGE WITH UNWIND ORDER BY SKIP LIMIT UNION OPTIONAL CALL YIELD CASE WHEN THEN ELSE END AND OR NOT IN IS NULL AS DISTINCT EXISTS CONTAINS STARTS ENDS XOR ON FOREACH USING INDEX SCAN CONSTRAINT UNIQUE ASSERT DROP)

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
        root.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/i, Tokens::Keyword)
        root.add_rule Rule.new(/(?:true|false|null)\b/i, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\d+\.\d*/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/:[A-Za-z_]\w*/, Tokens::NameLabel)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/-\[/, Tokens::Punctuation)
        root.add_rule Rule.new(/\]->/, Tokens::Punctuation)
        root.add_rule Rule.new(/-->/, Tokens::Punctuation)
        root.add_rule Rule.new(/<--/, Tokens::Punctuation)
        root.add_rule Rule.new(/[+\-*\/%=<>!]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("cypher", Cypher)
  end
end
