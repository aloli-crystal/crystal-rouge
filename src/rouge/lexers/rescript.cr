module Rouge
  module Lexers
    class ReScript < RegexLexer
      def self.tag_name : String
        "rescript"
      end

      def self.title_text : String
        "ReScript"
      end

      def self.desc_text : String
        "ReScript programming language"
      end

      def self.file_exts : Array(String)
        ["*.res", "*.resi"]
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
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :multiline_comment)

        # Template strings with interpolation
        root.add_rule Rule.new(/`/, Tokens::StrBacktick, next_state: :template_string)

        # Regular strings
        root.add_rule Rule.new(/"(?:\\.|[^"\\])*"/, Tokens::StrDouble)

        # Keywords
        root.add_rule Rule.new(/\b(?:and|as|assert|catch|constraint|else|exception|external|for|if|in|include|lazy|let|module|mutable|of|open|rec|switch|to|try|type|when|while|with)\b/, Tokens::Keyword)

        # Constants
        root.add_rule Rule.new(/\b(?:true|false)\b/, Tokens::KeywordConstant)

        # Types (start with uppercase)
        root.add_rule Rule.new(/\b[A-Z][a-zA-Z0-9_]*\b/, Tokens::NameClass)

        # JSX tags
        root.add_rule Rule.new(/<\/[a-zA-Z_][a-zA-Z0-9_.]*>/, Tokens::NameTag)
        root.add_rule Rule.new(/<[a-zA-Z_][a-zA-Z0-9_.]*/, Tokens::NameTag)
        root.add_rule Rule.new(/\/>/, Tokens::NameTag)

        # Numbers
        root.add_rule Rule.new(/0x[0-9a-fA-F_]+/, Tokens::NumHex)
        root.add_rule Rule.new(/0o[0-7_]+/, Tokens::NumOct)
        root.add_rule Rule.new(/0b[01_]+/, Tokens::NumBin)
        root.add_rule Rule.new(/\d+\.\d+(?:e[+-]?\d+)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        # Operators
        root.add_rule Rule.new(/=>/, Tokens::Operator)
        root.add_rule Rule.new(/->/, Tokens::Operator)
        root.add_rule Rule.new(/\|>/, Tokens::Operator)
        root.add_rule Rule.new(/[+\-*\/%=!<>&|^~?:@]+/, Tokens::Operator)

        # Decorators
        root.add_rule Rule.new(/@[a-zA-Z_][a-zA-Z0-9_.]*/, Tokens::NameDecorator)

        # Punctuation
        root.add_rule Rule.new(/[{}\[\]();,.]/, Tokens::Punctuation)

        # Identifiers
        root.add_rule Rule.new(/[a-z_][a-zA-Z0-9_]*/, Tokens::Name)

        root.add_rule Rule.new(/./, Tokens::Text)

        states[:root] = root

        mc = State.new(:multiline_comment)
        mc.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        mc.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        mc.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:multiline_comment] = mc

        ts = State.new(:template_string)
        ts.add_rule Rule.new(/`/, Tokens::StrBacktick, pop: true)
        ts.add_rule Rule.new(/\$\{/, Tokens::StrInterpol, next_state: :interp)
        ts.add_rule Rule.new(/\\./, Tokens::StrEscape)
        ts.add_rule Rule.new(/[^`\\$]+/, Tokens::StrBacktick)
        ts.add_rule Rule.new(/./, Tokens::StrBacktick)
        states[:template_string] = ts

        interp = State.new(:interp)
        interp.add_rule Rule.new(/\}/, Tokens::StrInterpol, pop: true)
        interp.add_rule Rule.new(/[^}]+/, Tokens::Name)
        states[:interp] = interp

        states
      end
    end

    RegexLexer.register("rescript", ReScript)
    RegexLexer.register("res", ReScript)
  end
end
