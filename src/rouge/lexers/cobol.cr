module Rouge
  module Lexers
    class COBOL < RegexLexer
      def self.tag_name : String
        "cobol"
      end

      def self.title_text : String
        "COBOL"
      end

      def self.desc_text : String
        "COBOL programming language"
      end

      def self.file_exts : Array(String)
        ["*.cob", "*.cbl", "*.cobol"]
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

        # :root
        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/^\*[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\*>[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)

        root.add_rule Rule.new(/\b(?:IDENTIFICATION|DIVISION|PROGRAM-ID|ENVIRONMENT|DATA|PROCEDURE|SECTION|PARAGRAPH|PERFORM|MOVE|ADD|SUBTRACT|MULTIPLY|DIVIDE|COMPUTE|IF|ELSE|END-IF|EVALUATE|WHEN|END-EVALUATE|GO|TO|STOP|RUN|DISPLAY|ACCEPT|READ|WRITE|OPEN|CLOSE|CALL|USING|GIVING|RETURNING|PIC|PICTURE|VALUE|OCCURS|REDEFINES|COPY|REPLACING|WORKING-STORAGE|FILE|FD|SELECT|ASSIGN|ORGANIZATION|ACCESS|STATUS)\b/i, Tokens::Keyword)

        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/\./, Tokens::Punctuation)
        root.add_rule Rule.new(/[(),]+/, Tokens::Punctuation)
        root.add_rule Rule.new(/[=<>]+/, Tokens::Operator)
        root.add_rule Rule.new(/[a-zA-Z][\w-]*/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("cobol", COBOL)
  end
end
