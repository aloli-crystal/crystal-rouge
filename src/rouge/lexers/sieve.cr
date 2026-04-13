module Rouge
  module Lexers
    class Sieve < RegexLexer
      def self.tag_name : String
        "sieve"
      end

      def self.title_text : String
        "Sieve"
      end

      def self.desc_text : String
        "Sieve email filtering language"
      end

      def self.file_exts : Array(String)
        ["*.sieve", "*.siv"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)

        # Comments
        root.add_rule Rule.new(/#[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :multiline_comment)

        # Strings
        root.add_rule Rule.new(/"(?:\\.|[^"\\])*"/, Tokens::StrDouble)

        # Numbers with optional K/M/G
        root.add_rule Rule.new(/\d+[KMG]?/, Tokens::NumInteger)

        # Keywords
        root.add_rule Rule.new(/\b(?:require|if|elsif|else|stop|keep|discard|redirect|reject|fileinto|vacation|notify|addheader|deleteheader|replaceheader|addflag|removeflag|setflag|hasflag|address|header|envelope|body|size|exists|allof|anyof|not|true|false)\b/, Tokens::Keyword)

        # Comparators / match types
        root.add_rule Rule.new(/:(?:is|contains|matches|over|under|comparator|localpart|domain|all|value|count)\b/, Tokens::KeywordPseudo)

        # Punctuation
        root.add_rule Rule.new(/[{}\[\]();,]/, Tokens::Punctuation)

        # Operators
        root.add_rule Rule.new(/[=!<>]+/, Tokens::Operator)

        # Identifiers
        root.add_rule Rule.new(/[a-zA-Z_][a-zA-Z0-9_]*/, Tokens::Name)

        root.add_rule Rule.new(/./, Tokens::Text)

        states[:root] = root

        mc = State.new(:multiline_comment)
        mc.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        mc.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        mc.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:multiline_comment] = mc

        states
      end
    end

    RegexLexer.register("sieve", Sieve)
  end
end
