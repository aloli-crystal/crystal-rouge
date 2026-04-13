module Rouge
  module Lexers
    class Stata < RegexLexer
      def self.tag_name : String
        "stata"
      end

      def self.title_text : String
        "Stata"
      end

      def self.desc_text : String
        "Stata statistical programming language"
      end

      def self.file_exts : Array(String)
        ["*.do", "*.ado"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(
          if else in forvalues foreach while local global program end capture
          quietly noisily display generate replace drop keep sort merge append
          collapse reshape encode decode label tabulate summarize describe list
          count regress logit probit anova ttest correlate graph twoway scatter
          line bar histogram kdensity matrix predict test estimates margins
          bootstrap simulate use save clear set sysuse webuse import export
          insheet outsheet log using by bysort return
        )

        kw_pattern = keywords.join("|")

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :multiline_comment)
        root.add_rule Rule.new(/\/\/.*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\*[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(Regex.new("\\b(?:#{kw_pattern})\\b"), Tokens::Keyword)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string)
        root.add_rule Rule.new(/`[^']*'/, Tokens::StrBacktick)
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[=!<>]+|\+|-|\*|\//, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        states[:root] = root

        mc = State.new(:multiline_comment)
        mc.add_rule Rule.new(/[^*\/]+/, Tokens::CommentMultiline)
        mc.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        mc.add_rule Rule.new(/[*\/]/, Tokens::CommentMultiline)
        states[:multiline_comment] = mc

        str = State.new(:string)
        str.add_rule Rule.new(/\\./, Tokens::StrEscape)
        str.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        str.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string] = str

        states
      end
    end

    RegexLexer.register("stata", Stata)
  end
end
