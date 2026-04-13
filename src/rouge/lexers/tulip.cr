module Rouge
  module Lexers
    class Tulip < RegexLexer
      def self.tag_name : String
        "tulip"
      end

      def self.title_text : String
        "Tulip"
      end

      def self.desc_text : String
        "Tulip programming language"
      end

      def self.file_exts : Array(String)
        ["*.tlp"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)

        # Comments
        root.add_rule Rule.new(/#[^\n]*/, Tokens::CommentSingle)

        # Strings
        root.add_rule Rule.new(/"(?:\\.|[^"\\])*"/, Tokens::StrDouble)
        root.add_rule Rule.new(/'(?:\\.|[^'\\])*'/, Tokens::StrSingle)

        # Numbers
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        # Keywords
        root.add_rule Rule.new(/\b(?:if|else|let|fn|do|end|return|match|with|module|import|export|type|data|class|instance|where|then|in)\b/, Tokens::Keyword)

        # Constants
        root.add_rule Rule.new(/\b(?:true|false|nil)\b/, Tokens::KeywordConstant)

        # Operators
        root.add_rule Rule.new(/[+\-*\/%=!<>&|^~@?:]+/, Tokens::Operator)

        # Punctuation
        root.add_rule Rule.new(/[{}\[\]();,.]/, Tokens::Punctuation)

        # Identifiers
        root.add_rule Rule.new(/[a-zA-Z_][a-zA-Z0-9_]*/, Tokens::Name)

        root.add_rule Rule.new(/./, Tokens::Text)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("tulip", Tulip)
  end
end
