module Rouge
  module Lexers
    class SPARQL < RegexLexer
      def self.tag_name : String
        "sparql"
      end

      def self.title_text : String
        "SPARQL"
      end

      def self.desc_text : String
        "SPARQL query language for RDF"
      end

      def self.file_exts : Array(String)
        ["*.rq", "*.sparql"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(
          SELECT WHERE FILTER OPTIONAL UNION ORDER BY ASC DESC LIMIT OFFSET
          PREFIX BASE CONSTRUCT DESCRIBE ASK INSERT DELETE GRAPH FROM NAMED
          DISTINCT REDUCED GROUP HAVING BIND VALUES EXISTS NOT AS SERVICE
          MINUS IN SILENT
        )

        kw_pattern = keywords.join("|")

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/#.*/, Tokens::CommentSingle)
        root.add_rule Rule.new(Regex.new("\\b(?:#{kw_pattern})\\b", Regex::Options::IGNORE_CASE), Tokens::Keyword)
        root.add_rule Rule.new(/(?:true|false)\b/i, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\?[a-zA-Z_]\w*/, Tokens::NameVariable)
        root.add_rule Rule.new(/<[^>]*>/, Tokens::NameLabel)
        root.add_rule Rule.new(/[a-zA-Z_][\w-]*:[a-zA-Z_][\w-]*/, Tokens::NameOther)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string)
        root.add_rule Rule.new(/'[^']*'/, Tokens::StrSingle)
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[=!<>]+|&&|\|\||\*/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        states[:root] = root

        str = State.new(:string)
        str.add_rule Rule.new(/\\./, Tokens::StrEscape)
        str.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        str.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string] = str

        states
      end
    end

    RegexLexer.register("sparql", SPARQL)
  end
end
