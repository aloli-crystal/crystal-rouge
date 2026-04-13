module Rouge
  module Lexers
    class Eiffel < RegexLexer
      def self.tag_name : String
        "eiffel"
      end

      def self.title_text : String
        "Eiffel"
      end

      def self.desc_text : String
        "Eiffel programming language"
      end

      def self.file_exts : Array(String)
        ["*.e"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(
          across agent alias all and as assign attribute check class convert
          create current debug deferred do else elseif end ensure expanded export
          external feature from frozen if implies indexing inherit inspect
          invariant is like local loop not note obsolete old once only or
          precursor redefine rename require rescue result retry select separate
          some then undefine until variant void when xor
        )

        kw_pattern = keywords.join("|")

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/--.*/, Tokens::CommentSingle)
        root.add_rule Rule.new(Regex.new("\\b(?:#{kw_pattern})\\b", Regex::Options::IGNORE_CASE), Tokens::Keyword)
        root.add_rule Rule.new(/(?:True|False|Void)\b/i, Tokens::KeywordConstant)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string)
        root.add_rule Rule.new(/'[^']'/, Tokens::StrChar)
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[+\-*\/=<>:]+|:=|\/=/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[A-Z][A-Z0-9_]*/, Tokens::NameClass)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        states[:root] = root

        str = State.new(:string)
        str.add_rule Rule.new(/%[A-Z\/]/, Tokens::StrEscape)
        str.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        str.add_rule Rule.new(/[^"%]+/, Tokens::StrDouble)
        states[:string] = str

        states
      end
    end

    RegexLexer.register("eiffel", Eiffel)
    RegexLexer.register("e", Eiffel)
  end
end
