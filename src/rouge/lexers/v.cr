module Rouge
  module Lexers
    class VLang < RegexLexer
      def self.tag_name : String
        "vlang"
      end

      def self.title_text : String
        "V"
      end

      def self.desc_text : String
        "The V programming language (vlang.io)"
      end

      def self.file_exts : Array(String)
        ["*.v", "*.vv"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        # :string_double
        sd = State.new(:string_double)
        sd.add_rule Rule.new(/\\./, Tokens::StrEscape)
        sd.add_rule Rule.new(/\$\{[^}]*\}/, Tokens::StrInterpol)
        sd.add_rule Rule.new(/\$[a-zA-Z_]\w*/, Tokens::StrInterpol)
        sd.add_rule Rule.new(/[^"\\$]+/, Tokens::StrDouble)
        sd.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        states[:string_double] = sd

        # :string_single
        ss = State.new(:string_single)
        ss.add_rule Rule.new(/\\./, Tokens::StrEscape)
        ss.add_rule Rule.new(/[^'\\]+/, Tokens::StrSingle)
        ss.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        states[:string_single] = ss

        # :string_raw
        sr = State.new(:string_raw)
        sr.add_rule Rule.new(/[^`]+/, Tokens::StrBacktick)
        sr.add_rule Rule.new(/`/, Tokens::StrBacktick, pop: true)
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
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multi)
        root.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)
        root.add_rule Rule.new(/`/, Tokens::StrBacktick, next_state: :string_raw)

        root.add_rule Rule.new(/\b(?:true|false|none)\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\b(?:as|asm|assert|atomic|break|const|continue|defer|else|enum|fn|for|go|goto|if|import|in|interface|is|isreftype|lock|match|module|mut|or|pub|return|rlock|select|shared|sizeof|spawn|static|struct|type|typeof|union|unsafe|volatile)\b/, Tokens::Keyword)

        root.add_rule Rule.new(/\d+\.\d+(?:[eE][+-]?\d+)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/0[xX][0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/0[bB][01]+/, Tokens::NumBin)
        root.add_rule Rule.new(/0[oO][0-7]+/, Tokens::NumOct)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        root.add_rule Rule.new(/[+\-*\/%<>=!&|^~?]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.:#]+/, Tokens::Punctuation)
        root.add_rule Rule.new(/[A-Z]\w*/, Tokens::NameClass)
        root.add_rule Rule.new(/[a-z_]\w*/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("vlang", VLang)
  end
end
