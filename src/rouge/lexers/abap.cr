module Rouge
  module Lexers
    class ABAP < RegexLexer
      def self.tag_name : String
        "abap"
      end

      def self.title_text : String
        "ABAP"
      end

      def self.desc_text : String
        "SAP ABAP programming language"
      end

      def self.file_exts : Array(String)
        ["*.abap"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(REPORT DATA TYPE TYPES BEGIN END OF PERFORM FORM ENDFORM IF ELSE ENDIF LOOP ENDLOOP AT ENDAT SELECT FROM WHERE INTO TABLE WRITE MOVE CLEAR APPEND DELETE MODIFY READ CALL METHOD CLASS ENDCLASS PUBLIC PRIVATE PROTECTED SECTION DO ENDDO WHILE ENDWHILE CASE ENDCASE WHEN FUNCTION ENDFUNCTION TRY CATCH ENDTRY RAISE)

        # :comment
        comment = State.new(:comment)
        comment.add_rule Rule.new(/[^\n]*/, Tokens::CommentSingle, pop: true)
        states[:comment] = comment

        # :string
        string = State.new(:string)
        string.add_rule Rule.new(/''/, Tokens::StrEscape)
        string.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        string.add_rule Rule.new(/[^']+/, Tokens::StrSingle)
        states[:string] = string

        # :string_double
        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/""/, Tokens::StrEscape)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        # :root
        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/^\*[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"/, Tokens::CommentSingle, next_state: :comment)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string)
        root.add_rule Rule.new(/`[^`]*`/, Tokens::StrSingle)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/i, Tokens::Keyword)
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/<>=]/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.:@]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("abap", ABAP)
  end
end
