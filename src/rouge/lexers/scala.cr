module Rouge
  module Lexers
    class Scala < RegexLexer
      def self.tag_name : String
        "scala"
      end

      def self.title_text : String
        "Scala"
      end

      def self.desc_text : String
        "The Scala programming language (scala-lang.org)"
      end

      def self.file_exts : Array(String)
        ["*.scala", "*.sc"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(
          abstract case catch class def do else extends final finally for forSome
          if implicit import lazy macro match new object override package private
          protected return sealed super this throw trait try type val var while
          with yield given using enum export then
        )

        types = %w(
          Int Long Short Byte Float Double Boolean Char String Unit Nothing Any
          AnyRef AnyVal Null Option Some None List Map Set Seq Vector Array
          Future Either Left Right Try Success Failure BigInt BigDecimal
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
        cm.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        cm.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        cm.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment_multi] = cm

        # :string_double
        sd = State.new(:string_double)
        sd.add_rule Rule.new(/\\./, Tokens::StrEscape)
        sd.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        sd.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        states[:string_double] = sd

        # :string_triple
        st = State.new(:string_triple)
        st.add_rule Rule.new(/"""/, Tokens::StrDouble, pop: true)
        st.add_rule Rule.new(/[^"]+/, Tokens::StrDouble)
        st.add_rule Rule.new(/"/, Tokens::StrDouble)
        states[:string_triple] = st

        # :string_interp (for s"..." and f"...")
        sip = State.new(:string_interp)
        sip.add_rule Rule.new(/\$\{/, Tokens::StrInterpol, next_state: :interp_brace)
        sip.add_rule Rule.new(/\$[a-zA-Z_]\w*/, Tokens::StrInterpol)
        sip.add_rule Rule.new(/\\./, Tokens::StrEscape)
        sip.add_rule Rule.new(/[^"\\$]+/, Tokens::StrDouble)
        sip.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        states[:string_interp] = sip

        # :interp_brace
        ib = State.new(:interp_brace)
        ib.add_rule Rule.new(/[^}]+/, Tokens::StrInterpol)
        ib.add_rule Rule.new(/\}/, Tokens::StrInterpol, pop: true)
        states[:interp_brace] = ib

        # :root
        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/\//, Tokens::CommentSingle, next_state: :comment_single)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multi)

        root.add_rule Rule.new(Regex.new("\\b(?:#{kw_pattern})\\b"), Tokens::Keyword)
        root.add_rule Rule.new(Regex.new("\\b(?:#{type_pattern})\\b"), Tokens::KeywordType)
        root.add_rule Rule.new(Regex.new("\\b(?:#{const_pattern})\\b"), Tokens::KeywordConstant)

        # Annotations
        root.add_rule Rule.new(/@[a-zA-Z_]\w*/, Tokens::NameDecorator)

        # Numbers
        root.add_rule Rule.new(/0[xX][0-9a-fA-F_]+[lL]?/, Tokens::NumHex)
        root.add_rule Rule.new(/\d[\d_]*\.\d[\d_]*(?:[eE][+-]?\d[\d_]*)?[fFdD]?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d[\d_]*[lL]/, Tokens::NumIntegerLong)
        root.add_rule Rule.new(/\d[\d_]*/, Tokens::NumInteger)

        # Triple-quoted strings
        root.add_rule Rule.new(/"""/, Tokens::StrDouble, next_state: :string_triple)

        # Interpolated strings
        root.add_rule Rule.new(/[sf]"/, Tokens::StrDouble, next_state: :string_interp)

        # Regular strings
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)

        # Character literals
        root.add_rule Rule.new(/'\\.'/, Tokens::StrChar)
        root.add_rule Rule.new(/'[^\\]'/, Tokens::StrChar)

        # Symbols
        root.add_rule Rule.new(/'[a-zA-Z_]\w*/, Tokens::StrSymbol)

        # Operators
        root.add_rule Rule.new(/=>|<-|->|[+\-*\/%&|^~!=<>:]+/, Tokens::Operator)

        # Punctuation
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)

        # Class / type names
        root.add_rule Rule.new(/[A-Z]\w*/, Tokens::NameClass)

        # Function names
        root.add_rule Rule.new(/[a-zA-Z_]\w*(?=\s*[\[(])/, Tokens::NameFunction)

        # Identifiers
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)

        states[:root] = root

        states
      end
    end

    RegexLexer.register("scala", Scala)
  end
end
