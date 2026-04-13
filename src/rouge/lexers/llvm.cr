module Rouge
  module Lexers
    class LLVM < RegexLexer
      def self.tag_name : String
        "llvm"
      end

      def self.title_text : String
        "LLVM"
      end

      def self.desc_text : String
        "LLVM Intermediate Representation"
      end

      def self.file_exts : Array(String)
        ["*.ll"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        # :string
        sd = State.new(:string_double)
        sd.add_rule Rule.new(/\\./, Tokens::StrEscape)
        sd.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        sd.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        states[:string_double] = sd

        # :root
        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/;[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)

        # Metadata
        root.add_rule Rule.new(/!\d+/, Tokens::NameVariable)
        root.add_rule Rule.new(/![a-zA-Z_][\w.]*/, Tokens::NameVariable)

        # Labels
        root.add_rule Rule.new(/[a-zA-Z_][\w.]*:/, Tokens::NameLabel)

        # Types
        root.add_rule Rule.new(/\b(?:i1|i8|i16|i32|i64|i128|float|double|void|ptr)\b/, Tokens::KeywordType)

        # Keywords
        root.add_rule Rule.new(/\b(?:define|declare|ret|br|switch|invoke|resume|unreachable|add|sub|mul|sdiv|udiv|srem|urem|fadd|fsub|fmul|fdiv|frem|and|or|xor|shl|lshr|ashr|icmp|fcmp|phi|select|call|alloca|load|store|getelementptr|trunc|zext|sext|fptrunc|fpext|bitcast|to|label|void|metadata|target|datalayout|triple|global|constant|private|internal|external|linkonce|weak|appending|common|unnamed_addr|align|nounwind|readnone|readonly|inbounds|nsw|nuw|exact|tail)\b/, Tokens::Keyword)

        # Identifiers
        root.add_rule Rule.new(/%[a-zA-Z_][\w.]*/, Tokens::NameVariable)
        root.add_rule Rule.new(/@[a-zA-Z_][\w.]*/, Tokens::NameVariableGlobal)
        root.add_rule Rule.new(/%\d+/, Tokens::NameVariable)

        # Numbers
        root.add_rule Rule.new(/0[xX][0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/-?\d+\.\d+(?:e[+-]?\d+)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/-?\d+/, Tokens::NumInteger)

        # Operators and punctuation
        root.add_rule Rule.new(/[=(){}\[\],*]/, Tokens::Punctuation)

        # Other
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("llvm", LLVM)
  end
end
