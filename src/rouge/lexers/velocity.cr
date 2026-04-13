module Rouge
  module Lexers
    class Velocity < RegexLexer
      def self.tag_name : String
        "velocity"
      end

      def self.title_text : String
        "Velocity"
      end

      def self.desc_text : String
        "Apache Velocity template language"
      end

      def self.file_exts : Array(String)
        ["*.vm", "*.vtl"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)

        # Multi-line comments #* ... *#
        root.add_rule Rule.new(/#\*/, Tokens::CommentMultiline, next_state: :multiline_comment)

        # Single-line comments
        root.add_rule Rule.new(/##[^\n]*/, Tokens::CommentSingle)

        # Directives
        root.add_rule Rule.new(/#(?:set|if|elseif|else|end|foreach|include|parse|macro|stop|break|evaluate|define|literal)\b/, Tokens::Keyword)

        # References $!{var.method()} or ${var} or $var
        root.add_rule Rule.new(/\$!?\{[^}]*\}/, Tokens::NameVariable)
        root.add_rule Rule.new(/\$!?[a-zA-Z_][a-zA-Z0-9_]*(?:\.[a-zA-Z_][a-zA-Z0-9_]*(?:\([^)]*\))?)*/, Tokens::NameVariable)

        # Strings
        root.add_rule Rule.new(/"(?:\\.|[^"\\])*"/, Tokens::StrDouble)
        root.add_rule Rule.new(/'(?:\\.|[^'\\])*'/, Tokens::StrSingle)

        # Numbers
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        # Operators
        root.add_rule Rule.new(/[+\-*\/%=!<>&|]+/, Tokens::Operator)

        # Punctuation
        root.add_rule Rule.new(/[{}\[\]();,.]/, Tokens::Punctuation)

        # Plain text
        root.add_rule Rule.new(/[^#\$\s"']+/, Tokens::Text)
        root.add_rule Rule.new(/./, Tokens::Text)

        states[:root] = root

        mc = State.new(:multiline_comment)
        mc.add_rule Rule.new(/\*#/, Tokens::CommentMultiline, pop: true)
        mc.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        mc.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:multiline_comment] = mc

        states
      end
    end

    RegexLexer.register("velocity", Velocity)
    RegexLexer.register("vtl", Velocity)
  end
end
