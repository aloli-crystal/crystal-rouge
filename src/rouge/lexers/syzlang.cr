module Rouge
  module Lexers
    class Syzlang < RegexLexer
      def self.tag_name : String
        "syzlang"
      end

      def self.title_text : String
        "Syzlang"
      end

      def self.desc_text : String
        "Syzkaller description language"
      end

      def self.file_exts : Array(String)
        ["*.txt"]
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

        # Keywords
        root.add_rule Rule.new(/\b(?:resource|type|define|include|incdir|flags|len|bytesize|bitsize|vma|proc|text|fmt|opt|const|in|out|inout)\b/, Tokens::Keyword)

        # Types
        root.add_rule Rule.new(/\b(?:intptr|int8|int16|int32|int64|array|ptr|buffer|string|glob|fileoff|signalno|filename|bytesize2|bytesize4|bytesize8|offsetof|align|parent|void|bool8|bool16|bool32|bool64)\b/, Tokens::KeywordType)

        # Numbers
        root.add_rule Rule.new(/0x[0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        # Punctuation
        root.add_rule Rule.new(/[{}\[\](),=:.]/, Tokens::Punctuation)

        # Identifiers
        root.add_rule Rule.new(/[a-zA-Z_][a-zA-Z0-9_\$]*/, Tokens::Name)

        root.add_rule Rule.new(/./, Tokens::Text)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("syzlang", Syzlang)
  end
end
