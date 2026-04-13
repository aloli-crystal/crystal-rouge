module Rouge
  module Lexers
    class EPP < RegexLexer
      def self.tag_name : String
        "epp"
      end

      def self.title_text : String
        "EPP"
      end

      def self.desc_text : String
        "Puppet EPP (Embedded Puppet) templates"
      end

      def self.file_exts : Array(String)
        ["*.epp"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        epp_code = State.new(:epp_code)
        epp_code.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        epp_code.add_rule Rule.new(/-?%>/, Tokens::CommentPreproc, pop: true)
        epp_code.add_rule Rule.new(/"(?:\\.|[^"\\])*"/, Tokens::StrDouble)
        epp_code.add_rule Rule.new(/'(?:\\.|[^'\\])*'/, Tokens::StrSingle)
        epp_code.add_rule Rule.new(/\b(?:if|elsif|else|unless|case|each|slice|include|class|define|node|inherits|contain|require|ensure|present|absent|file|package|service|exec|notify|subscribe|before|require|true|false|undef)\b/, Tokens::Keyword)
        epp_code.add_rule Rule.new(/\$[a-zA-Z_][a-zA-Z0-9_]*(?:::[a-zA-Z_][a-zA-Z0-9_]*)*/, Tokens::NameVariable)
        epp_code.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        epp_code.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        epp_code.add_rule Rule.new(/[+\-*\/%=!<>&|?:]+/, Tokens::Operator)
        epp_code.add_rule Rule.new(/[{}\[\]();,.]/, Tokens::Punctuation)
        epp_code.add_rule Rule.new(/[a-zA-Z_][a-zA-Z0-9_]*/, Tokens::Name)
        epp_code.add_rule Rule.new(/./, Tokens::Text)
        states[:epp_code] = epp_code

        root = State.new(:root)

        # Comment tags <%# ... %>
        root.add_rule Rule.new(/<%#/, Tokens::CommentMultiline, next_state: :epp_comment)

        # Expression tags <%= ... %>
        root.add_rule Rule.new(/<%-?=/, Tokens::CommentPreproc, next_state: :epp_code)

        # Code tags <% ... %>
        root.add_rule Rule.new(/<%-?/, Tokens::CommentPreproc, next_state: :epp_code)

        # Plain text
        root.add_rule Rule.new(/[^<]+/, Tokens::Text)
        root.add_rule Rule.new(/</, Tokens::Text)

        states[:root] = root

        ec = State.new(:epp_comment)
        ec.add_rule Rule.new(/-?%>/, Tokens::CommentMultiline, pop: true)
        ec.add_rule Rule.new(/[^%]+/, Tokens::CommentMultiline)
        ec.add_rule Rule.new(/%/, Tokens::CommentMultiline)
        states[:epp_comment] = ec

        states
      end
    end

    RegexLexer.register("epp", EPP)
  end
end
