module Rouge
  module Lexers
    class Fish < RegexLexer
      def self.tag_name : String
        "fish"
      end

      def self.title_text : String
        "Fish"
      end

      def self.desc_text : String
        "Fish shell (fishshell.com)"
      end

      def self.file_exts : Array(String)
        ["*.fish"]
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
        sd.add_rule Rule.new(/\$[a-zA-Z_]\w*/, Tokens::NameVariable)
        sd.add_rule Rule.new(/[^"\\$]+/, Tokens::StrDouble)
        sd.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        states[:string_double] = sd

        # :string_single
        ss = State.new(:string_single)
        ss.add_rule Rule.new(/[^']+/, Tokens::StrSingle)
        ss.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        states[:string_single] = ss

        # :root
        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/#[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)

        root.add_rule Rule.new(/\$[a-zA-Z_]\w*/, Tokens::NameVariable)
        root.add_rule Rule.new(/\b(?:if|else|end|for|in|while|switch|case|function|return|begin|break|continue|and|or|not|set|builtin|command|emit|status|test|true|false|count|math|string|contains|type|source|eval|exec|read|echo|printf|argparse)\b/, Tokens::Keyword)

        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        root.add_rule Rule.new(/[|&;><]+/, Tokens::Operator)
        root.add_rule Rule.new(/[()]+/, Tokens::Punctuation)
        root.add_rule Rule.new(/[^\s"'$#|&;><()]+/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("fish", Fish)
  end
end
