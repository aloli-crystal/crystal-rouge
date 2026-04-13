module Rouge
  module Lexers
    class BrightScript < RegexLexer
      def self.tag_name : String
        "brightscript"
      end

      def self.title_text : String
        "BrightScript"
      end

      def self.desc_text : String
        "BrightScript programming language (Roku)"
      end

      def self.file_exts : Array(String)
        ["*.brs"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(and as dim each else elseif end endif endwhile exit false for function goto if in invalid let line next not objfun or pos print return step stop sub tab then to true type void while end\s+function end\s+sub end\s+if end\s+for end\s+while)

        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\n]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/'[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/REM\b[^\n]*/i, Tokens::CommentSingle)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/i, Tokens::Keyword)
        root.add_rule Rule.new(/(?:true|false|invalid)\b/i, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\d+\.\d*/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/%=<>]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.:@]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("brightscript", BrightScript)
    RegexLexer.register("brs", BrightScript)
  end
end
