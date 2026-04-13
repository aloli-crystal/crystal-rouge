module Rouge
  module Lexers
    class ReasonML < RegexLexer
      def self.tag_name : String
        "reasonml"
      end

      def self.title_text : String
        "ReasonML"
      end

      def self.desc_text : String
        "ReasonML programming language"
      end

      def self.file_exts : Array(String)
        ["*.re", "*.rei"]
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
        cm.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        cm.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        cm.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment_multi] = cm

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multi)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'[^'\\]'|'\\.'/, Tokens::StrChar)

        root.add_rule Rule.new(/\b(?:true|false)\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\b(?:int|float|string|char|bool|unit|list|array|option|ref)\b/, Tokens::KeywordType)
        root.add_rule Rule.new(/\b(?:and|as|assert|begin|class|constraint|do|done|downto|else|end|exception|external|for|fun|function|functor|if|in|include|inherit|initializer|land|lazy|let|lor|lsl|lsr|lxor|match|method|mod|module|mutable|new|nonrec|object|of|open|or|pri|pub|rec|ref|sig|struct|switch|then|to|try|type|val|virtual|when|while|with)\b/, Tokens::Keyword)

        # JSX
        root.add_rule Rule.new(/<\/[a-zA-Z_][\w.]*>/, Tokens::NameTag)
        root.add_rule Rule.new(/<[a-zA-Z_][\w.]*/, Tokens::NameTag)

        root.add_rule Rule.new(/=>|->|\|>/, Tokens::Operator)
        root.add_rule Rule.new(/0[xX][0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        root.add_rule Rule.new(/[+\-*\/<>=!&|^~@#%]+/, Tokens::Operator)
        root.add_rule Rule.new(/[(){};\[\],:.?]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("reasonml", ReasonML)
    RegexLexer.register("re", ReasonML)
    RegexLexer.register("reason", ReasonML)
  end
end
