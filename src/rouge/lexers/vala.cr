module Rouge
  module Lexers
    class Vala < RegexLexer
      def self.tag_name : String
        "vala"
      end

      def self.title_text : String
        "Vala"
      end

      def self.desc_text : String
        "Vala programming language (GNOME)"
      end

      def self.file_exts : Array(String)
        ["*.vala", "*.vapi"]
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

        # Triple-quoted strings
        root.add_rule Rule.new(/"""/, Tokens::StrDouble, next_state: :triple_string)

        # Template strings
        root.add_rule Rule.new(/@"/, Tokens::StrDouble, next_state: :template_string)

        # Regular strings
        root.add_rule Rule.new(/"(?:\\.|[^"\\])*"/, Tokens::StrDouble)

        # Keywords
        root.add_rule Rule.new(/\b(?:abstract|as|async|base|break|case|catch|class|const|construct|continue|default|delegate|delete|do|dynamic|else|ensures|enum|errordomain|extern|finally|for|foreach|get|if|in|inline|interface|internal|is|lock|namespace|new|out|override|owned|private|protected|public|ref|requires|return|set|signal|sizeof|static|struct|switch|this|throw|throws|try|typeof|unowned|using|var|virtual|void|volatile|weak|while|with|yield)\b/, Tokens::Keyword)

        # Constants
        root.add_rule Rule.new(/\b(?:true|false|null)\b/, Tokens::KeywordConstant)

        # Types (common GLib/Vala types)
        root.add_rule Rule.new(/\b(?:bool|char|double|float|int|int8|int16|int32|int64|long|short|size_t|ssize_t|string|uchar|uint|uint8|uint16|uint32|uint64|ulong|unichar|ushort)\b/, Tokens::KeywordType)

        # Class names (start with uppercase)
        root.add_rule Rule.new(/\b[A-Z][a-zA-Z0-9_]*\b/, Tokens::NameClass)

        # Numbers
        root.add_rule Rule.new(/0x[0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/\d+\.\d+[fFdD]?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+[lLuU]*/, Tokens::NumInteger)

        # Operators
        root.add_rule Rule.new(/[+\-*\/%=!<>&|^~?:]+/, Tokens::Operator)

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

        ts = State.new(:triple_string)
        ts.add_rule Rule.new(/"""/, Tokens::StrDouble, pop: true)
        ts.add_rule Rule.new(/[^"]+/, Tokens::StrDouble)
        ts.add_rule Rule.new(/"/, Tokens::StrDouble)
        states[:triple_string] = ts

        tmpl = State.new(:template_string)
        tmpl.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        tmpl.add_rule Rule.new(/\$[a-zA-Z_][a-zA-Z0-9_]*/, Tokens::StrInterpol)
        tmpl.add_rule Rule.new(/\$\{[^}]*\}/, Tokens::StrInterpol)
        tmpl.add_rule Rule.new(/\\./, Tokens::StrEscape)
        tmpl.add_rule Rule.new(/[^"\\$]+/, Tokens::StrDouble)
        tmpl.add_rule Rule.new(/./, Tokens::StrDouble)
        states[:template_string] = tmpl

        states
      end
    end

    RegexLexer.register("vala", Vala)
  end
end
