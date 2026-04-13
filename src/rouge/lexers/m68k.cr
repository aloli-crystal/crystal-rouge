module Rouge
  module Lexers
    class M68k < RegexLexer
      def self.tag_name : String
        "m68k"
      end

      def self.title_text : String
        "M68k"
      end

      def self.desc_text : String
        "Motorola 68000 assembly"
      end

      def self.file_exts : Array(String)
        ["*.s", "*.asm"]
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

        ss = State.new(:string_single)
        ss.add_rule Rule.new(/\\./, Tokens::StrEscape)
        ss.add_rule Rule.new(/[^'\\]+/, Tokens::StrSingle)
        ss.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        states[:string_single] = ss

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/;[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\*[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)

        # Directives
        root.add_rule Rule.new(/\b(?:dc|ds|equ|org|section|end)\b/i, Tokens::KeywordDeclaration)

        # Registers
        root.add_rule Rule.new(/\b(?:d[0-7]|a[0-7]|sp|pc|sr|ccr)\b/i, Tokens::NameBuiltin)

        # Instructions
        root.add_rule Rule.new(/\b(?:move|add|sub|mulu|muls|divu|divs|and|or|eor|not|lsl|lsr|asl|asr|rol|ror|bra|bsr|beq|bne|bcc|bcs|bmi|bpl|bge|blt|bgt|ble|jmp|jsr|rts|rte|nop|clr|cmp|tst|ext|swap|lea|pea|link|unlk|trap|dbra|moveq)(?:\.[bwl])?\b/i, Tokens::Keyword)

        # Numbers
        root.add_rule Rule.new(/\#?\$[0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/\#?%[01]+/, Tokens::NumBin)
        root.add_rule Rule.new(/\#?\d+/, Tokens::NumInteger)

        # Labels
        root.add_rule Rule.new(/[a-zA-Z_]\w*:/, Tokens::NameLabel)

        # Operators/punctuation
        root.add_rule Rule.new(/[+\-*\/,()#]/, Tokens::Punctuation)

        # Identifiers
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("m68k", M68k)
  end
end
