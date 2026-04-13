module Rouge
  module Lexers
    class Digdag < RegexLexer
      def self.tag_name : String
        "digdag"
      end

      def self.title_text : String
        "Digdag"
      end

      def self.desc_text : String
        "Digdag workflow definition language"
      end

      def self.file_exts : Array(String)
        ["*.dig"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        operators = %w(sh> py> rb> td> emr> mail> http> s3_wait> redshift> pg> embulk> loop> for_each> if> fail> echo> td_ddl> td_load> td_table_export>)
        specials = %w(_export _retry _parallel _check _error _do)

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/#[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\+[a-zA-Z_]\w*/, Tokens::NameFunction)
        root.add_rule Rule.new(/(?:#{specials.map { |s| Regex.escape(s) }.join("|")})\b/, Tokens::KeywordReserved)
        root.add_rule Rule.new(/(?:#{operators.map { |o| Regex.escape(o) }.join("|")})/, Tokens::Keyword)
        root.add_rule Rule.new(/"[^"]*"/, Tokens::StrDouble)
        root.add_rule Rule.new(/'[^']*'/, Tokens::StrSingle)
        root.add_rule Rule.new(/\$\{[^}]*\}/, Tokens::StrInterpol)
        root.add_rule Rule.new(/(?:true|false|null)\b/i, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/:/, Tokens::Punctuation)
        root.add_rule Rule.new(/[,\[\]{}]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("digdag", Digdag)
  end
end
