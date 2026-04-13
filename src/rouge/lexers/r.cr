module Rouge
  module Lexers
    class R < RegexLexer
      def self.tag_name : String
        "r"
      end

      def self.title_text : String
        "R"
      end

      def self.desc_text : String
        "The R programming language (r-project.org)"
      end

      def self.file_exts : Array(String)
        ["*.r", "*.R", "*.Rscript"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(if else repeat while function for in next break return switch tryCatch)

        constants = %w(TRUE FALSE NULL NA NA_integer_ NA_real_ NA_complex_ NA_character_ Inf NaN T F)

        builtins = %w(
          c list data.frame matrix vector print cat paste paste0 length nrow ncol
          dim names class str summary head tail which seq rep sort order unique
          table apply sapply lapply tapply mapply library require install.packages
          source setwd getwd read.csv write.csv plot hist barplot ggplot mean
          median sd var sum min max abs sqrt log exp round ceiling floor
        )

        kw_pattern = keywords.join("|")
        const_pattern = constants.map { |c| Regex.escape(c) }.join("|")
        builtin_pattern = builtins.map { |b| Regex.escape(b) }.join("|")

        # :comment_single
        cs = State.new(:comment_single)
        cs.add_rule Rule.new(/[^\n]*/, Tokens::CommentSingle, pop: true)
        states[:comment_single] = cs

        # :string_double
        sd = State.new(:string_double)
        sd.add_rule Rule.new(/\\./, Tokens::StrEscape)
        sd.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        sd.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        states[:string_double] = sd

        # :string_single
        ss = State.new(:string_single)
        ss.add_rule Rule.new(/\\./, Tokens::StrEscape)
        ss.add_rule Rule.new(/[^'\\]+/, Tokens::StrSingle)
        ss.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        states[:string_single] = ss

        # :root
        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/#/, Tokens::CommentSingle, next_state: :comment_single)

        root.add_rule Rule.new(Regex.new("\\b(?:#{kw_pattern})\\b"), Tokens::Keyword)
        root.add_rule Rule.new(Regex.new("\\b(?:#{const_pattern})\\b"), Tokens::KeywordConstant)
        root.add_rule Rule.new(Regex.new("\\b(?:#{builtin_pattern})(?=\\s*\\()"), Tokens::NameBuiltin)

        # Numbers
        root.add_rule Rule.new(/0[xX][0-9a-fA-F]+[Li]?/, Tokens::NumHex)
        root.add_rule Rule.new(/\d+\.\d*(?:[eE][+-]?\d+)?[Li]?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\.\d+(?:[eE][+-]?\d+)?[Li]?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+(?:[eE][+-]?\d+)[Li]?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+[Li]?/, Tokens::NumInteger)

        # Strings
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)

        # Assignment operators
        root.add_rule Rule.new(/<<-|<-|->|->>/, Tokens::Operator)

        # Operators
        root.add_rule Rule.new(/%[a-zA-Z_]+%/, Tokens::Operator)
        root.add_rule Rule.new(/\|\||&&|>=|<=|==|!=|[+\-*\/%^~!<>=|&$@?:]/, Tokens::Operator)

        # Punctuation
        root.add_rule Rule.new(/[{}()\[\];,]/, Tokens::Punctuation)

        # Function names
        root.add_rule Rule.new(/[a-zA-Z_.][a-zA-Z0-9_.]*(?=\s*\()/, Tokens::NameFunction)

        # Identifiers
        root.add_rule Rule.new(/[a-zA-Z_.][a-zA-Z0-9_.]*/, Tokens::Name)

        states[:root] = root

        states
      end
    end

    RegexLexer.register("r", R)
    RegexLexer.register("R", R)
    RegexLexer.register("rlang", R)
  end
end
