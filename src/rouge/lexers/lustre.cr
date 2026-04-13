module Rouge
  module Lexers
    class Lustre < RegexLexer
      def self.tag_name : String
        "lustre"
      end

      def self.title_text : String
        "Lustre"
      end

      def self.desc_text : String
        "Lustre synchronous language"
      end

      def self.file_exts : Array(String)
        ["*.lus"]
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

        ml = State.new(:comment_multi)
        ml.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        ml.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        ml.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment_multi] = ml

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/--[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multi)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)

        root.add_rule Rule.new(/\b(?:true|false)\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\b(?:int|real|bool)\b/, Tokens::KeywordType)
        root.add_rule Rule.new(/\b(?:node|function|returns|let|tel|var|const|type|if|then|else|with|when|merge|pre|fby|and|or|not|xor|mod)\b/, Tokens::Keyword)

        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        root.add_rule Rule.new(/[+\-*\/<>=!&|^~]+/, Tokens::Operator)
        root.add_rule Rule.new(/[(){};\[\],:.]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("lustre", Lustre)
  end
end
