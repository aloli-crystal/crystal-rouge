module Rouge
  module Lexers
    class SliceLexer < RegexLexer
      def self.tag_name : String
        "slice"
      end

      def self.title_text : String
        "Slice"
      end

      def self.desc_text : String
        "Slice (ZeroC ICE interface definition)"
      end

      def self.file_exts : Array(String)
        ["*.ice"]
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
        root.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :multiline_comment)

        # Strings
        root.add_rule Rule.new(/"(?:\\.|[^"\\])*"/, Tokens::StrDouble)

        # Keywords
        root.add_rule Rule.new(/\b(?:module|class|interface|struct|exception|enum|sequence|dictionary|extends|implements|throws|local|const|out|optional|idempotent|tag)\b/, Tokens::Keyword)

        # Types
        root.add_rule Rule.new(/\b(?:void|bool|byte|short|int|long|float|double|string|Object|Value)\b/, Tokens::KeywordType)

        # Boolean constants
        root.add_rule Rule.new(/\b(?:true|false)\b/, Tokens::KeywordConstant)

        # Numbers
        root.add_rule Rule.new(/0x[0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        # Punctuation
        root.add_rule Rule.new(/[{}\[\]();,<>]/, Tokens::Punctuation)

        # Operators
        root.add_rule Rule.new(/[=:*]/, Tokens::Operator)

        # Identifiers
        root.add_rule Rule.new(/[a-zA-Z_][a-zA-Z0-9_]*/, Tokens::Name)

        root.add_rule Rule.new(/./, Tokens::Text)

        states[:root] = root

        mc = State.new(:multiline_comment)
        mc.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        mc.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        mc.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:multiline_comment] = mc

        states
      end
    end

    RegexLexer.register("slice", SliceLexer)
  end
end
