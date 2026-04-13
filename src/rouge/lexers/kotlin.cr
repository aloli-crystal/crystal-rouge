module Rouge
  module Lexers
    class Kotlin < RegexLexer
      def self.tag_name : String
        "kotlin"
      end

      def self.title_text : String
        "Kotlin"
      end

      def self.desc_text : String
        "The Kotlin programming language (kotlinlang.org)"
      end

      def self.file_exts : Array(String)
        ["*.kt", "*.kts"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        # :string_double
        sd = State.new(:string_double)
        sd.add_rule Rule.new(/\$\{[^}]*\}/, Tokens::StrInterpol)
        sd.add_rule Rule.new(/\$\w+/, Tokens::StrInterpol)
        sd.add_rule Rule.new(/\\[tbnr'"\\$]/, Tokens::StrEscape)
        sd.add_rule Rule.new(/[^"$\\]+/, Tokens::StrDouble)
        sd.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        sd.add_rule Rule.new(/./, Tokens::StrDouble)
        states[:string_double] = sd

        # :string_raw
        sr = State.new(:string_raw)
        sr.add_rule Rule.new(/\$\{[^}]*\}/, Tokens::StrInterpol)
        sr.add_rule Rule.new(/\$\w+/, Tokens::StrInterpol)
        sr.add_rule Rule.new(/"""/, Tokens::StrDouble, pop: true)
        sr.add_rule Rule.new(/[^"$]+/, Tokens::StrDouble)
        sr.add_rule Rule.new(/./, Tokens::StrDouble)
        states[:string_raw] = sr

        # :comment_multi
        cm = State.new(:comment_multi)
        cm.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        cm.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        cm.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment_multi] = cm

        # :root
        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)

        # Comments
        root.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multi)

        # Annotations
        root.add_rule Rule.new(/@\w+/, Tokens::NameDecorator)

        # Labels
        root.add_rule Rule.new(/\w+@/, Tokens::NameLabel)

        # Raw strings
        root.add_rule Rule.new(/"""/, Tokens::StrDouble, next_state: :string_raw)

        # Strings
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)

        # Characters
        root.add_rule Rule.new(/'\\.'/, Tokens::StrChar)
        root.add_rule Rule.new(/'[^\\']'/, Tokens::StrChar)

        # Constants
        root.add_rule Rule.new(/\b(?:true|false)\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\bnull\b/, Tokens::KeywordConstant)

        # Types
        root.add_rule Rule.new(/\b(?:Int|Long|Short|Byte|Float|Double|Boolean|Char|String|Unit|Nothing|Any|Array|List|Map|Set|Pair|Triple|MutableList|MutableMap|MutableSet)\b/, Tokens::KeywordType)

        # Keywords
        root.add_rule Rule.new(/\b(?:abstract|actual|annotation|as|break|by|catch|class|companion|const|constructor|continue|crossinline|data|do|else|enum|expect|external|final|finally|for|fun|get|if|import|in|infix|init|inline|inner|interface|internal|is|lateinit|noinline|object|open|operator|out|override|package|private|protected|public|reified|return|sealed|set|super|suspend|tailrec|this|throw|try|typealias|val|var|vararg|when|where|while|yield)\b/, Tokens::Keyword)

        # Numbers
        root.add_rule Rule.new(/0x[0-9a-fA-F_]+[Ll]?/, Tokens::NumHex)
        root.add_rule Rule.new(/0b[01_]+[Ll]?/, Tokens::NumBin)
        root.add_rule Rule.new(/\d[\d_]*\.\d[\d_]*(?:[eE][+-]?\d[\d_]*)?[fF]?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d[\d_]*[eE][+-]?\d[\d_]*[fF]?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d[\d_]*[Ll]/, Tokens::NumIntegerLong)
        root.add_rule Rule.new(/\d[\d_]*[fF]/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d[\d_]*/, Tokens::NumInteger)

        # Operators
        root.add_rule Rule.new(/[+\-*\/%&|^!<>=]=?/, Tokens::Operator)
        root.add_rule Rule.new(/->|\.\./, Tokens::Operator)
        root.add_rule Rule.new(/::/, Tokens::Operator)

        # Punctuation
        root.add_rule Rule.new(/[{}()\[\];,.:?]/, Tokens::Punctuation)

        # Identifiers
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("kotlin", Kotlin)
    RegexLexer.register("kt", Kotlin)
  end
end
