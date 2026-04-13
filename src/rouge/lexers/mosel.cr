module Rouge
  module Lexers
    class Mosel < RegexLexer
      def self.tag_name : String
        "mosel"
      end

      def self.title_text : String
        "Mosel"
      end

      def self.desc_text : String
        "FICO Xpress Mosel language"
      end

      def self.file_exts : Array(String)
        ["*.mos"]
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
        root.add_rule Rule.new(/![^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)

        root.add_rule Rule.new(/\b(?:model|end-model|uses|declarations|end-declarations|procedure|end-procedure|function|end-function|if|then|else|elif|end-if|forall|do|end-do|while|repeat|until|case|of|end-case|next|break|return|forward|public|include|import|as|from|is_binary|is_integer|is_continuous|is_free|is_semcont|is_semicont|is_sos1|is_sos2|is_partint|minimize|maximize)\b/, Tokens::Keyword)

        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        root.add_rule Rule.new(/[+\-*\/<>=!]+/, Tokens::Operator)
        root.add_rule Rule.new(/[(){};\[\],:.]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("mosel", Mosel)
  end
end
