module Rouge
  module Lexers
    class BSL < RegexLexer
      def self.tag_name : String
        "bsl"
      end

      def self.title_text : String
        "BSL"
      end

      def self.desc_text : String
        "1C:Enterprise BSL language"
      end

      def self.file_exts : Array(String)
        ["*.bsl", "*.os"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(If Then ElsIf Else EndIf For Each In To Do EndDo While EndWhile Procedure EndProcedure Function EndFunction Var Return Continue Break Try Except EndTry Raise Export New Execute Goto And Or Not)

        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/""/, Tokens::StrEscape)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\n]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/\|[^\n]*/, Tokens::StrDouble)
        root.add_rule Rule.new(/'[0-9]{8}'/, Tokens::LiteralDate)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/i, Tokens::Keyword)
        root.add_rule Rule.new(/(?:True|False|Undefined|Null)\b/i, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\d+\.\d*/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_\p{Cyrillic}]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/%=<>]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("bsl", BSL)
    RegexLexer.register("1c", BSL)
  end
end
