module Rouge
  module Lexers
    class BIML < RegexLexer
      def self.tag_name : String
        "biml"
      end

      def self.title_text : String
        "BIML"
      end

      def self.desc_text : String
        "Business Intelligence Markup Language"
      end

      def self.file_exts : Array(String)
        ["*.biml"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        tag = State.new(:tag)
        tag.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        tag.add_rule Rule.new(/[a-zA-Z_][\w.-]*\s*=\s*/,
          block: ->(m : Regex::MatchData) {
            [{Tokens::NameAttribute, m[0]}] of TokenPair
          }
        )
        tag.add_rule Rule.new(/"[^"]*"/, Tokens::StrDouble)
        tag.add_rule Rule.new(/'[^']*'/, Tokens::StrSingle)
        tag.add_rule Rule.new(/\/?>/, Tokens::NameTag, pop: true)
        states[:tag] = tag

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/<!--/, Tokens::Comment, next_state: :comment)
        root.add_rule Rule.new(/<!\[CDATA\[/, Tokens::CommentPreproc, next_state: :cdata)
        root.add_rule Rule.new(/<\/[a-zA-Z_][\w.-]*\s*>/, Tokens::NameTag)
        root.add_rule Rule.new(/<[a-zA-Z_][\w.-]*/, Tokens::NameTag, next_state: :tag)
        root.add_rule Rule.new(/<\?xml[^?]*\?>/, Tokens::CommentPreproc)
        root.add_rule Rule.new(/&\w+;/, Tokens::NameEntity)
        root.add_rule Rule.new(/[^<&\s]+/, Tokens::Text)
        states[:root] = root

        comment = State.new(:comment)
        comment.add_rule Rule.new(/-->/, Tokens::Comment, pop: true)
        comment.add_rule Rule.new(/[^-]+/, Tokens::Comment)
        comment.add_rule Rule.new(/-/, Tokens::Comment)
        states[:comment] = comment

        cdata = State.new(:cdata)
        cdata.add_rule Rule.new(/\]\]>/, Tokens::CommentPreproc, pop: true)
        cdata.add_rule Rule.new(/[^\]]+/, Tokens::Text)
        cdata.add_rule Rule.new(/\]/, Tokens::Text)
        states[:cdata] = cdata

        states
      end
    end

    RegexLexer.register("biml", BIML)
  end
end
