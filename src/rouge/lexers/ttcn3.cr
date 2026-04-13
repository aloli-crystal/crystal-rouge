module Rouge
  module Lexers
    class TTCN3 < RegexLexer
      def self.tag_name : String
        "ttcn3"
      end

      def self.title_text : String
        "TTCN-3"
      end

      def self.desc_text : String
        "TTCN-3 testing language"
      end

      def self.file_exts : Array(String)
        ["*.ttcn", "*.ttcn3"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)

        # Comments
        root.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :multiline_comment)

        # Strings
        root.add_rule Rule.new(/"(?:\\.|[^"\\])*"/, Tokens::StrDouble)

        # Declaration keywords
        root.add_rule Rule.new(/\b(?:module|import|from|type|record|set|union|enumerated|component|port|function|testcase|altstep|template|control|const|var|timer|group)\b/, Tokens::KeywordDeclaration)

        # Flow keywords
        root.add_rule Rule.new(/\b(?:if|else|select|case|for|while|do|alt|interleave|return|goto|label|break|continue|activate|deactivate)\b/, Tokens::Keyword)

        # Communication keywords
        root.add_rule Rule.new(/\b(?:execute|start|stop|running|alive|create|connect|disconnect|map|unmap|send|receive|trigger|call|reply|raise|catch|check|getcall|getreply)\b/, Tokens::NameBuiltin)

        # Verdict/constants
        root.add_rule Rule.new(/\b(?:pass|fail|inconc|none|error|true|false|null|omit)\b/, Tokens::KeywordConstant)

        # Verdict functions
        root.add_rule Rule.new(/\b(?:log|match|valueof|setverdict|getverdict|action|verdicttype)\b/, Tokens::NameBuiltin)

        # Special keywords
        root.add_rule Rule.new(/\b(?:language|with|encode|display|extension|variant|optional|present|ifpresent|length|pattern|complement|superset|subset|permutation|all|any|value|sender|to|system|mtc|self)\b/, Tokens::KeywordReserved)

        # Numbers
        root.add_rule Rule.new(/0x[0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        # Operators
        root.add_rule Rule.new(/[+\-*\/%=!<>&|^~?:]+/, Tokens::Operator)
        root.add_rule Rule.new(/\.\./, Tokens::Operator)

        # Punctuation
        root.add_rule Rule.new(/[{}\[\]();,.]/, Tokens::Punctuation)

        # Identifiers
        root.add_rule Rule.new(/[a-zA-Z_][a-zA-Z0-9_]*/, Tokens::Name)

        root.add_rule Rule.new(/./, Tokens::Text)

        states[:root] = root

        mc = State.new(:multiline_comment)
        mc.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        mc.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        mc.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:multiline_comment] = mc

        states
      end
    end

    RegexLexer.register("ttcn3", TTCN3)
  end
end
