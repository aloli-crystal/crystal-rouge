module Rouge
  module Lexers
    class CSS < RegexLexer
      def self.tag_name : String
        "css"
      end

      def self.title_text : String
        "CSS"
      end

      def self.desc_text : String
        "Cascading Style Sheets"
      end

      def self.file_exts : Array(String)
        ["*.css"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        # :comment
        comment = State.new(:comment)
        comment.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        comment.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        comment.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment] = comment

        # :string_double
        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        # :string_single
        string_single = State.new(:string_single)
        string_single.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_single.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        string_single.add_rule Rule.new(/[^'\\]+/, Tokens::StrSingle)
        states[:string_single] = string_single

        # :value — property values after the colon
        value = State.new(:value)
        value.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        value.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment)
        value.add_rule Rule.new(/!important\b/, Tokens::KeywordPseudo)
        value.add_rule Rule.new(/#[0-9a-fA-F]{3,8}\b/, Tokens::NumHex)
        value.add_rule Rule.new(/-?(?:\d+\.\d+|\.\d+|\d+)(?:px|em|rem|%|vh|vw|vmin|vmax|pt|cm|mm|in|ex|ch|deg|rad|turn|s|ms|Hz|kHz|dpi|dpcm|dppx|fr)\b/, Tokens::NumOther)
        value.add_rule Rule.new(/-?(?:\d+\.\d+|\.\d+)\b/, Tokens::NumFloat)
        value.add_rule Rule.new(/-?\d+\b/, Tokens::NumInteger)
        value.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        value.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)
        value.add_rule Rule.new(/(?:rgb|rgba|hsl|hsla|url|calc|var|linear-gradient|radial-gradient|repeat|minmax)\s*\(/, Tokens::NameBuiltin)
        value.add_rule Rule.new(/[a-zA-Z_][\w-]*/, Tokens::NameOther)
        value.add_rule Rule.new(/[,\/()]/, Tokens::Punctuation)
        value.add_rule Rule.new(/;/, Tokens::Punctuation, pop: true)
        value.add_rule Rule.new(/(?=\})/, Tokens::Text, pop: true)
        states[:value] = value

        # :block — inside { }
        block = State.new(:block)
        block.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        block.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment)
        block.add_rule Rule.new(/([a-zA-Z_-][\w-]*)(\s*:\s*)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::NameProperty, m[1]},
              {Tokens::Punctuation, m[2]},
            ] of TokenPair
          },
          next_state: :value
        )
        block.add_rule Rule.new(/;/, Tokens::Punctuation)
        block.add_rule Rule.new(/\}/, Tokens::Punctuation, pop: true)
        states[:block] = block

        # :selector — selectors before {
        selector = State.new(:selector)
        selector.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        selector.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment)
        selector.add_rule Rule.new(/\.[a-zA-Z_][\w-]*/, Tokens::NameClass)
        selector.add_rule Rule.new(/#[a-zA-Z_][\w-]*/, Tokens::NameFunction)
        selector.add_rule Rule.new(/::?[a-zA-Z_][\w-]*/, Tokens::NameDecorator)
        selector.add_rule Rule.new(/\[[^\]]*\]/, Tokens::NameAttribute)
        selector.add_rule Rule.new(/[a-zA-Z_][\w-]*/, Tokens::NameTag)
        selector.add_rule Rule.new(/[*>+~,]/, Tokens::Operator)
        states[:selector] = selector

        # :root
        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment)
        root.add_rule Rule.new(/@[\w-]+/, Tokens::Keyword)
        root.add_rule Rule.new(/\{/, Tokens::Punctuation, next_state: :block)
        root.add_rule Rule.new(/\}/, Tokens::Punctuation)
        root.add_mixin :selector
        states[:root] = root

        states
      end
    end

    # Register
    RegexLexer.register("css", CSS)
  end
end
