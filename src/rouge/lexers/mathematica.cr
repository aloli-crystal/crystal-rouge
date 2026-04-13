module Rouge
  module Lexers
    class Mathematica < RegexLexer
      def self.tag_name : String
        "mathematica"
      end

      def self.title_text : String
        "Mathematica"
      end

      def self.desc_text : String
        "Wolfram Language / Mathematica"
      end

      def self.file_exts : Array(String)
        ["*.nb", "*.wl", "*.m"]
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

        cm = State.new(:comment_multi)
        cm.add_rule Rule.new(/\*\)/, Tokens::CommentMultiline, pop: true)
        cm.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        cm.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment_multi] = cm

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\(\*/, Tokens::CommentMultiline, next_state: :comment_multi)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)

        root.add_rule Rule.new(/\b(?:True|False|Null|None|All|Infinity)\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\b(?:Module|Block|With|If|Which|Switch|Do|For|While|Return|Break|Continue|Throw|Catch|Function|Map|Apply|Table|Sum|Product|Integrate|Solve|Plot|Print)\b/, Tokens::Keyword)

        # Slots
        root.add_rule Rule.new(/##?\d*/, Tokens::NameBuiltin)

        # Patterns
        root.add_rule Rule.new(/[a-zA-Z$]\w*_+/, Tokens::NameVariable)

        # Numbers
        root.add_rule Rule.new(/\d+\.\d*(?:\*\^[+-]?\d+)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+(?:\*\^[+-]?\d+)?/, Tokens::NumInteger)

        # Special operators
        root.add_rule Rule.new(/::/, Tokens::Operator)
        root.add_rule Rule.new(/->|:>/, Tokens::Operator)
        root.add_rule Rule.new(/\/\.|\/\/\./, Tokens::Operator)
        root.add_rule Rule.new(/@@?/, Tokens::Operator)
        root.add_rule Rule.new(/&/, Tokens::Operator)

        root.add_rule Rule.new(/[+\-*\/^=<>!~|]+/, Tokens::Operator)
        root.add_rule Rule.new(/[(){};\[\],]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z$]\w*/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("mathematica", Mathematica)
    RegexLexer.register("wolfram", Mathematica)
    RegexLexer.register("mma", Mathematica)
    RegexLexer.register("nb", Mathematica)
  end
end
