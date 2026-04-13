module Rouge
  module Lexers
    class P4 < RegexLexer
      def self.tag_name : String
        "p4"
      end

      def self.title_text : String
        "P4"
      end

      def self.desc_text : String
        "P4 networking programming language"
      end

      def self.file_exts : Array(String)
        ["*.p4"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        sd = State.new(:string_double)
        sd.add_rule Rule.new(/\\./, Tokens::StrEscape)
        sd.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        sd.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        states[:string_double] = sd

        cm = State.new(:comment_multi)
        cm.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        cm.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        cm.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment_multi] = cm

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multi)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)

        root.add_rule Rule.new(/\b(?:true|false)\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\b(?:bit|bool|int|varbit|void)\b/, Tokens::KeywordType)
        root.add_rule Rule.new(/\b(?:action|apply|const|control|default|else|enum|error|extern|exit|header|header_union|if|in|inout|match_kind|out|package|parser|return|select|state|struct|switch|table|transition|true|false|tuple|type|typedef|verify)\b/, Tokens::Keyword)

        # Preprocessor
        root.add_rule Rule.new(/#\s*(?:include|define|ifdef|ifndef|endif|if|else)[^\n]*/, Tokens::CommentPreproc)

        root.add_rule Rule.new(/0[xX][0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/0[bB][01]+/, Tokens::NumBin)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        root.add_rule Rule.new(/[+\-*\/<>=!&|^~]+/, Tokens::Operator)
        root.add_rule Rule.new(/[(){};\[\],:.@]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("p4", P4)
  end
end
