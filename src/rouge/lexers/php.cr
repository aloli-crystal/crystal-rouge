module Rouge
  module Lexers
    class PHP < RegexLexer
      def self.tag_name : String
        "php"
      end

      def self.title_text : String
        "PHP"
      end

      def self.desc_text : String
        "The PHP scripting language (php.net)"
      end

      def self.file_exts : Array(String)
        ["*.php", "*.php3", "*.php4", "*.php5", "*.phtml"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(
          abstract and as break callable case catch class clone const continue
          declare default do echo else elseif empty enddeclare endfor endforeach
          endif endswitch endwhile enum eval exit extends final finally fn for
          foreach function global goto if implements include include_once
          instanceof insteadof interface isset list match namespace new or print
          private protected public readonly require require_once return static
          switch throw trait try unset use var while xor yield
        )

        constants = %w(true false null TRUE FALSE NULL)
        types = %w(int float string bool array object void never mixed self parent)

        kw_pattern = keywords.join("|")
        const_pattern = constants.join("|")
        type_pattern = types.join("|")

        # :comment_single
        cs = State.new(:comment_single)
        cs.add_rule Rule.new(/[^\n]*/, Tokens::CommentSingle, pop: true)
        states[:comment_single] = cs

        # :comment_multi
        cm = State.new(:comment_multi)
        cm.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        cm.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        cm.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment_multi] = cm

        # :string_double
        sd = State.new(:string_double)
        sd.add_rule Rule.new(/\\./, Tokens::StrEscape)
        sd.add_rule Rule.new(/\$[a-zA-Z_]\w*/, Tokens::NameVariable)
        sd.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        sd.add_rule Rule.new(/[^"\\$]+/, Tokens::StrDouble)
        sd.add_rule Rule.new(/\$/, Tokens::StrDouble)
        states[:string_double] = sd

        # :string_single
        ss = State.new(:string_single)
        ss.add_rule Rule.new(/\\./, Tokens::StrEscape)
        ss.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        ss.add_rule Rule.new(/[^'\\]+/, Tokens::StrSingle)
        states[:string_single] = ss

        # :root
        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)

        # Comments
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multi)
        root.add_rule Rule.new(/\/\//, Tokens::CommentSingle, next_state: :comment_single)
        root.add_rule Rule.new(/#(?!\[)/, Tokens::CommentSingle, next_state: :comment_single)

        # PHP tags
        root.add_rule Rule.new(/<\?php\b/, Tokens::CommentPreproc)
        root.add_rule Rule.new(/\?>/, Tokens::CommentPreproc)

        # Constants
        root.add_rule Rule.new(Regex.new("\\b(?:#{const_pattern})\\b"), Tokens::KeywordConstant)

        # Keywords
        root.add_rule Rule.new(Regex.new("\\b(?:#{kw_pattern})\\b"), Tokens::Keyword)

        # Types
        root.add_rule Rule.new(Regex.new("\\b(?:#{type_pattern})\\b"), Tokens::KeywordType)

        # Variables
        root.add_rule Rule.new(/\$[a-zA-Z_]\w*/, Tokens::NameVariable)

        # Numbers
        root.add_rule Rule.new(/0[xX][0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/0[bB][01]+/, Tokens::NumBin)
        root.add_rule Rule.new(/0[0-7]+/, Tokens::NumOct)
        root.add_rule Rule.new(/\d+\.\d*(?:[eE][+-]?\d+)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\.\d+(?:[eE][+-]?\d+)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+[eE][+-]?\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        # Strings
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)

        # Operators
        root.add_rule Rule.new(/=>|->|&&|\|\||<<=?|>>=?|\*\*|\.{3}|\?\?|[+\-*\/%&|^~!=<>.]=?|\?|:/, Tokens::Operator)

        # Punctuation
        root.add_rule Rule.new(/[{}()\[\];,]/, Tokens::Punctuation)

        # Function names
        root.add_rule Rule.new(/[a-zA-Z_]\w*(?=\s*\()/, Tokens::NameFunction)

        # Constants (ALL_CAPS)
        root.add_rule Rule.new(/[A-Z][A-Z_0-9]*\b/, Tokens::NameConstant)

        # Identifiers
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)

        states[:root] = root

        states
      end
    end

    RegexLexer.register("php", PHP)
  end
end
