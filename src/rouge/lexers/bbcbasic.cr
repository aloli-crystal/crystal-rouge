module Rouge
  module Lexers
    class BBCBasic < RegexLexer
      def self.tag_name : String
        "bbcbasic"
      end

      def self.title_text : String
        "BBC BASIC"
      end

      def self.desc_text : String
        "BBC BASIC programming language"
      end

      def self.file_exts : Array(String)
        ["*.bbc"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(AND AUTO BPUT CALL CASE CHAIN CLEAR CLG CLS COLOUR DATA DEF DIM DRAW ELSE END ENDCASE ENDIF ENDPROC ENDWHILE ENVELOPE ERROR EVAL FALSE FOR GCOL GOSUB GOTO IF INPUT LET LINE LIST LOAD LOCAL MODE MOVE NEXT NOT OF OFF ON OR OSCLI OTHERWISE PLOT POINT PRINT PROC QUIT READ REPEAT REPORT RESTORE RETURN RUN SAVE SOUND STEP STOP SWAP SYS THEN TIME TO TRACE TRUE UNTIL VDU WAIT WHEN WHILE)

        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\n]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/REM[^\n]*/i, Tokens::CommentSingle)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/i, Tokens::Keyword)
        root.add_rule Rule.new(/(?:TRUE|FALSE)\b/i, Tokens::KeywordConstant)
        root.add_rule Rule.new(/&[0-9A-Fa-f]+/, Tokens::NumHex)
        root.add_rule Rule.new(/\d+\.\d*/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_]\w*[%$#]?/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/%=<>!^~]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.:@]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("bbcbasic", BBCBasic)
  end
end
