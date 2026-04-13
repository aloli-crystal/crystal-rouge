module Rouge
  module Lexers
    class IDLang < RegexLexer
      def self.tag_name : String
        "idlang"
      end

      def self.title_text : String
        "IDL"
      end

      def self.desc_text : String
        "IDL (Interactive Data Language)"
      end

      def self.file_exts : Array(String)
        ["*.pro"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(PRO FUNCTION END BEGIN RETURN IF THEN ELSE FOR DO WHILE REPEAT UNTIL CASE OF SWITCH BREAK CONTINUE GOTO COMMON COMPILE_OPT ENDFOR ENDIF ENDWHILE ENDCASE ENDSWITCH ENDREP)

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
        root.add_rule Rule.new(/;[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/i, Tokens::Keyword)
        root.add_rule Rule.new(/\d+\.\d*(?:[eEdD][+-]?\d+)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/%&|^~<>=!#]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.:]+/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("idlang", IDLang)
    RegexLexer.register("idl", IDLang)
  end
end
