module Rouge
  module Lexers
    class BibTeX < RegexLexer
      def self.tag_name : String
        "bibtex"
      end

      def self.title_text : String
        "BibTeX"
      end

      def self.desc_text : String
        "BibTeX bibliography format"
      end

      def self.file_exts : Array(String)
        ["*.bib"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        entry_types = %w(article book booklet conference inbook incollection inproceedings manual mastersthesis misc phdthesis proceedings techreport unpublished string preamble comment)

        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        braced = State.new(:braced)
        braced.add_rule Rule.new(/\{/, Tokens::Punctuation, next_state: :braced)
        braced.add_rule Rule.new(/\}/, Tokens::Punctuation, pop: true)
        braced.add_rule Rule.new(/[^{}]+/, Tokens::StrDouble)
        states[:braced] = braced

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/%[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/@(?:#{entry_types.join("|")})\b/i, Tokens::Keyword)
        root.add_rule Rule.new(/(?:author|title|journal|year|volume|number|pages|month|note|key|publisher|editor|series|address|edition|howpublished|booktitle|organization|school|institution|type|chapter|doi|url|isbn|issn|abstract|keywords)\b/i, Tokens::NameAttribute)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/\{/, Tokens::Punctuation, next_state: :braced)
        root.add_rule Rule.new(/\}/, Tokens::Punctuation)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[=,#]/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];.]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("bibtex", BibTeX)
    RegexLexer.register("bib", BibTeX)
  end
end
