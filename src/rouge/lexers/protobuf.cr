module Rouge
  module Lexers
    class Protobuf < RegexLexer
      def self.tag_name : String
        "protobuf"
      end

      def self.title_text : String
        "Protocol Buffers"
      end

      def self.desc_text : String
        "Google Protocol Buffers (protobuf)"
      end

      def self.file_exts : Array(String)
        ["*.proto"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        # :whitespace
        ws = State.new(:whitespace)
        ws.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        states[:whitespace] = ws

        # :comment_multiline
        comment_ml = State.new(:comment_multiline)
        comment_ml.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        comment_ml.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        comment_ml.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment_multiline] = comment_ml

        # :string_double
        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        # :root
        root = State.new(:root)
        root.add_mixin :whitespace
        # Comments
        root.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multiline)
        # Strings
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        # Keywords
        root.add_rule Rule.new(/\b(?:syntax|import|option|package|message|enum|service|rpc|returns|stream|oneof|map|reserved|to|extend|extensions|repeated|optional|required|group|default|weak|public)\b/, Tokens::Keyword)
        # Built-in types
        root.add_rule Rule.new(/\b(?:double|float|int32|int64|uint32|uint64|sint32|sint64|fixed32|fixed64|sfixed32|sfixed64|bool|string|bytes)\b/, Tokens::KeywordType)
        # Constants
        root.add_rule Rule.new(/\b(?:true|false)\b/, Tokens::KeywordConstant)
        # Numbers
        root.add_rule Rule.new(/0[xX][0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/\d+\.\d+(?:[eE][+-]?\d+)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        # Punctuation
        root.add_rule Rule.new(/[{}()\[\];,]/, Tokens::Punctuation)
        # Operators
        root.add_rule Rule.new(/[=]/, Tokens::Operator)
        # Identifiers (capitalized as type names)
        root.add_rule Rule.new(/[A-Z][a-zA-Z0-9_]*/, Tokens::NameClass)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("protobuf", Protobuf)
    RegexLexer.register("proto", Protobuf)
  end
end
