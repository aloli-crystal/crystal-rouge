module Rouge
  module Lexers
    class Makefile < RegexLexer
      def self.tag_name : String
        "makefile"
      end

      def self.title_text : String
        "Makefile"
      end

      def self.desc_text : String
        "GNU Make build files"
      end

      def self.file_exts : Array(String)
        ["Makefile", "*.mk", "GNUmakefile"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        directives = %w(
          include ifdef ifndef ifeq ifneq else endif define endef
          export unexport override vpath
        )

        directive_pattern = directives.join("|")

        # :shell_command
        shell = State.new(:shell_command)
        shell.add_rule Rule.new(/\$\([\w.:=%-]+\)/, Tokens::NameVariable)
        shell.add_rule Rule.new(/\$\{[\w.:=%-]+\}/, Tokens::NameVariable)
        shell.add_rule Rule.new(/\$[@<^?*%]/, Tokens::NameVariable)
        shell.add_rule Rule.new(/\$\([@<^?*%][DF]\)/, Tokens::NameVariable)
        shell.add_rule Rule.new(/\\$/, Tokens::Punctuation)
        shell.add_rule Rule.new(/[^\n$\\]+/, Tokens::Text)
        shell.add_rule Rule.new(/\$/, Tokens::Text)
        shell.add_rule Rule.new(/\n/, Tokens::TextWhitespace, pop: true)
        states[:shell_command] = shell

        # :root
        root = State.new(:root)

        # Comments
        root.add_rule Rule.new(/#.*$/, Tokens::CommentSingle)

        # Shell commands (lines starting with tab)
        root.add_rule Rule.new(/\t/, Tokens::TextWhitespace, next_state: :shell_command)

        # Directives
        root.add_rule Rule.new(Regex.new("(?:#{directive_pattern})\\b"), Tokens::Keyword)

        # Variable assignments: VAR = value, VAR := value, VAR ?= value, VAR += value
        root.add_rule Rule.new(
          /([a-zA-Z_]\w*)(\s*)([?+:]?=)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::NameVariable, m[1]},
              {Tokens::TextWhitespace, m[2]},
              {Tokens::Operator, m[3]},
            ] of TokenPair
          }
        )

        # .PHONY and other special targets
        root.add_rule Rule.new(
          /(\.[A-Z_]+)(\s*)(:)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::NameBuiltin, m[1]},
              {Tokens::TextWhitespace, m[2]},
              {Tokens::Operator, m[3]},
            ] of TokenPair
          }
        )

        # Target rules: target: dependencies
        root.add_rule Rule.new(
          /([\w.%\/-]+)(\s*)(:)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::NameFunction, m[1]},
              {Tokens::TextWhitespace, m[2]},
              {Tokens::Operator, m[3]},
            ] of TokenPair
          }
        )

        # Variable references
        root.add_rule Rule.new(/\$\([\w.:=%-]+\)/, Tokens::NameVariable)
        root.add_rule Rule.new(/\$\{[\w.:=%-]+\}/, Tokens::NameVariable)
        root.add_rule Rule.new(/\$[@<^?*%]/, Tokens::NameVariable)
        root.add_rule Rule.new(/\$\([@<^?*%][DF]\)/, Tokens::NameVariable)

        # Whitespace
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)

        # Line continuation
        root.add_rule Rule.new(/\\$/, Tokens::Punctuation)

        # Generic text
        root.add_rule Rule.new(/[^\s#$\\:=]+/, Tokens::Text)
        root.add_rule Rule.new(/./, Tokens::Text)

        states[:root] = root

        states
      end
    end

    RegexLexer.register("makefile", Makefile)
    RegexLexer.register("make", Makefile)
  end
end
