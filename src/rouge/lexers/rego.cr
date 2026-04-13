module Rouge
  module Lexers
    class Rego < RegexLexer
      def self.tag_name : String
        "rego"
      end

      def self.title_text : String
        "Rego"
      end

      def self.desc_text : String
        "OPA Rego policy language"
      end

      def self.file_exts : Array(String)
        ["*.rego"]
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

        sb = State.new(:string_backtick)
        sb.add_rule Rule.new(/[^`]+/, Tokens::StrBacktick)
        sb.add_rule Rule.new(/`/, Tokens::StrBacktick, pop: true)
        states[:string_backtick] = sb

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/#[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/`/, Tokens::StrBacktick, next_state: :string_backtick)

        root.add_rule Rule.new(/\b(?:true|false|null)\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\b(?:package|import|default|else|not|with|as|some|every|if|contains|in)\b/, Tokens::Keyword)

        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        root.add_rule Rule.new(/:=|=|!=|==|[+\-*\/<>&|]+/, Tokens::Operator)
        root.add_rule Rule.new(/[(){};\[\],.:]+/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("rego", Rego)
  end
end
