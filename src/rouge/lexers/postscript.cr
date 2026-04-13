module Rouge
  module Lexers
    class PostScript < RegexLexer
      def self.tag_name : String
        "postscript"
      end

      def self.title_text : String
        "PostScript"
      end

      def self.desc_text : String
        "PostScript page description language"
      end

      def self.file_exts : Array(String)
        ["*.ps", "*.eps"]
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

        # Names
        root.add_rule Rule.new(/\/[a-zA-Z_][\w.]*/, Tokens::NameConstant)

        # Strings
        root.add_rule Rule.new(/\(/, Tokens::Str, next_state: :string_paren)
        root.add_rule Rule.new(/</, Tokens::Punctuation, next_state: :hex_string)

        # Keywords
        root.add_rule Rule.new(/\b(?:def|begin|end|dict|dup|exch|pop|copy|index|roll|clear|count|mark|array|length|get|put|aload|astore|string|search|anchorsearch|token|cvs|cvrs|cvx|exec|if|ifelse|for|repeat|loop|exit|forall|pathforall|bind|readonly|executeonly|noaccess|currentdict|systemdict|userdict|globaldict|statusdict)\b/, Tokens::Keyword)

        # Booleans
        root.add_rule Rule.new(/\b(?:true|false)\b/, Tokens::KeywordConstant)

        # Numbers
        root.add_rule Rule.new(/-?\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/-?\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[0-9]+#[0-9a-zA-Z]+/, Tokens::NumOther)

        root.add_rule Rule.new(/[{}()\[\]]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_][\w.]*/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("postscript", PostScript)
    RegexLexer.register("ps", PostScript)
  end
end
