module Rouge
  module Lexers
    class Zig < RegexLexer
      def self.tag_name : String
        "zig"
      end

      def self.title_text : String
        "Zig"
      end

      def self.desc_text : String
        "The Zig programming language"
      end

      def self.file_exts : Array(String)
        ["*.zig"]
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

        # :string_double
        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/\\[\\'"abefnrtv0]/, Tokens::StrEscape)
        string_double.add_rule Rule.new(/\\x[0-9a-fA-F]{2}/, Tokens::StrEscape)
        string_double.add_rule Rule.new(/\\u\{[0-9a-fA-F]+\}/, Tokens::StrEscape)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        # :root
        root = State.new(:root)
        root.add_mixin :whitespace
        # Comments
        root.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        # Strings
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        # Multiline strings (\\...)
        root.add_rule Rule.new(/\\\\[^\n]*/, Tokens::Str)
        # Character literals
        root.add_rule Rule.new(/'(?:\\[\\'"abefnrtv0]|\\x[0-9a-fA-F]{2}|\\u\{[0-9a-fA-F]+\}|[^'\\])'/, Tokens::StrChar)
        # Keywords
        root.add_rule Rule.new(/\b(?:addrspace|align|allowzero|and|anyframe|anytype|asm|async|await|break|callconv|catch|comptime|const|continue|defer|else|enum|errdefer|error|export|extern|fn|for|if|inline|linksection|noalias|nosuspend|opaque|or|orelse|packed|pub|resume|return|struct|suspend|switch|test|threadlocal|try|union|unreachable|var|volatile|while)\b/, Tokens::Keyword)
        # Built-in types
        root.add_rule Rule.new(/\b(?:i8|i16|i32|i64|i128|u8|u16|u32|u64|u128|f16|f32|f64|f128|usize|isize|bool|void|noreturn|type|anyerror|comptime_int|comptime_float)\b/, Tokens::KeywordType)
        # Constants
        root.add_rule Rule.new(/\b(?:true|false|null|undefined)\b/, Tokens::KeywordConstant)
        # Builtins (@name)
        root.add_rule Rule.new(/@[a-zA-Z_]\w*/, Tokens::NameBuiltin)
        # Numbers with underscores
        root.add_rule Rule.new(/0[xX][0-9a-fA-F_]+/, Tokens::NumHex)
        root.add_rule Rule.new(/0[oO][0-7_]+/, Tokens::NumOct)
        root.add_rule Rule.new(/0[bB][01_]+/, Tokens::NumBin)
        root.add_rule Rule.new(/\d[\d_]*\.\d[\d_]*(?:[eE][+-]?\d[\d_]*)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d[\d_]*/, Tokens::NumInteger)
        # Operators
        root.add_rule Rule.new(/[+\-*\/%=<>!&|^~?]/, Tokens::Operator)
        # Punctuation
        root.add_rule Rule.new(/[{}()\[\];,.:@]/, Tokens::Punctuation)
        # Identifiers
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("zig", Zig)
  end
end
