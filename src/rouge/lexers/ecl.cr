module Rouge
  module Lexers
    class ECL < RegexLexer
      def self.tag_name : String
        "ecl"
      end

      def self.title_text : String
        "ECL"
      end

      def self.desc_text : String
        "Enterprise Control Language (HPCC Systems)"
      end

      def self.file_exts : Array(String)
        ["*.ecl"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(BEGINC ENDC DEFINE EXPORT IMPORT MACRO ENDMACRO MODULE END RECORD TRANSFORM FUNCTION RETURN SHARED LOCAL OUTPUT SORT DISTRIBUTE DEDUP JOIN PROJECT TABLE DATASET SET IF ELSE ELSEIF ENDIF MAP CASE CHOOSE ITERATE NORMALIZE ROLLUP DENORMALIZE GROUP GRAPH APPLY)

        comment_block = State.new(:comment_block)
        comment_block.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        comment_block.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        comment_block.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment_block] = comment_block

        string_single = State.new(:string_single)
        string_single.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_single.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        string_single.add_rule Rule.new(/[^'\\]+/, Tokens::StrSingle)
        states[:string_single] = string_single

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_block)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/i, Tokens::Keyword)
        root.add_rule Rule.new(/(?:TRUE|FALSE)\b/i, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\d+\.\d*/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/%=<>!&|^~:]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("ecl", ECL)
  end
end
