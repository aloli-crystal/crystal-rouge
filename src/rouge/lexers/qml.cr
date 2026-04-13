module Rouge
  module Lexers
    class QML < RegexLexer
      def self.tag_name : String
        "qml"
      end

      def self.title_text : String
        "QML"
      end

      def self.desc_text : String
        "Qt Modeling Language (qt.io)"
      end

      def self.file_exts : Array(String)
        ["*.qml"]
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
        sd.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        sd.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        states[:string_double] = sd

        # :string_single
        ss = State.new(:string_single)
        ss.add_rule Rule.new(/\\./, Tokens::StrEscape)
        ss.add_rule Rule.new(/[^'\\]+/, Tokens::StrSingle)
        ss.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        states[:string_single] = ss

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

        root.add_rule Rule.new(/\b(?:true|false|null|undefined)\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\b(?:int|real|double|bool|string|list|var|color|date|point|size|rect|url|font|variant|enumeration|QtObject|Item|Rectangle|Text|Image|Column|Row|ListView|Repeater|Timer|MouseArea|Button|Label|ApplicationWindow)\b/, Tokens::KeywordType)
        root.add_rule Rule.new(/\b(?:import|property|signal|readonly|alias|default|required|component|function|let|const|if|else|for|while|do|switch|case|break|continue|return|try|catch|finally|throw|this|as|on|id)\b/, Tokens::Keyword)

        # Property bindings: name:
        root.add_rule Rule.new(
          /([a-zA-Z_]\w*)(\s*)(:)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::NameProperty, m[1]},
              {Tokens::TextWhitespace, m[2]},
              {Tokens::Punctuation, m[3]},
            ] of TokenPair
          }
        )

        root.add_rule Rule.new(/\d+\.\d+(?:[eE][+-]?\d+)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/0[xX][0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        root.add_rule Rule.new(/[+\-*\/%<>=!&|^~?:]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]+/, Tokens::Punctuation)
        root.add_rule Rule.new(/[A-Z]\w*/, Tokens::NameClass)
        root.add_rule Rule.new(/[a-z_]\w*/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("qml", QML)
  end
end
