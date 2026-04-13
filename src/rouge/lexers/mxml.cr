module Rouge
  module Lexers
    class MXML < RegexLexer
      def self.tag_name : String
        "mxml"
      end

      def self.title_text : String
        "MXML"
      end

      def self.desc_text : String
        "MXML (Flex/ActionScript markup)"
      end

      def self.file_exts : Array(String)
        ["*.mxml"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        # :script_block
        sb = State.new(:script_block)
        sb.add_rule Rule.new(/<\/mx:Script>|<\/fx:Script>/i, Tokens::NameTag, pop: true)
        sb.add_rule Rule.new(/[^<]+/, Tokens::Other)
        sb.add_rule Rule.new(/</, Tokens::Other)
        states[:script_block] = sb

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
        root.add_rule Rule.new(/<(?:mx|fx):Script[^>]*>/i, Tokens::NameTag, next_state: :script_block)
        root.add_rule Rule.new(/<\/[a-zA-Z_:][\w:.-]*>/, Tokens::NameTag)
        root.add_rule Rule.new(/<[a-zA-Z_:][\w:.-]*/, Tokens::NameTag, next_state: :tag)
        root.add_rule Rule.new(/[^<\s]+/, Tokens::Text)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("mxml", MXML)
  end
end
