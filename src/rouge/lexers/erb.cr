module Rouge
  module Lexers
    class ERB < RegexLexer
      def self.tag_name : String
        "erb"
      end

      def self.title_text : String
        "ERB"
      end

      def self.desc_text : String
        "Embedded Ruby (ERB) templates"
      end

      def self.file_exts : Array(String)
        ["*.erb", "*.rhtml"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        root = State.new(:root)
        root.add_rule Rule.new(/<%#.*?%>/m, Tokens::CommentMultiline)
        root.add_rule Rule.new(/<%-?\s*=/, Tokens::StrInterpol, next_state: :erb_output)
        root.add_rule Rule.new(/<%-?/, Tokens::StrInterpol, next_state: :erb_code)
        root.add_rule Rule.new(/<!--/, Tokens::CommentMultiline, next_state: :html_comment)
        root.add_rule Rule.new(/<\/?[a-zA-Z][\w-]*/, Tokens::NameTag)
        root.add_rule Rule.new(/\/>/, Tokens::NameTag)
        root.add_rule Rule.new(/>/, Tokens::NameTag)
        root.add_rule Rule.new(/[a-zA-Z][\w-]*=/, Tokens::NameAttribute)
        root.add_rule Rule.new(/"[^"]*"/, Tokens::StrDouble)
        root.add_rule Rule.new(/'[^']*'/, Tokens::StrSingle)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/[^<]+/, Tokens::Text)
        root.add_rule Rule.new(/./, Tokens::Text)
        states[:root] = root

        erb_output = State.new(:erb_output)
        erb_output.add_rule Rule.new(/-?%>/, Tokens::StrInterpol, pop: true)
        erb_output.add_rule Rule.new(/[^%]+/, Tokens::Text)
        erb_output.add_rule Rule.new(/%/, Tokens::Text)
        states[:erb_output] = erb_output

        erb_code = State.new(:erb_code)
        erb_code.add_rule Rule.new(/-?%>/, Tokens::StrInterpol, pop: true)
        erb_code.add_rule Rule.new(/[^%]+/, Tokens::Text)
        erb_code.add_rule Rule.new(/%/, Tokens::Text)
        states[:erb_code] = erb_code

        html_comment = State.new(:html_comment)
        html_comment.add_rule Rule.new(/-->/, Tokens::CommentMultiline, pop: true)
        html_comment.add_rule Rule.new(/[^-]+/, Tokens::CommentMultiline)
        html_comment.add_rule Rule.new(/-/, Tokens::CommentMultiline)
        states[:html_comment] = html_comment

        states
      end
    end

    RegexLexer.register("erb", ERB)
    RegexLexer.register("rhtml", ERB)
  end
end
