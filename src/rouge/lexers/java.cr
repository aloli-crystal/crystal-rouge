module Rouge
  module Lexers
    class Java < RegexLexer
      def self.tag_name : String
        "java"
      end

      def self.title_text : String
        "Java"
      end

      def self.desc_text : String
        "The Java programming language (java.com)"
      end

      def self.file_exts : Array(String)
        ["*.java"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(
          abstract assert break case catch class const continue default do else
          enum extends final finally for goto if implements import instanceof
          interface native new package private protected public return static
          strictfp super switch synchronized this throw throws transient try
          volatile while yield var record sealed permits non-sealed
        )

        types = %w(
          boolean byte char double float int long short void
          String Integer Double Float Boolean Long Short Byte Character
          Object Class System Math Arrays Collections List Map Set
          HashMap ArrayList Optional Stream Exception RuntimeException
          Thread Runnable
        )

        constants = %w(true false null)

        kw_pattern = keywords.join("|")
        type_pattern = types.join("|")
        const_pattern = constants.join("|")

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

        # :comment_doc
        cd = State.new(:comment_doc)
        cd.add_rule Rule.new(/[^*]+/, Tokens::CommentDoc)
        cd.add_rule Rule.new(/\*\//, Tokens::CommentDoc, pop: true)
        cd.add_rule Rule.new(/\*/, Tokens::CommentDoc)
        states[:comment_doc] = cd

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

        # Comments
        root.add_rule Rule.new(/\/\*\*/, Tokens::CommentDoc, next_state: :comment_doc)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multi)
        root.add_rule Rule.new(/\/\//, Tokens::CommentSingle, next_state: :comment_single)

        # Annotations
        root.add_rule Rule.new(/@[a-zA-Z_]\w*/, Tokens::NameDecorator)

        # Constants
        root.add_rule Rule.new(Regex.new("\\b(?:#{const_pattern})\\b"), Tokens::KeywordConstant)

        # Keywords
        root.add_rule Rule.new(Regex.new("\\b(?:#{kw_pattern})\\b"), Tokens::Keyword)

        # Types
        root.add_rule Rule.new(Regex.new("\\b(?:#{type_pattern})\\b"), Tokens::KeywordType)

        # Numbers
        root.add_rule Rule.new(/0[xX][0-9a-fA-F]+[lL]?/, Tokens::NumHex)
        root.add_rule Rule.new(/0[bB][01]+[lL]?/, Tokens::NumBin)
        root.add_rule Rule.new(/0[0-7]+[lL]?/, Tokens::NumOct)
        root.add_rule Rule.new(/\d+\.\d*(?:[eE][+-]?\d+)?[fFdD]?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\.\d+(?:[eE][+-]?\d+)?[fFdD]?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+[eE][+-]?\d+[fFdD]?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+[fFdD]/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+[lL]/, Tokens::NumIntegerLong)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        # Strings and chars
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'/, Tokens::StrChar, next_state: :char)

        # Operators
        root.add_rule Rule.new(/->|&&|\|\||<<=?|>>=?|>>>=?|[+\-*\/%&|^~!=<>]=?|\?|:/, Tokens::Operator)

        # Punctuation
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)

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

    RegexLexer.register("java", Java)
  end
end
