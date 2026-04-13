module Rouge
  module Lexers
    class Praat < RegexLexer
      def self.tag_name : String
        "praat"
      end

      def self.title_text : String
        "Praat"
      end

      def self.desc_text : String
        "Praat scripting language"
      end

      def self.file_exts : Array(String)
        ["*.praat", "*.psc"]
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
        root.add_rule Rule.new(/#[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/;[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)

        root.add_rule Rule.new(/\b(?:if|then|else|elsif|elif|endif|fi|for|from|to|endfor|while|endwhile|repeat|until|procedure|endproc|call|select|plus|minus|echo|print|printline|appendFile|appendFileLine|writeFile|writeFileLine|pause|exit|form|endform|comment|natural|real|integer|word|sentence|text|boolean|choice|optionMenu|option|do|writeInfoLine|appendInfoLine|beginPause|endPause|clicked|editor|endeditor|nocheck|assert|asserterror)\b/, Tokens::Keyword)

        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        root.add_rule Rule.new(/[+\-*\/<>=!^]+/, Tokens::Operator)
        root.add_rule Rule.new(/[(){};\[\],:]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_]\w*\$?/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("praat", Praat)
  end
end
