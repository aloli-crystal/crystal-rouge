module Rouge
  module Lexers
    class LiterateCoffeeScript < RegexLexer
      def self.tag_name : String
        "literate_coffeescript"
      end

      def self.title_text : String
        "Literate CoffeeScript"
      end

      def self.desc_text : String
        "Literate CoffeeScript (Markdown with CoffeeScript)"
      end

      def self.file_exts : Array(String)
        ["*.litcoffee"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        coffee_keywords = %w(if else unless switch when then for while until loop in of by to til do return break continue throw try catch finally class extends new delete typeof instanceof not and or is isnt true false null undefined void this super)

        # Code line state: entered after seeing indentation
        code_line = State.new(:code_line)
        code_line.add_rule Rule.new(/\n/, Tokens::TextWhitespace, pop: true)
        code_line.add_rule Rule.new(/#[^\n]*/, Tokens::CommentSingle)
        code_line.add_rule Rule.new(/"(?:[^"\\]|\\.)*"/, Tokens::StrDouble)
        code_line.add_rule Rule.new(/'(?:[^'\\]|\\.)*'/, Tokens::StrSingle)
        code_line.add_rule Rule.new(/(?:#{coffee_keywords.join("|")})\b/, Tokens::Keyword)
        code_line.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        code_line.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        code_line.add_rule Rule.new(/[a-zA-Z_$]\w*/, Tokens::Name)
        code_line.add_rule Rule.new(/[+\-*\/%&|^~<>=!?:]+/, Tokens::Operator)
        code_line.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        code_line.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        states[:code_line] = code_line

        root = State.new(:root)
        root.add_rule Rule.new(/(    |\t)/, Tokens::TextWhitespace, next_state: :code_line)
        root.add_rule Rule.new(/[^\n]+/, Tokens::GenericOutput)
        root.add_rule Rule.new(/\n/, Tokens::TextWhitespace)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("literate_coffeescript", LiterateCoffeeScript)
    RegexLexer.register("litcoffee", LiterateCoffeeScript)
  end
end
