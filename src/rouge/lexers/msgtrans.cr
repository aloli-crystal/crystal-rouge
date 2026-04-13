module Rouge
  module Lexers
    class MsgTrans < RegexLexer
      def self.tag_name : String
        "msgtrans"
      end

      def self.title_text : String
        "MsgTrans"
      end

      def self.desc_text : String
        "RISC OS Message Trans file"
      end

      def self.file_exts : Array(String)
        ["*.Messages"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/#[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(
          /([a-zA-Z_][\w.]*)(:)([^\n]*)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::NameLabel, m[1]},
              {Tokens::Punctuation, m[2]},
              {Tokens::Str, m[3]},
            ] of TokenPair
          }
        )
        root.add_rule Rule.new(/[^\n]+/, Tokens::Text)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("msgtrans", MsgTrans)
  end
end
