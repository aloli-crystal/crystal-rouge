module Rouge
  module Lexers
    class MiniZinc < RegexLexer
      def self.tag_name : String
        "minizinc"
      end

      def self.title_text : String
        "MiniZinc"
      end

      def self.desc_text : String
        "MiniZinc constraint modelling language"
      end

      def self.file_exts : Array(String)
        ["*.mzn", "*.dzn"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        sd = State.new(:string_double)
        sd.add_rule Rule.new(/\\./, Tokens::StrEscape)
        sd.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        sd.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        states[:string_double] = sd

        cm = State.new(:comment_multi)
        cm.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        cm.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        cm.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment_multi] = cm

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/%[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multi)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)

        root.add_rule Rule.new(/\b(?:true|false)\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\b(?:int|float|bool|string|set|array|of|opt|par|var)\b/, Tokens::KeywordType)
        root.add_rule Rule.new(/\b(?:annotation|any|constraint|else|elseif|endif|enum|function|if|in|include|let|maximize|minimize|output|predicate|record|satisfy|solve|test|then|type|where)\b/, Tokens::Keyword)

        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        root.add_rule Rule.new(/[+\-*\/<>=!\\\.]+/, Tokens::Operator)
        root.add_rule Rule.new(/[(){};\[\],:]+/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("minizinc", MiniZinc)
    RegexLexer.register("mzn", MiniZinc)
  end
end
