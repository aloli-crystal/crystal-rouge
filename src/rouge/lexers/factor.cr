module Rouge
  module Lexers
    class Factor < RegexLexer
      def self.tag_name : String
        "factor"
      end

      def self.title_text : String
        "Factor"
      end

      def self.desc_text : String
        "The Factor programming language (factorcode.org)"
      end

      def self.file_exts : Array(String)
        ["*.factor"]
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

        # :root
        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/![^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/\b(?:USING:|IN:|TUPLE:|GENERIC:|MIXIN:|INSTANCE:|SLOT:|SINGLETON:|SPECIALIZED-ARRAY:|SYMBOL:|POSTPONE:|CONSTANT:|DEFER:|ALIAS:|PREDICATE:|M:)\s/, Tokens::Keyword)
        root.add_rule Rule.new(/\b(?:t|f)\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/[:;]/, Tokens::Keyword)
        root.add_rule Rule.new(/\b(?:if|unless|when|cond|case|dup|drop|swap|over|rot|nip|tuck|pick|bi|tri|each|map|filter|reduce|curry|compose|dip|keep|call|execute)\b/, Tokens::NameBuiltin)
        root.add_rule Rule.new(/-?\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/-?\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[{}()\[\]]+/, Tokens::Punctuation)
        root.add_rule Rule.new(/\S+/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("factor", Factor)
  end
end
