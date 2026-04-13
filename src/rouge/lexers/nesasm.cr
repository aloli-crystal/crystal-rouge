module Rouge
  module Lexers
    class NESASM < RegexLexer
      def self.tag_name : String
        "nesasm"
      end

      def self.title_text : String
        "NESASM"
      end

      def self.desc_text : String
        "NESASM (NES assembler)"
      end

      def self.file_exts : Array(String)
        ["*.nesasm", "*.nes"]
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

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/;[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)

        # Directives
        root.add_rule Rule.new(/\.(?:db|dw|org|bank|inesprg|ineschr|inesmap|inesmir|rsset|rs|macro|endm|if|else|endif|include|incbin)\b/i, Tokens::KeywordDeclaration)

        # Instructions
        root.add_rule Rule.new(/\b(?:lda|sta|ldx|stx|ldy|sty|adc|sbc|and|ora|eor|cmp|cpx|cpy|inc|dec|inx|iny|dex|dey|tax|tay|txa|tya|tsx|txs|pha|pla|php|plp|clc|sec|cli|sei|cld|sed|clv|jmp|jsr|rts|rti|brk|nop|bcc|bcs|beq|bne|bmi|bpl|bvs|bvc|bit|asl|lsr|rol|ror)\b/i, Tokens::Keyword)

        # Numbers
        root.add_rule Rule.new(/\$[0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/%[01]+/, Tokens::NumBin)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        # Labels
        root.add_rule Rule.new(/[a-zA-Z_]\w*:/, Tokens::NameLabel)

        root.add_rule Rule.new(/[+\-*\/,#()]+/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("nesasm", NESASM)
  end
end
