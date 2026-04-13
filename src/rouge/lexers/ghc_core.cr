module Rouge
  module Lexers
    class GhcCore < RegexLexer
      def self.tag_name : String
        "ghc_core"
      end

      def self.title_text : String
        "GHC Core"
      end

      def self.desc_text : String
        "GHC Core intermediate language"
      end

      def self.file_exts : Array(String)
        [] of String
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(case of let in letrec data newtype forall module where)

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/--[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"(?:[^"\\]|\\.)*"/, Tokens::StrDouble)
        root.add_rule Rule.new(/'(?:[^'\\]|\\.)'/, Tokens::StrChar)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/, Tokens::Keyword)
        root.add_rule Rule.new(/[A-Z][a-zA-Z0-9_']*/, Tokens::NameClass)
        root.add_rule Rule.new(/0[xX][0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/-?\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/-?\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-z_][a-zA-Z0-9_']*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/%&|^~<>=!@#:\.\\]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("ghc_core", GhcCore)
    RegexLexer.register("core", GhcCore)
  end
end
