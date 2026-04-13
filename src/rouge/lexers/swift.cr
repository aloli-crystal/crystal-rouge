module Rouge
  module Lexers
    class Swift < RegexLexer
      def self.tag_name : String
        "swift"
      end

      def self.title_text : String
        "Swift"
      end

      def self.desc_text : String
        "The Swift programming language (swift.org)"
      end

      def self.file_exts : Array(String)
        ["*.swift"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(
          associatedtype break case catch class continue convenience default defer
          deinit do else enum extension fallthrough fileprivate final for func guard
          if import in indirect infix init inout internal is lazy let mutating
          nonmutating open operator optional override postfix prefix private protocol
          public repeat required rethrows return self some static struct subscript
          super switch throw throws try typealias unowned var weak where while
          async await actor
        )

        types = %w(
          Int Int8 Int16 Int32 Int64 UInt UInt8 UInt16 UInt32 UInt64
          Float Double Bool String Character Array Dictionary Set Optional
          Result Error Any AnyObject Void Never Codable Equatable Hashable
          Comparable CustomStringConvertible
        )

        constants = %w(true false nil)

        kw_pattern = keywords.join("|")
        type_pattern = types.join("|")
        const_pattern = constants.join("|")

        # :comment_single
        cs = State.new(:comment_single)
        cs.add_rule Rule.new(/[^\n]*/, Tokens::CommentSingle, pop: true)
        states[:comment_single] = cs

        # :comment_multi
        cm = State.new(:comment_multi)
        cm.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        cm.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        cm.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment_multi] = cm

        # :string_double
        sd = State.new(:string_double)
        sd.add_rule Rule.new(/\\\(/, Tokens::StrInterpol, next_state: :string_interp)
        sd.add_rule Rule.new(/\\./, Tokens::StrEscape)
        sd.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        sd.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        states[:string_double] = sd

        # :string_interp
        si = State.new(:string_interp)
        si.add_rule Rule.new(/[^)]+/, Tokens::StrInterpol)
        si.add_rule Rule.new(/\)/, Tokens::StrInterpol, pop: true)
        states[:string_interp] = si

        # :root
        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/\//, Tokens::CommentSingle, next_state: :comment_single)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multi)

        # Self with capital S
        root.add_rule Rule.new(/\bSelf\b/, Tokens::Keyword)
        root.add_rule Rule.new(Regex.new("\\b(?:#{kw_pattern})\\b"), Tokens::Keyword)
        root.add_rule Rule.new(Regex.new("\\b(?:#{type_pattern})\\b"), Tokens::KeywordType)
        root.add_rule Rule.new(Regex.new("\\b(?:#{const_pattern})\\b"), Tokens::KeywordConstant)

        # Numbers
        root.add_rule Rule.new(/0[xX][0-9a-fA-F_]+/, Tokens::NumHex)
        root.add_rule Rule.new(/0[bB][01_]+/, Tokens::NumBin)
        root.add_rule Rule.new(/0[oO][0-7_]+/, Tokens::NumOct)
        root.add_rule Rule.new(/\d[\d_]*\.\d[\d_]*(?:[eE][+-]?\d[\d_]*)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d[\d_]*/, Tokens::NumInteger)

        # Strings
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)

        # Operators
        root.add_rule Rule.new(/[+\-*\/%&|^~!=<>?]+/, Tokens::Operator)

        # Punctuation
        root.add_rule Rule.new(/[{}()\[\];,.:@#]/, Tokens::Punctuation)

        # Method / function names
        root.add_rule Rule.new(/[a-zA-Z_]\w*(?=\s*\()/, Tokens::NameFunction)

        # Identifiers
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)

        states[:root] = root

        states
      end
    end

    RegexLexer.register("swift", Swift)
  end
end
