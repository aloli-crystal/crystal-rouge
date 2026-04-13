module Rouge
  module Lexers
    class OpenEdge < RegexLexer
      def self.tag_name : String
        "openedge"
      end

      def self.title_text : String
        "OpenEdge ABL"
      end

      def self.desc_text : String
        "OpenEdge ABL / Progress 4GL"
      end

      def self.file_exts : Array(String)
        ["*.p", "*.cls", "*.w"]
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

        ss = State.new(:string_single)
        ss.add_rule Rule.new(/\\./, Tokens::StrEscape)
        ss.add_rule Rule.new(/[^'\\]+/, Tokens::StrSingle)
        ss.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        states[:string_single] = ss

        cm = State.new(:comment_multi)
        cm.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        cm.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        cm.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment_multi] = cm

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multi)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)

        root.add_rule Rule.new(/\b(?:TRUE|FALSE|YES|NO|UNKNOWN)\b/i, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\b(?:INTEGER|CHARACTER|DECIMAL|LOGICAL|DATE|DATETIME|INT64|HANDLE|MEMPTR|RAW|LONGCHAR|ROWID|RECID|VOID)\b/i, Tokens::KeywordType)
        root.add_rule Rule.new(/\b(?:DEFINE|VARIABLE|AS|ASSIGN|BLOCK-LEVEL|BUFFER|CLASS|CONSTRUCTOR|CREATE|DATA-SOURCE|DATASET|DELETE|DESTRUCTOR|DO|ELSE|END|ENTRY|ENUM|FIND|FOR|EACH|FIRST|LAST|FUNCTION|IF|THEN|INPUT|INTERFACE|LEAVE|METHOD|NEW|NO-ERROR|NO-UNDO|OUTPUT|PROCEDURE|PUBLISH|REPEAT|RETURN|RUN|SUBSCRIBE|SUPER|TEMP-TABLE|THIS-OBJECT|TRIGGER|UNDO|USING|VIEW-AS)\b/i, Tokens::Keyword)

        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        root.add_rule Rule.new(/[+\-*\/<>=!]+/, Tokens::Operator)
        root.add_rule Rule.new(/[(){};\[\],:.]+/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_][\w-]*/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("openedge", OpenEdge)
    RegexLexer.register("progress", OpenEdge)
    RegexLexer.register("abl", OpenEdge)
  end
end
