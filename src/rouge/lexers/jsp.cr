module Rouge
  module Lexers
    class JSP < RegexLexer
      def self.tag_name : String
        "jsp"
      end

      def self.title_text : String
        "JSP"
      end

      def self.desc_text : String
        "JavaServer Pages"
      end

      def self.file_exts : Array(String)
        ["*.jsp"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        java_keywords = %w(abstract assert boolean break byte case catch char class const continue default do double else enum extends final finally float for goto if implements import instanceof int interface long native new package private protected public return short static strictfp super switch synchronized this throw throws transient try void volatile while)

        jsp_expr = State.new(:jsp_expr)
        jsp_expr.add_rule Rule.new(/%>/, Tokens::CommentPreproc, pop: true)
        jsp_expr.add_rule Rule.new(/(?:#{java_keywords.join("|")})\b/, Tokens::Keyword)
        jsp_expr.add_rule Rule.new(/"(?:[^"\\]|\\.)*"/, Tokens::StrDouble)
        jsp_expr.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        jsp_expr.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        jsp_expr.add_rule Rule.new(/[^%]+/, Tokens::Other)
        jsp_expr.add_rule Rule.new(/%/, Tokens::Other)
        states[:jsp_expr] = jsp_expr

        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/<%--|<!--/, Tokens::CommentMultiline, next_state: :html_comment)
        root.add_rule Rule.new(/<%[=!@]?/, Tokens::CommentPreproc, next_state: :jsp_expr)
        root.add_rule Rule.new(/<\/?(?:c|fmt|fn|sql|x):[a-zA-Z]+/, Tokens::NameTag)
        root.add_rule Rule.new(/<\/?[a-zA-Z][\w:-]*/, Tokens::NameTag)
        root.add_rule Rule.new(/\/>/, Tokens::NameTag)
        root.add_rule Rule.new(/>/, Tokens::NameTag)
        root.add_rule Rule.new(/[a-zA-Z_][\w:-]*(?==)/, Tokens::NameAttribute)
        root.add_rule Rule.new(/=/, Tokens::Operator)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'[^']*'/, Tokens::StrSingle)
        root.add_rule Rule.new(/\$\{[^}]*\}/, Tokens::StrInterpol)
        root.add_rule Rule.new(/[^<>$"'\s]+/, Tokens::Text)
        root.add_rule Rule.new(/./, Tokens::Text)
        states[:root] = root

        html_comment = State.new(:html_comment)
        html_comment.add_rule Rule.new(/--%>|-->/, Tokens::CommentMultiline, pop: true)
        html_comment.add_rule Rule.new(/[^-]+/, Tokens::CommentMultiline)
        html_comment.add_rule Rule.new(/-/, Tokens::CommentMultiline)
        states[:html_comment] = html_comment

        states
      end
    end

    RegexLexer.register("jsp", JSP)
  end
end
