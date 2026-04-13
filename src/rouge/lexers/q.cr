module Rouge
  module Lexers
    class QLang < RegexLexer
      def self.tag_name : String
        "q"
      end

      def self.title_text : String
        "Q"
      end

      def self.desc_text : String
        "Q/KDB+ programming language"
      end

      def self.file_exts : Array(String)
        ["*.q", "*.k"]
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

        # Comments: / at start of line
        root.add_rule Rule.new(/^\/[^\n]*/, Tokens::CommentSingle)
        # End-of-line comments
        root.add_rule Rule.new(/\s+\/[^\n]*/, Tokens::CommentSingle)

        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)

        # Symbols
        root.add_rule Rule.new(/`[a-zA-Z_][\w.]*/, Tokens::StrSymbol)
        root.add_rule Rule.new(/`/, Tokens::StrSymbol)

        root.add_rule Rule.new(/\b(?:if|do|while|select|exec|update|delete|from|where|by|each|over|scan|prior|flip|enlist|til|peach|raze|first|last|count|sum|avg|min|max|prd|med|dev|var|sdev|svar|asc|desc|rank|iasc|idesc|group|ungroup|xgroup|xasc|xdesc|xcol|xcols|key|keys|value|values|type|string|get|set|system|abs|all|any|ceiling|floor|log|exp|sqrt|reciprocal|neg|not|null|distinct)\b/, Tokens::Keyword)

        root.add_rule Rule.new(/\d{4}\.\d{2}\.\d{2}/, Tokens::LiteralDate)
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+[bhijef]?/, Tokens::NumInteger)

        root.add_rule Rule.new(/[+\-*%&|^~=<>!,#_@.\\]+/, Tokens::Operator)
        root.add_rule Rule.new(/[(){};\[\]:]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("q", QLang)
    RegexLexer.register("kdb", QLang)
  end
end
