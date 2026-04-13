module Rouge
  module Lexers
    class NASM < RegexLexer
      def self.tag_name : String
        "nasm"
      end

      def self.title_text : String
        "NASM"
      end

      def self.desc_text : String
        "Netwide Assembler (nasm.us)"
      end

      def self.file_exts : Array(String)
        ["*.asm", "*.nasm"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        # :string_double
        sd = State.new(:string_double)
        sd.add_rule Rule.new(/\\./, Tokens::StrEscape)
        sd.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        sd.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        states[:string_double] = sd

        # :string_single
        ss = State.new(:string_single)
        ss.add_rule Rule.new(/\\./, Tokens::StrEscape)
        ss.add_rule Rule.new(/[^'\\]+/, Tokens::StrSingle)
        ss.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        states[:string_single] = ss

        # :root
        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/;[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)

        # Sections
        root.add_rule Rule.new(/\.(?:text|data|bss)\b/, Tokens::NameLabel)

        # Directives
        root.add_rule Rule.new(/\b(?:section|global|extern|db|dw|dd|dq|resb|resw|resd|resq|times|equ)\b/i, Tokens::KeywordDeclaration)

        # Instructions
        root.add_rule Rule.new(/\b(?:mov|push|pop|call|ret|jmp|je|jne|jz|jnz|cmp|add|sub|mul|div|inc|dec|and|or|xor|not|shl|shr|lea|int|syscall|nop)\b/i, Tokens::Keyword)

        # Registers
        root.add_rule Rule.new(/\b(?:eax|ebx|ecx|edx|esi|edi|esp|ebp|rax|rbx|rcx|rdx|rsi|rdi|rsp|rbp|r8|r9|r10|r11|r12|r13|r14|r15|al|ah|bl|bh|cl|ch|dl|dh|sil|dil|spl|bpl|r8b|r9b|r10b|r11b|r12b|r13b|r14b|r15b|ax|bx|cx|dx|si|di|sp|bp|xmm0|xmm1|xmm2|xmm3|xmm4|xmm5|xmm6|xmm7|xmm8|xmm9|xmm10|xmm11|xmm12|xmm13|xmm14|xmm15)\b/i, Tokens::NameBuiltin)

        # Numbers
        root.add_rule Rule.new(/0[xX][0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/0[bB][01]+/, Tokens::NumBin)
        root.add_rule Rule.new(/0[oO][0-7]+/, Tokens::NumOct)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        # Operators
        root.add_rule Rule.new(/[+\-*\/%,:\[\]]+/, Tokens::Punctuation)

        # Labels
        root.add_rule Rule.new(/[a-zA-Z_]\w*:/, Tokens::NameLabel)

        # Identifiers
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("nasm", NASM)
    RegexLexer.register("asm", NASM)
  end
end
