module Rouge
  module Lexers
    class Plist < RegexLexer
      def self.tag_name : String
        "plist"
      end

      def self.title_text : String
        "Plist"
      end

      def self.desc_text : String
        "Apple Property List (XML)"
      end

      def self.file_exts : Array(String)
        ["*.plist"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        # :tag
        tag = State.new(:tag)
        tag.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        tag.add_rule Rule.new(/[a-zA-Z_:][\w:.-]*\s*=\s*/, Tokens::NameAttribute)
        tag.add_rule Rule.new(/"[^"]*"/, Tokens::StrDouble)
        tag.add_rule Rule.new(/'[^']*'/, Tokens::StrSingle)
        tag.add_rule Rule.new(/\/?>/, Tokens::NameTag, pop: true)
        states[:tag] = tag

        # :comment
        cm = State.new(:comment)
        cm.add_rule Rule.new(/-->/, Tokens::CommentMultiline, pop: true)
        cm.add_rule Rule.new(/[^-]+/, Tokens::CommentMultiline)
        cm.add_rule Rule.new(/-/, Tokens::CommentMultiline)
        states[:comment] = cm

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/<!--/, Tokens::CommentMultiline, next_state: :comment)
        root.add_rule Rule.new(/<\?xml[^?]*\?>/, Tokens::CommentPreproc)
        root.add_rule Rule.new(/<!DOCTYPE[^>]*>/, Tokens::CommentPreproc)

        # Plist-specific tags
        root.add_rule Rule.new(/<(?:dict|array|string|integer|real|data|date|true|false|plist)[^>]*>/, Tokens::NameTag)
        root.add_rule Rule.new(/<\/(?:dict|array|string|integer|real|data|date|true|false|plist)>/, Tokens::NameTag)
        root.add_rule Rule.new(/<(?:true|false)\s*\/>/, Tokens::NameTag)
        root.add_rule Rule.new(/<key>/, Tokens::NameTag)
        root.add_rule Rule.new(/<\/key>/, Tokens::NameTag)

        # Generic tags
        root.add_rule Rule.new(/<\/[a-zA-Z_:][\w:.-]*>/, Tokens::NameTag)
        root.add_rule Rule.new(/<[a-zA-Z_:][\w:.-]*/, Tokens::NameTag, next_state: :tag)

        root.add_rule Rule.new(/[^<\s]+/, Tokens::Text)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("plist", Plist)
  end
end
