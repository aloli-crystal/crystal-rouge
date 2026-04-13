module Rouge
  module Lexers
    class ArmAsm < RegexLexer
      def self.tag_name : String
        "armasm"
      end

      def self.title_text : String
        "ARM Assembly"
      end

      def self.desc_text : String
        "ARM assembly language"
      end

      def self.file_exts : Array(String)
        ["*.s", "*.S"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        instructions = %w(MOV LDR STR ADD SUB CMP B BL BX BEQ BNE BGT BLT BGE BLE PUSH POP MUL AND ORR EOR LSL LSR ASR NOP SWI SVC MOVS ADDS SUBS)
        directives = %w(.text .data .global .globl .word .byte .ascii .asciz .align .section .equ .extern .space .arm .thumb)
        registers = %w(R0 R1 R2 R3 R4 R5 R6 R7 R8 R9 R10 R11 R12 R13 R14 R15 SP LR PC CPSR SPSR)

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/;[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/@[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"[^"]*"/, Tokens::StrDouble)
        root.add_rule Rule.new(/(?:#{directives.map { |d| Regex.escape(d) }.join("|")})\b/i, Tokens::KeywordDeclaration)
        root.add_rule Rule.new(/(?:#{instructions.join("|")})\b/i, Tokens::Keyword)
        root.add_rule Rule.new(/(?:#{registers.join("|")})\b/i, Tokens::NameBuiltin)
        root.add_rule Rule.new(/#-?\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/0x[0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_]\w*:/, Tokens::NameLabel)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/%=<>!&|^~]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}\[\](),#]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("armasm", ArmAsm)
    RegexLexer.register("arm", ArmAsm)
  end
end
