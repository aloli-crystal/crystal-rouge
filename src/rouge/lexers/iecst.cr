module Rouge
  module Lexers
    class IECST < RegexLexer
      def self.tag_name : String
        "iecst"
      end

      def self.title_text : String
        "IEC 61131-3 ST"
      end

      def self.desc_text : String
        "IEC 61131-3 Structured Text"
      end

      def self.file_exts : Array(String)
        ["*.st", "*.scl"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(PROGRAM END_PROGRAM FUNCTION END_FUNCTION FUNCTION_BLOCK END_FUNCTION_BLOCK VAR VAR_INPUT VAR_OUTPUT VAR_IN_OUT VAR_TEMP VAR_GLOBAL END_VAR IF THEN ELSE ELSIF END_IF CASE OF END_CASE FOR TO BY DO END_FOR WHILE END_WHILE REPEAT UNTIL END_REPEAT RETURN EXIT AND OR NOT XOR MOD)
        types = %w(BOOL BYTE WORD DWORD LWORD SINT INT DINT LINT USINT UINT UDINT ULINT REAL LREAL TIME DATE STRING ARRAY)
        constants = %w(TRUE FALSE)

        comment_multi = State.new(:comment_multi)
        comment_multi.add_rule Rule.new(/\*\)/, Tokens::CommentMultiline, pop: true)
        comment_multi.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        comment_multi.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment_multi] = comment_multi

        string_single = State.new(:string_single)
        string_single.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        string_single.add_rule Rule.new(/[^']+/, Tokens::StrSingle)
        states[:string_single] = string_single

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\(\*/, Tokens::CommentMultiline, next_state: :comment_multi)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)
        root.add_rule Rule.new(/(?:#{constants.join("|")})\b/i, Tokens::KeywordConstant)
        root.add_rule Rule.new(/(?:#{types.join("|")})\b/i, Tokens::KeywordType)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/i, Tokens::Keyword)
        root.add_rule Rule.new(/\d+\.\d*/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/%&|^~<>=!:]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("iecst", IECST)
  end
end
