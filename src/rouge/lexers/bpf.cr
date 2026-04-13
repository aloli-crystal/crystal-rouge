module Rouge
  module Lexers
    class BPF < RegexLexer
      def self.tag_name : String
        "bpf"
      end

      def self.title_text : String
        "BPF"
      end

      def self.desc_text : String
        "BPF/eBPF bytecode assembly"
      end

      def self.file_exts : Array(String)
        ["*.bpf"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        instructions = %w(ldw ldh ldb stw sth stb jmp jeq jne jgt jge jlt jle jset call exit mov add sub mul div mod and or xor lsh rsh neg arsh ja lock xadd)
        registers = %w(r0 r1 r2 r3 r4 r5 r6 r7 r8 r9 r10)

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/;[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"[^"]*"/, Tokens::StrDouble)
        root.add_rule Rule.new(/(?:#{instructions.join("|")})\b/i, Tokens::Keyword)
        root.add_rule Rule.new(/(?:#{registers.join("|")})\b/i, Tokens::NameBuiltin)
        root.add_rule Rule.new(/#?0x[0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/#?-?\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_]\w*:/, Tokens::NameLabel)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/%=<>!&|^~]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}\[\](),]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("bpf", BPF)
  end
end
