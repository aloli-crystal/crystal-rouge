module Rouge
  module Lexers
    class Idris < RegexLexer
      def self.tag_name : String
        "idris"
      end

      def self.title_text : String
        "Idris"
      end

      def self.desc_text : String
        "Idris dependently typed language"
      end

      def self.file_exts : Array(String)
        ["*.idr"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(module import data where let in do record class instance interface implementation case of if then else with proof total partial covering mutual namespace parameters using public private export implicit auto default impossible rewrite syntax prefix infix infixl infixr pattern)

        comment_multi = State.new(:comment_multi)
        comment_multi.add_rule Rule.new(/-\}/, Tokens::CommentMultiline, pop: true)
        comment_multi.add_rule Rule.new(/[^-]+/, Tokens::CommentMultiline)
        comment_multi.add_rule Rule.new(/-/, Tokens::CommentMultiline)
        states[:comment_multi] = comment_multi

        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/--[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\{-/, Tokens::CommentMultiline, next_state: :comment_multi)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'(?:[^'\\]|\\.)'/, Tokens::StrChar)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/, Tokens::Keyword)
        root.add_rule Rule.new(/[A-Z][a-zA-Z0-9_']*/, Tokens::NameClass)
        root.add_rule Rule.new(/0[xX][0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-z_][a-zA-Z0-9_']*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/%&|^~<>=!@#$:.\\]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("idris", Idris)
    RegexLexer.register("idr", Idris)
  end
end
