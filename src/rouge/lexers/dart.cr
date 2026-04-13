module Rouge
  module Lexers
    class Dart < RegexLexer
      def self.tag_name : String
        "dart"
      end

      def self.title_text : String
        "Dart"
      end

      def self.desc_text : String
        "The Dart programming language (dart.dev)"
      end

      def self.file_exts : Array(String)
        ["*.dart"]
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

        # :string_double
        sd = State.new(:string_double)
        sd.add_rule Rule.new(/\$\{[^}]*\}/, Tokens::StrInterpol)
        sd.add_rule Rule.new(/\$[a-zA-Z_]\w*/, Tokens::StrInterpol)
        sd.add_rule Rule.new(/\\./, Tokens::StrEscape)
        sd.add_rule Rule.new(/[^"\\$]+/, Tokens::StrDouble)
        sd.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        states[:string_double] = sd

        # :string_single
        ss = State.new(:string_single)
        ss.add_rule Rule.new(/\$\{[^}]*\}/, Tokens::StrInterpol)
        ss.add_rule Rule.new(/\$[a-zA-Z_]\w*/, Tokens::StrInterpol)
        ss.add_rule Rule.new(/\\./, Tokens::StrEscape)
        ss.add_rule Rule.new(/[^'\\$]+/, Tokens::StrSingle)
        ss.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        states[:string_single] = ss

        # :string_triple_double
        std = State.new(:string_triple_double)
        std.add_rule Rule.new(/"""/, Tokens::StrDouble, pop: true)
        std.add_rule Rule.new(/\$\{[^}]*\}/, Tokens::StrInterpol)
        std.add_rule Rule.new(/\$[a-zA-Z_]\w*/, Tokens::StrInterpol)
        std.add_rule Rule.new(/\\./, Tokens::StrEscape)
        std.add_rule Rule.new(/[^"\\$]+/, Tokens::StrDouble)
        std.add_rule Rule.new(/"/, Tokens::StrDouble)
        states[:string_triple_double] = std

        # :string_triple_single
        sts = State.new(:string_triple_single)
        sts.add_rule Rule.new(/'''/, Tokens::StrSingle, pop: true)
        sts.add_rule Rule.new(/\$\{[^}]*\}/, Tokens::StrInterpol)
        sts.add_rule Rule.new(/\$[a-zA-Z_]\w*/, Tokens::StrInterpol)
        sts.add_rule Rule.new(/\\./, Tokens::StrEscape)
        sts.add_rule Rule.new(/[^'\\$]+/, Tokens::StrSingle)
        sts.add_rule Rule.new(/'/, Tokens::StrSingle)
        states[:string_triple_single] = sts

        # :comment_block
        cb = State.new(:comment_block)
        cb.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        cb.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        cb.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment_block] = cb

        # :root
        root = State.new(:root)
        root.add_mixin :whitespace

        # Comments
        root.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_block)

        # Annotations
        root.add_rule Rule.new(/@[a-zA-Z_]\w*/, Tokens::NameDecorator)

        # Triple-quoted strings (before regular strings)
        root.add_rule Rule.new(/r"""[\s\S]*?"""/, Tokens::StrDouble)
        root.add_rule Rule.new(/r'''[\s\S]*?'''/, Tokens::StrSingle)
        root.add_rule Rule.new(/"""/, Tokens::StrDouble, next_state: :string_triple_double)
        root.add_rule Rule.new(/'''/, Tokens::StrSingle, next_state: :string_triple_single)

        # Raw strings
        root.add_rule Rule.new(/r"[^"]*"/, Tokens::StrDouble)
        root.add_rule Rule.new(/r'[^']*'/, Tokens::StrSingle)

        # Regular strings
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)

        # Constants
        root.add_rule Rule.new(/\b(?:true|false|null)\b/, Tokens::KeywordConstant)

        # Types
        root.add_rule Rule.new(/\b(?:int|double|num|bool|String|List|Map|Set|Future|Stream|Iterable|Iterator|Object|dynamic|void|Never|Null|Type|Symbol|Function|Record|BigInt|Duration|DateTime|Uri|RegExp)\b/, Tokens::KeywordType)

        # Keywords
        root.add_rule Rule.new(/\b(?:abstract|as|assert|async|await|base|break|case|catch|class|const|continue|covariant|default|deferred|do|dynamic|else|enum|export|extends|extension|external|factory|final|finally|for|get|hide|if|implements|import|in|interface|is|late|library|mixin|new|on|operator|part|required|rethrow|return|sealed|set|show|static|super|switch|sync|this|throw|try|typedef|var|void|when|while|with|yield)\b/, Tokens::Keyword)

        # Numbers
        root.add_rule Rule.new(/0[xX][0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/\d+\.\d+(?:[eE][+-]?\d+)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+[eE][+-]?\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        # Cascade operator
        root.add_rule Rule.new(/\.\./, Tokens::Operator)

        # Operators
        root.add_rule Rule.new(/[!%&*+\-\/<=>?|^~]+/, Tokens::Operator)

        # Identifiers
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)

        # Punctuation
        root.add_rule Rule.new(/[(){}\[\],.;:@#]/, Tokens::Punctuation)

        states[:root] = root

        states
      end
    end

    RegexLexer.register("dart", Dart)
  end
end
