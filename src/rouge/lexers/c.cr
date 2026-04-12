module Rouge
  module Lexers
    class C < RegexLexer
      def self.tag_name : String
        "c"
      end

      def self.title_text : String
        "C"
      end

      def self.desc_text : String
        "The C programming language"
      end

      def self.file_exts : Array(String)
        ["*.c", "*.h"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(
          auto break case const continue default do else enum extern for goto
          if inline register restrict return sizeof static struct switch typedef
          union volatile while _Bool _Complex _Imaginary
        )

        types = %w(
          int char float double void long short unsigned signed
          size_t int8_t int16_t int32_t int64_t uint8_t uint16_t uint32_t uint64_t
          bool FILE
        )

        kw_pattern = keywords.join("|")
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
        sd.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        sd.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string_double] = sd

        # :char
        ch = State.new(:char)
        ch.add_rule Rule.new(/\\./, Tokens::StrEscape)
        ch.add_rule Rule.new(/'/, Tokens::StrChar, pop: true)
        ch.add_rule Rule.new(/[^'\\]+/, Tokens::StrChar)
        states[:char] = ch

        # :root
        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)

        # Preprocessor
        root.add_rule Rule.new(
          /(#\s*(?:include|import))(\s+)(<[^>]+>)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::CommentPreproc, m[1]},
              {Tokens::TextWhitespace, m[2]},
              {Tokens::CommentPreprocFile, m[3]},
            ] of TokenPair
          }
        )
        root.add_rule Rule.new(
          /(#\s*(?:include|import))(\s+)("[^"]+")/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::CommentPreproc, m[1]},
              {Tokens::TextWhitespace, m[2]},
              {Tokens::CommentPreprocFile, m[3]},
            ] of TokenPair
          }
        )
        root.add_rule Rule.new(/#\s*(?:define|ifdef|ifndef|endif|if|else|elif|pragma|error|warning|undef|line)\b.*$/, Tokens::CommentPreproc)

        # Comments
        root.add_rule Rule.new(/\/\//, Tokens::CommentSingle, next_state: :comment_single)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multi)

        # Constants
        root.add_rule Rule.new(/\bNULL\b/, Tokens::KeywordConstant)

        root.add_rule Rule.new(Regex.new("\\b(?:#{kw_pattern})\\b"), Tokens::Keyword)
        root.add_rule Rule.new(Regex.new("\\b(?:#{type_pattern})\\b"), Tokens::KeywordType)

        # Numbers
        root.add_rule Rule.new(/0[xX][0-9a-fA-F]+[uUlL]*/, Tokens::NumHex)
        root.add_rule Rule.new(/0[bB][01]+[uUlL]*/, Tokens::NumBin)
        root.add_rule Rule.new(/0[0-7]+[uUlL]*/, Tokens::NumOct)
        root.add_rule Rule.new(/\d+\.\d*(?:[eE][+-]?\d+)?[fFlL]?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\.\d+(?:[eE][+-]?\d+)?[fFlL]?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+[eE][+-]?\d+[fFlL]?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+[uUlL]*/, Tokens::NumInteger)

        # Strings and chars
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'/, Tokens::StrChar, next_state: :char)

        # Operators
        root.add_rule Rule.new(/->|&&|\|\||<<=?|>>=?|[+\-*\/%&|^~!=<>]=?|\?|:/, Tokens::Operator)

        # Punctuation
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)

        # Function names
        root.add_rule Rule.new(/[a-zA-Z_]\w*(?=\s*\()/, Tokens::NameFunction)

        # Identifiers
        root.add_rule Rule.new(/[A-Z][A-Z_0-9]*\b/, Tokens::NameConstant)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)

        states[:root] = root

        states
      end
    end

    RegexLexer.register("c", C)
  end
end
