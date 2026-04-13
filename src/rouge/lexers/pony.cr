module Rouge
  module Lexers
    class Pony < RegexLexer
      def self.tag_name : String
        "pony"
      end

      def self.title_text : String
        "Pony"
      end

      def self.desc_text : String
        "The Pony programming language (ponylang.io)"
      end

      def self.file_exts : Array(String)
        ["*.pony"]
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

        # :comment_multi
        cm = State.new(:comment_multi)
        cm.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        cm.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        cm.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment_multi] = cm

        # :root
        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multi)
        root.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)

        root.add_rule Rule.new(/\b(?:true|false|None)\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\b(?:iso|trn|ref|val|box|tag)\b/, Tokens::KeywordType)
        root.add_rule Rule.new(/\b(?:actor|be|break|class|compile_error|compile_intrinsic|consume|continue|do|else|elseif|embed|end|error|for|fun|if|ifdef|in|interface|is|isnt|let|match|new|object|primitive|recover|repeat|return|struct|then|this|trait|try|type|until|use|var|where|while|with)\b/, Tokens::Keyword)

        root.add_rule Rule.new(/\d+\.\d+(?:[eE][+-]?\d+)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/0[xX][0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/0[bB][01]+/, Tokens::NumBin)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        root.add_rule Rule.new(/[+\-*\/%<>=!&|^~?]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,:.]+/, Tokens::Punctuation)
        root.add_rule Rule.new(/[A-Z]\w*/, Tokens::NameClass)
        root.add_rule Rule.new(/[a-z_]\w*/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("pony", Pony)
  end
end
