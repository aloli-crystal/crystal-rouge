module Rouge
  module Lexers
    class KickAssembler < RegexLexer
      def self.tag_name : String
        "kickassembler"
      end

      def self.title_text : String
        "Kick Assembler"
      end

      def self.desc_text : String
        "Kick Assembler for C64"
      end

      def self.file_exts : Array(String)
        ["*.asm"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        instructions = %w(lda sta ldx stx ldy sty jmp jsr rts rti brk nop pha pla php plp adc sbc and ora eor cmp cpx cpy inc dec inx iny dex dey asl lsr rol ror bcc bcs beq bne bmi bpl bvs bvc clc sec cli sei cld sed clv tax tay txa tya tsx txs)
        directives = %w(.pc .byte .word .text .fill .const .var .label .macro .function .if .for .while .eval .import .importonce .namespace .filenamespace .segment .disk .file .modify .print .printnow .error .define .struct .enum .return .break)

        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/(?:#{directives.map { |d| Regex.escape(d) }.join("|")})\b/i, Tokens::KeywordDeclaration)
        root.add_rule Rule.new(/(?:#{instructions.join("|")})\b/i, Tokens::Keyword)
        root.add_rule Rule.new(/\$[0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/%[01]+/, Tokens::NumBin)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/#/, Tokens::Operator)
        root.add_rule Rule.new(/[a-zA-Z_]\w*:/, Tokens::NameLabel)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/%&|^~<>=!]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("kickassembler", KickAssembler)
    RegexLexer.register("kick_asm", KickAssembler)
  end
end
