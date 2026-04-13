module Rouge
  module Lexers
    class PDFLexer < RegexLexer
      def self.tag_name : String
        "pdf"
      end

      def self.title_text : String
        "PDF"
      end

      def self.desc_text : String
        "PDF document syntax"
      end

      def self.file_exts : Array(String)
        ["*.pdf"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        # :string_paren
        sp = State.new(:string_paren)
        sp.add_rule Rule.new(/\\./, Tokens::StrEscape)
        sp.add_rule Rule.new(/[^)\\]+/, Tokens::Str)
        sp.add_rule Rule.new(/\)/, Tokens::Str, pop: true)
        states[:string_paren] = sp

        # :hex_string
        hs = State.new(:hex_string)
        hs.add_rule Rule.new(/[0-9a-fA-F\s]+/, Tokens::StrOther)
        hs.add_rule Rule.new(/>/, Tokens::Punctuation, pop: true)
        states[:hex_string] = hs

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/%[^\n]*/, Tokens::CommentSingle)

        root.add_rule Rule.new(/\b(?:true|false|null)\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\b(?:obj|endobj|stream|endstream|xref|trailer|startxref)\b/, Tokens::Keyword)

        # Names
        root.add_rule Rule.new(/\/[a-zA-Z_][\w.]*/, Tokens::NameConstant)

        # Dict
        root.add_rule Rule.new(/<</, Tokens::Punctuation)
        root.add_rule Rule.new(/>>/, Tokens::Punctuation)

        # Hex string
        root.add_rule Rule.new(/</, Tokens::Punctuation, next_state: :hex_string)

        # Parenthesized string
        root.add_rule Rule.new(/\(/, Tokens::Str, next_state: :string_paren)

        # Numbers
        root.add_rule Rule.new(/-?\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/-?\d+/, Tokens::NumInteger)

        # References
        root.add_rule Rule.new(/\d+\s+\d+\s+R\b/, Tokens::NameVariable)

        root.add_rule Rule.new(/[\[\]]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("pdf", PDFLexer)
  end
end
