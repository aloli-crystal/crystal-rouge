module Rouge
  module Lexers
    class XPath < RegexLexer
      def self.tag_name : String
        "xpath"
      end

      def self.title_text : String
        "XPath"
      end

      def self.desc_text : String
        "XML Path Language"
      end

      def self.file_exts : Array(String)
        ["*.xpath"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)

        # Strings
        root.add_rule Rule.new(/"[^"]*"/, Tokens::StrDouble)
        root.add_rule Rule.new(/'[^']*'/, Tokens::StrSingle)

        # Axes
        root.add_rule Rule.new(/\b(?:ancestor-or-self|ancestor|attribute|child|descendant-or-self|descendant|following-sibling|following|namespace|parent|preceding-sibling|preceding|self)\s*::/, Tokens::NameBuiltin)

        # Operators
        root.add_rule Rule.new(/\b(?:and|or|not|div|mod)\b/, Tokens::OperatorWord)

        # Functions
        root.add_rule Rule.new(/\b(?:position|last|count|id|local-name|namespace-uri|name|string|concat|starts-with|contains|substring-before|substring-after|substring|string-length|normalize-space|translate|boolean|true|false|number|sum|floor|ceiling|round|text|comment|processing-instruction|node)\b/, Tokens::NameFunction)

        # Numbers
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        # Paths
        root.add_rule Rule.new(/\/\//, Tokens::Operator)
        root.add_rule Rule.new(/\//, Tokens::Operator)
        root.add_rule Rule.new(/\.\./, Tokens::Operator)
        root.add_rule Rule.new(/\./, Tokens::Operator)
        root.add_rule Rule.new(/@/, Tokens::Operator)

        # Comparison operators
        root.add_rule Rule.new(/[=!<>]+/, Tokens::Operator)
        root.add_rule Rule.new(/\|/, Tokens::Operator)

        # Predicates and punctuation
        root.add_rule Rule.new(/[\[\](),]/, Tokens::Punctuation)

        # Variables
        root.add_rule Rule.new(/\$[a-zA-Z_][a-zA-Z0-9_.-]*/, Tokens::NameVariable)

        # Node names / identifiers
        root.add_rule Rule.new(/[a-zA-Z_][a-zA-Z0-9_.-]*:[a-zA-Z_][a-zA-Z0-9_.-]*/, Tokens::NameTag)
        root.add_rule Rule.new(/\*/, Tokens::Operator)
        root.add_rule Rule.new(/[a-zA-Z_][a-zA-Z0-9_.-]*/, Tokens::Name)

        root.add_rule Rule.new(/./, Tokens::Text)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("xpath", XPath)
  end
end
