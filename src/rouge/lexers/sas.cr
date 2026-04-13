module Rouge
  module Lexers
    class SAS < RegexLexer
      def self.tag_name : String
        "sas"
      end

      def self.title_text : String
        "SAS"
      end

      def self.desc_text : String
        "SAS programming language (sas.com)"
      end

      def self.file_exts : Array(String)
        ["*.sas"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        # :string_double
        sd = State.new(:string_double)
        sd.add_rule Rule.new(/[^"]+/, Tokens::StrDouble)
        sd.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        states[:string_double] = sd

        # :string_single
        ss = State.new(:string_single)
        ss.add_rule Rule.new(/[^']+/, Tokens::StrSingle)
        ss.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        states[:string_single] = ss

        # :comment_multi
        cm = State.new(:comment_multi)
        cm.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        cm.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        cm.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment_multi] = cm

        # :root
        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multi)
        root.add_rule Rule.new(/\*[^;]*;/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)

        # Macro keywords
        root.add_rule Rule.new(/%(?:macro|mend|let|if|then|else|do|end|include|put|global|local|sysfunc|eval|str|nrstr|quote|nrquote|bquote|nrbquote|unquote)\b/i, Tokens::KeywordReserved)

        # Regular keywords
        root.add_rule Rule.new(/\b(?:data|run|set|merge|by|if|then|else|do|end|output|input|put|proc|quit|libname|filename|options|title|footnote|where|keep|drop|rename|length|format|informat|label|array|retain|cards|datalines)\b/i, Tokens::Keyword)

        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        root.add_rule Rule.new(/[+\-*\/%<>=!&|^~]+/, Tokens::Operator)
        root.add_rule Rule.new(/[;(),\.]+/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("sas", SAS)
  end
end
