module Rouge
  module Lexers
    class Shell < RegexLexer
      def self.tag_name : String
        "shell"
      end

      def self.title_text : String
        "Shell"
      end

      def self.desc_text : String
        "Bash/Shell script"
      end

      def self.file_exts : Array(String)
        ["*.sh", "*.bash", "*.zsh"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(
          if fi else elif while do done for then return function select
          continue until esac case in
        )

        builtins = %w(
          echo cd pwd ls cat grep sed awk export source alias unalias set unset
          exit read eval exec test true false shift getopts local declare readonly
          trap wait kill bg fg jobs history type which command builtin printf
          mkdir rm cp mv chmod chown touch find sort uniq wc head tail tee xargs
          curl wget tar gzip gunzip sudo apt yum brew pip npm git docker
        )

        kw_pattern = keywords.join("|")
        bi_pattern = builtins.join("|")

        # :root
        root = State.new(:root)
        root.add_rule Rule.new(/\A#!.*$/, Tokens::CommentHashbang)
        root.add_mixin :basic
        root.add_mixin :data
        states[:root] = root

        # :basic
        basic = State.new(:basic)
        basic.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        basic.add_rule Rule.new(/#.*$/, Tokens::CommentSingle)
        basic.add_rule Rule.new(/&&|\|\||[|;&><]|>>|<</, Tokens::Operator)
        basic.add_rule Rule.new(Regex.new("\\b(?:#{kw_pattern})\\b"), Tokens::Keyword)
        basic.add_rule Rule.new(Regex.new("\\b(?:#{bi_pattern})\\b"), Tokens::NameBuiltin)
        states[:basic] = basic

        # :data
        data = State.new(:data)
        data.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :double_quotes)
        data.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :single_quotes)
        data.add_rule Rule.new(/\$\{[^}]+\}/, Tokens::NameVariable)
        data.add_rule Rule.new(/\$[A-Za-z_]\w*/, Tokens::NameVariable)
        data.add_rule Rule.new(/\$[0-9@*#?]/, Tokens::NameVariable)
        data.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        data.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        data.add_rule Rule.new(/[{}()\[\]]/, Tokens::Punctuation)
        data.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Text)
        states[:data] = data

        # :double_quotes
        dq = State.new(:double_quotes)
        dq.add_rule Rule.new(/\$\{/, Tokens::StrInterpol, next_state: :interp)
        dq.add_rule Rule.new(/\$[A-Za-z_]\w*/, Tokens::NameVariable)
        dq.add_rule Rule.new(/\$[0-9@*#?]/, Tokens::NameVariable)
        dq.add_rule Rule.new(/\\./, Tokens::StrEscape)
        dq.add_rule Rule.new(/[^"\\$]+/, Tokens::StrDouble)
        dq.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        states[:double_quotes] = dq

        # :single_quotes
        sq = State.new(:single_quotes)
        sq.add_rule Rule.new(/[^']+/, Tokens::StrSingle)
        sq.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        states[:single_quotes] = sq

        # :interp
        interp = State.new(:interp)
        interp.add_rule Rule.new(/[^}]+/, Tokens::StrInterpol)
        interp.add_rule Rule.new(/\}/, Tokens::StrInterpol, pop: true)
        states[:interp] = interp

        states
      end
    end

    RegexLexer.register("shell", Shell)
    RegexLexer.register("bash", Shell)
    RegexLexer.register("sh", Shell)
    RegexLexer.register("zsh", Shell)
  end
end
