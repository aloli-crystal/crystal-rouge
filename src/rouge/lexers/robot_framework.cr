module Rouge
  module Lexers
    class RobotFramework < RegexLexer
      def self.tag_name : String
        "robot_framework"
      end

      def self.title_text : String
        "Robot Framework"
      end

      def self.desc_text : String
        "Robot Framework test automation"
      end

      def self.file_exts : Array(String)
        ["*.robot", "*.resource"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)

        # Section headers
        root.add_rule Rule.new(/^\*\*\*\s*(?:Settings|Test Cases|Keywords|Variables|Tasks)\s*\*\*\*/, Tokens::GenericHeading)

        # Comments
        root.add_rule Rule.new(/#[^\n]*/, Tokens::CommentSingle)

        # Variables
        root.add_rule Rule.new(/[\$@&%]\{[^}]*\}/, Tokens::NameVariable)

        # Settings keywords
        root.add_rule Rule.new(/\b(?:Library|Resource|Variables|Suite Setup|Suite Teardown|Test Setup|Test Teardown|Test Template|Force Tags|Default Tags)\b/, Tokens::KeywordNamespace)

        # Bracket settings
        root.add_rule Rule.new(/\[(?:Documentation|Tags|Setup|Teardown|Template|Arguments|Return)\]/, Tokens::KeywordDeclaration)

        # Control flow keywords
        root.add_rule Rule.new(/\b(?:FOR|IN|END|IF|ELSE IF|ELSE|TRY|EXCEPT|FINALLY|WHILE|BREAK|CONTINUE|RETURN)\b/, Tokens::Keyword)

        # Strings
        root.add_rule Rule.new(/"[^"]*"/, Tokens::StrDouble)

        # Numbers
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        # Separators (two or more spaces, or tab)
        root.add_rule Rule.new(/  +|\t/, Tokens::TextWhitespace)

        # Other text
        root.add_rule Rule.new(/[^\s#\$@&%"\[\]*]+/, Tokens::Text)
        root.add_rule Rule.new(/./, Tokens::Text)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("robot_framework", RobotFramework)
    RegexLexer.register("robot", RobotFramework)
  end
end
