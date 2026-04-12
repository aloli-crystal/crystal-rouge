module Rouge
  module Lexers
    class Ruby < RegexLexer
      def self.tag_name : String
        "ruby"
      end

      def self.title_text : String
        "Ruby"
      end

      def self.desc_text : String
        "The Ruby programming language (ruby-lang.org)"
      end

      def self.file_exts : Array(String)
        ["*.rb", "*.gemspec", "Rakefile", "Gemfile"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(
          BEGIN END alias and begin break case class def do else elsif end
          ensure for if in module next not or redo rescue retry return self
          super then undef unless until when while yield
        )

        constants = %w(true false nil __FILE__ __LINE__ __ENCODING__)

        builtins = %w(
          puts print p require require_relative include extend
          attr_reader attr_writer attr_accessor raise lambda proc
          loop open gets chomp
        )

        kw_pattern = keywords.join("|")
        const_pattern = constants.join("|").gsub("__", "__")
        builtin_pattern = builtins.join("|")

        # :comment_single
        cs = State.new(:comment_single)
        cs.add_rule Rule.new(/[^\n]*/, Tokens::CommentSingle, pop: true)
        states[:comment_single] = cs

        # :comment_multi
        cm = State.new(:comment_multi)
        cm.add_rule Rule.new(/^=end\b.*$/, Tokens::CommentMultiline, pop: true)
        cm.add_rule Rule.new(/.+/, Tokens::CommentMultiline)
        cm.add_rule Rule.new(/\n/, Tokens::CommentMultiline)
        states[:comment_multi] = cm

        # :string_double
        sd = State.new(:string_double)
        sd.add_rule Rule.new(/#\{/, Tokens::StrInterpol, next_state: :string_interp)
        sd.add_rule Rule.new(/\\./, Tokens::StrEscape)
        sd.add_rule Rule.new(/[^"\\#]+/, Tokens::StrDouble)
        sd.add_rule Rule.new(/#/, Tokens::StrDouble)
        sd.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        states[:string_double] = sd

        # :string_interp
        si = State.new(:string_interp)
        si.add_rule Rule.new(/[^}]+/, Tokens::StrInterpol)
        si.add_rule Rule.new(/\}/, Tokens::StrInterpol, pop: true)
        states[:string_interp] = si

        # :string_single
        ss = State.new(:string_single)
        ss.add_rule Rule.new(/\\./, Tokens::StrEscape)
        ss.add_rule Rule.new(/[^'\\]+/, Tokens::StrSingle)
        ss.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        states[:string_single] = ss

        # :regex
        rx = State.new(:regex)
        rx.add_rule Rule.new(/\\./, Tokens::StrEscape)
        rx.add_rule Rule.new(/[^\/\\]+/, Tokens::StrRegex)
        rx.add_rule Rule.new(/\/[mixouesn]*/, Tokens::StrRegex, pop: true)
        states[:regex] = rx

        # :root
        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/^=begin\b/, Tokens::CommentMultiline, next_state: :comment_multi)
        root.add_rule Rule.new(/#/, Tokens::CommentSingle, next_state: :comment_single)

        # defined? is special
        root.add_rule Rule.new(/defined\?/, Tokens::Keyword)
        root.add_rule Rule.new(Regex.new("\\b(?:#{kw_pattern})\\b"), Tokens::Keyword)
        root.add_rule Rule.new(Regex.new("\\b(?:#{const_pattern})\\b"), Tokens::KeywordConstant)
        root.add_rule Rule.new(Regex.new("\\b(?:#{builtin_pattern})\\b"), Tokens::NameBuiltin)

        # Instance / class / global variables
        root.add_rule Rule.new(/@@[a-zA-Z_]\w*/, Tokens::NameVariableClass)
        root.add_rule Rule.new(/@[a-zA-Z_]\w*/, Tokens::NameVariableInstance)
        root.add_rule Rule.new(/\$[a-zA-Z_]\w*|\$[!@&+`'=~\/\\,;.<>_*$?:"]|\$-[0adFiIlpvw]|\$\d+/, Tokens::NameVariableGlobal)

        # Symbols
        root.add_rule Rule.new(/:"(?:\\.|[^"\\])*"/, Tokens::StrSymbol)
        root.add_rule Rule.new(/:[a-zA-Z_]\w*[?!]?/, Tokens::StrSymbol)

        # Numbers
        root.add_rule Rule.new(/0[xX][0-9a-fA-F_]+/, Tokens::NumHex)
        root.add_rule Rule.new(/0[bB][01_]+/, Tokens::NumBin)
        root.add_rule Rule.new(/0[oO]?[0-7_]+/, Tokens::NumOct)
        root.add_rule Rule.new(/\d[\d_]*\.\d[\d_]*(?:[eE][+-]?\d[\d_]*)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d[\d_]*/, Tokens::NumInteger)

        # Strings
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)

        # Regex
        root.add_rule Rule.new(/\/(?=[^\s*\/])/, Tokens::StrRegex, next_state: :regex)

        # Operators
        root.add_rule Rule.new(/\.\.\.|\.\.|\*\*|<=>|<<=?|>>=?|[+\-*\/%&|^~]=?|[=!<>]=?|&&|\|\|/, Tokens::Operator)

        # Punctuation
        root.add_rule Rule.new(/[{}()\[\];,.:?\\]/, Tokens::Punctuation)

        # Constants (uppercase identifiers)
        root.add_rule Rule.new(/[A-Z]\w*/, Tokens::NameClass)

        # Method names
        root.add_rule Rule.new(/[a-zA-Z_]\w*[?!]?(?=\s*\()/, Tokens::NameFunction)

        # Identifiers
        root.add_rule Rule.new(/[a-zA-Z_]\w*[?!]?/, Tokens::Name)

        states[:root] = root

        states
      end
    end

    RegexLexer.register("ruby", Ruby)
    RegexLexer.register("rb", Ruby)
  end
end
