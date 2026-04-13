module Rouge
  module Lexers
    class CoffeeScript < RegexLexer
      def self.tag_name : String
        "coffeescript"
      end

      def self.title_text : String
        "CoffeeScript"
      end

      def self.desc_text : String
        "CoffeeScript programming language"
      end

      def self.file_exts : Array(String)
        ["*.coffee"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(and break by catch class continue delete do each else extends finally for if in instanceof is isnt loop new no not of off on or own return super switch then this throw try typeof undefined unless until when while yes)
        constants = %w(true false null undefined)

        comment = State.new(:comment)
        comment.add_rule Rule.new(/[^\n]*/, Tokens::CommentSingle, pop: true)
        states[:comment] = comment

        comment_multi = State.new(:comment_multi)
        comment_multi.add_rule Rule.new(/###/, Tokens::CommentMultiline, pop: true)
        comment_multi.add_rule Rule.new(/[^#]+/, Tokens::CommentMultiline)
        comment_multi.add_rule Rule.new(/#/, Tokens::CommentMultiline)
        states[:comment_multi] = comment_multi

        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_double.add_rule Rule.new(/#\{[^}]*\}/, Tokens::StrInterpol)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\#]+/, Tokens::StrDouble)
        string_double.add_rule Rule.new(/#/, Tokens::StrDouble)
        states[:string_double] = string_double

        string_single = State.new(:string_single)
        string_single.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_single.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        string_single.add_rule Rule.new(/[^'\\]+/, Tokens::StrSingle)
        states[:string_single] = string_single

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/###/, Tokens::CommentMultiline, next_state: :comment_multi)
        root.add_rule Rule.new(/#/, Tokens::CommentSingle, next_state: :comment)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)
        root.add_rule Rule.new(/\/\/\/.*?\/\/\/[gimy]*/, Tokens::StrRegex)
        root.add_rule Rule.new(/\/(?!\s)[^\/\n]*\/[gimy]*/, Tokens::StrRegex)
        root.add_rule Rule.new(/(?:#{constants.join("|")})\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/, Tokens::Keyword)
        root.add_rule Rule.new(/=>|->/, Tokens::Operator)
        root.add_rule Rule.new(/0[xX][0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/\d+\.\d*(?:[eE][+-]?\d+)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/@[a-zA-Z_]\w*/, Tokens::NameVariableInstance)
        root.add_rule Rule.new(/[a-zA-Z_$]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/%&|^~<>=!?:]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("coffeescript", CoffeeScript)
    RegexLexer.register("coffee", CoffeeScript)
  end
end
