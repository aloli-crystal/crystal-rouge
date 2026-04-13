module Rouge
  module Lexers
    class Haml < RegexLexer
      def self.tag_name : String
        "haml"
      end

      def self.title_text : String
        "Haml"
      end

      def self.desc_text : String
        "Haml HTML templating language"
      end

      def self.file_exts : Array(String)
        ["*.haml"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/-#[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/%[a-zA-Z][\w:-]*/, Tokens::NameTag)
        root.add_rule Rule.new(/\.[a-zA-Z_][\w-]*/, Tokens::NameClass)
        root.add_rule Rule.new(/#[a-zA-Z_][\w-]*/, Tokens::NameOther)
        root.add_rule Rule.new(/#\{[^}]*\}/, Tokens::StrInterpol)
        root.add_rule Rule.new(/[=~&!]-?[^\n]*/, Tokens::Keyword)
        root.add_rule Rule.new(/-[^\n]*/, Tokens::Keyword)
        root.add_rule Rule.new(/"(?:[^"\\]|\\.)*"/, Tokens::StrDouble)
        root.add_rule Rule.new(/'(?:[^'\\]|\\.)*'/, Tokens::StrSingle)
        root.add_rule Rule.new(/\{/, Tokens::Punctuation)
        root.add_rule Rule.new(/\}/, Tokens::Punctuation)
        root.add_rule Rule.new(/[(\[\])]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[=:>]+/, Tokens::Operator)
        root.add_rule Rule.new(/[^\n]+/, Tokens::Text)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("haml", Haml)
  end
end
