module Rouge
  module Lexers
    class TeX < RegexLexer
      def self.tag_name : String
        "tex"
      end

      def self.title_text : String
        "TeX/LaTeX"
      end

      def self.desc_text : String
        "TeX and LaTeX typesetting"
      end

      def self.file_exts : Array(String)
        ["*.tex", "*.sty", "*.cls"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        root = State.new(:root)
        root.add_rule Rule.new(/%.*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\\begin\{[^}]+\}/, Tokens::Keyword)
        root.add_rule Rule.new(/\\end\{[^}]+\}/, Tokens::Keyword)
        root.add_rule Rule.new(/\\[a-zA-Z@]+\*?/, Tokens::Keyword)
        root.add_rule Rule.new(/\\\\./, Tokens::Keyword)
        root.add_rule Rule.new(/\$\$/, Tokens::Str, next_state: :display_math)
        root.add_rule Rule.new(/\$/, Tokens::Str, next_state: :inline_math)
        root.add_rule Rule.new(/\[/, Tokens::Punctuation, next_state: :options)
        root.add_rule Rule.new(/\{/, Tokens::Punctuation, next_state: :group)
        root.add_rule Rule.new(/[~^_&]/, Tokens::Operator)
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/[^\s\\{}$%\[\]~^_&]+/, Tokens::Text)
        states[:root] = root

        group = State.new(:group)
        group.add_rule Rule.new(/\}/, Tokens::Punctuation, pop: true)
        group.add_rule Rule.new(/\\[a-zA-Z@]+\*?/, Tokens::Keyword)
        group.add_rule Rule.new(/\{/, Tokens::Punctuation, next_state: :group)
        group.add_rule Rule.new(/[^}\\{]+/, Tokens::Text)
        states[:group] = group

        options = State.new(:options)
        options.add_rule Rule.new(/\]/, Tokens::Punctuation, pop: true)
        options.add_rule Rule.new(/[^\]]+/, Tokens::Text)
        states[:options] = options

        im = State.new(:inline_math)
        im.add_rule Rule.new(/\$/, Tokens::Str, pop: true)
        im.add_rule Rule.new(/\\[a-zA-Z]+/, Tokens::Keyword)
        im.add_rule Rule.new(/[^$\\]+/, Tokens::Str)
        states[:inline_math] = im

        dm = State.new(:display_math)
        dm.add_rule Rule.new(/\$\$/, Tokens::Str, pop: true)
        dm.add_rule Rule.new(/\\[a-zA-Z]+/, Tokens::Keyword)
        dm.add_rule Rule.new(/[^$\\]+/, Tokens::Str)
        dm.add_rule Rule.new(/\$/, Tokens::Str)
        states[:display_math] = dm

        states
      end
    end

    RegexLexer.register("tex", TeX)
    RegexLexer.register("latex", TeX)
  end
end
