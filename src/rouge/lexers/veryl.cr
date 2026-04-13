module Rouge
  module Lexers
    class Veryl < RegexLexer
      def self.tag_name : String
        "veryl"
      end

      def self.title_text : String
        "Veryl"
      end

      def self.desc_text : String
        "Veryl hardware description language"
      end

      def self.file_exts : Array(String)
        ["*.veryl"]
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

        # Strings
        root.add_rule Rule.new(/"(?:\\.|[^"\\])*"/, Tokens::StrDouble)

        # Declaration keywords
        root.add_rule Rule.new(/\b(?:module|endmodule|interface|endinterface|package|endpackage|function|endfunction)\b/, Tokens::KeywordDeclaration)

        # Flow/other keywords
        root.add_rule Rule.new(/\b(?:always_comb|always_ff|assign|let|var|const|enum|struct|type|if|else|for|in|case|default|return|import|export|initial|final|inst|connect|inside|outside|generate|embed|include|step|break|modport)\b/, Tokens::Keyword)

        # Types
        root.add_rule Rule.new(/\b(?:clock|reset|bit|logic|signed|unsigned|i32|i64|u32|u64|f32|f64|string)\b/, Tokens::KeywordType)

        # Constants
        root.add_rule Rule.new(/\b(?:true|false)\b/, Tokens::KeywordConstant)

        # Numbers
        root.add_rule Rule.new(/\d+'[bBoOdDhH][0-9a-fA-F_xXzZ]+/, Tokens::Num)
        root.add_rule Rule.new(/0x[0-9a-fA-F_]+/, Tokens::NumHex)
        root.add_rule Rule.new(/0b[01_]+/, Tokens::NumBin)
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        # Operators
        root.add_rule Rule.new(/[+\-*\/%=!<>&|^~?:]+/, Tokens::Operator)

        # Punctuation
        root.add_rule Rule.new(/[{}\[\]();,.'#]/, Tokens::Punctuation)

        # Identifiers
        root.add_rule Rule.new(/[a-zA-Z_][a-zA-Z0-9_]*/, Tokens::Name)

        root.add_rule Rule.new(/./, Tokens::Text)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("veryl", Veryl)
  end
end
