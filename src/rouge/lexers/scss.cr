module Rouge
  module Lexers
    class SCSS < RegexLexer
      def self.tag_name : String
        "scss"
      end

      def self.title_text : String
        "SCSS"
      end

      def self.desc_text : String
        "SCSS (Sassy CSS)"
      end

      def self.file_exts : Array(String)
        ["*.scss", "*.sass"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        # :whitespace
        ws = State.new(:whitespace)
        ws.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        states[:whitespace] = ws

        # :comment_multiline
        comment_ml = State.new(:comment_multiline)
        comment_ml.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        comment_ml.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        comment_ml.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment_multiline] = comment_ml

        # :string_double
        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_double.add_rule Rule.new(/#\{/, Tokens::StrInterpol, next_state: :interpolation)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\#]+/, Tokens::StrDouble)
        string_double.add_rule Rule.new(/#/, Tokens::StrDouble)
        states[:string_double] = string_double

        # :string_single
        string_single = State.new(:string_single)
        string_single.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_single.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        string_single.add_rule Rule.new(/[^'\\]+/, Tokens::StrSingle)
        states[:string_single] = string_single

        # :interpolation
        interpolation = State.new(:interpolation)
        interpolation.add_rule Rule.new(/\}/, Tokens::StrInterpol, pop: true)
        interpolation.add_rule Rule.new(/[^}]+/, Tokens::Name)
        states[:interpolation] = interpolation

        # :value
        value = State.new(:value)
        value.add_mixin :whitespace
        value.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_ml)
        value.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        value.add_rule Rule.new(/!important\b/, Tokens::KeywordPseudo)
        value.add_rule Rule.new(/#\{/, Tokens::StrInterpol, next_state: :interpolation)
        value.add_rule Rule.new(/#[0-9a-fA-F]{3,8}\b/, Tokens::NumHex)
        value.add_rule Rule.new(/-?(?:\d+\.\d+|\.\d+|\d+)(?:px|em|rem|%|vh|vw|vmin|vmax|pt|cm|mm|in|ex|ch|deg|rad|turn|s|ms|Hz|kHz|dpi|dpcm|dppx|fr)\b/, Tokens::NumOther)
        value.add_rule Rule.new(/-?(?:\d+\.\d+|\.\d+)\b/, Tokens::NumFloat)
        value.add_rule Rule.new(/-?\d+\b/, Tokens::NumInteger)
        value.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        value.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)
        value.add_rule Rule.new(/\$[a-zA-Z_][\w-]*/, Tokens::NameVariable)
        value.add_rule Rule.new(/(?:rgb|rgba|hsl|hsla|url|calc|var|linear-gradient|radial-gradient|repeat|minmax|if|nth|map-get|map-merge|lighten|darken|mix|percentage|round|ceil|floor|abs|min|max|unquote|quote|type-of|unit|unitless|comparable|append|join|length|nth|index|zip|list-separator)\s*\(/, Tokens::NameBuiltin)
        value.add_rule Rule.new(/[a-zA-Z_][\w-]*/, Tokens::NameOther)
        value.add_rule Rule.new(/[,\/()]/, Tokens::Punctuation)
        value.add_rule Rule.new(/;/, Tokens::Punctuation, pop: true)
        value.add_rule Rule.new(/(?=\})/, Tokens::Text, pop: true)
        states[:value] = value

        # :block
        block = State.new(:block)
        block.add_mixin :whitespace
        block.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        block.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multiline)
        # SCSS directives inside blocks
        block.add_rule Rule.new(/@(?:include|extend|if|else|for|each|while|return|at-root|error|warn|debug|content)\b/, Tokens::Keyword)
        # Property: value
        block.add_rule Rule.new(/([a-zA-Z_-][\w-]*)(\s*:\s*)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::NameProperty, m[1]},
              {Tokens::Punctuation, m[2]},
            ] of TokenPair
          },
          next_state: :value
        )
        # Variables
        block.add_rule Rule.new(/\$[a-zA-Z_][\w-]*/, Tokens::NameVariable)
        # Parent selector
        block.add_rule Rule.new(/&/, Tokens::Operator)
        # Nested selectors
        block.add_rule Rule.new(/\.[a-zA-Z_][\w-]*/, Tokens::NameClass)
        block.add_rule Rule.new(/#[a-zA-Z_][\w-]*/, Tokens::NameFunction)
        block.add_rule Rule.new(/::?[a-zA-Z_][\w-]*/, Tokens::NameDecorator)
        block.add_rule Rule.new(/[a-zA-Z_][\w-]*/, Tokens::NameTag)
        block.add_rule Rule.new(/\{/, Tokens::Punctuation, next_state: :block)
        block.add_rule Rule.new(/;/, Tokens::Punctuation)
        block.add_rule Rule.new(/\}/, Tokens::Punctuation, pop: true)
        block.add_rule Rule.new(/#\{/, Tokens::StrInterpol, next_state: :interpolation)
        states[:block] = block

        # :selector
        selector = State.new(:selector)
        selector.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        selector.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        selector.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multiline)
        selector.add_rule Rule.new(/\.[a-zA-Z_][\w-]*/, Tokens::NameClass)
        selector.add_rule Rule.new(/#[a-zA-Z_][\w-]*/, Tokens::NameFunction)
        selector.add_rule Rule.new(/::?[a-zA-Z_][\w-]*/, Tokens::NameDecorator)
        selector.add_rule Rule.new(/\[[^\]]*\]/, Tokens::NameAttribute)
        selector.add_rule Rule.new(/&/, Tokens::Operator)
        selector.add_rule Rule.new(/[a-zA-Z_][\w-]*/, Tokens::NameTag)
        selector.add_rule Rule.new(/[*>+~,]/, Tokens::Operator)
        selector.add_rule Rule.new(/#\{/, Tokens::StrInterpol, next_state: :interpolation)
        states[:selector] = selector

        # :root
        root = State.new(:root)
        root.add_mixin :whitespace
        root.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multiline)
        # SCSS-specific at-rules
        root.add_rule Rule.new(/@(?:mixin|include|extend|import|use|forward|function|return|if|else|for|each|while|at-root|error|warn|debug)\b/, Tokens::Keyword)
        # Generic at-rules
        root.add_rule Rule.new(/@[\w-]+/, Tokens::Keyword)
        # Variables
        root.add_rule Rule.new(/\$[a-zA-Z_][\w-]*/, Tokens::NameVariable)
        root.add_rule Rule.new(/\{/, Tokens::Punctuation, next_state: :block)
        root.add_rule Rule.new(/\}/, Tokens::Punctuation)
        root.add_rule Rule.new(/;/, Tokens::Punctuation)
        root.add_mixin :selector
        states[:root] = root

        states
      end
    end

    RegexLexer.register("scss", SCSS)
    RegexLexer.register("sass", SCSS)
  end
end
