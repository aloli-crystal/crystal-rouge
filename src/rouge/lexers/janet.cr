module Rouge
  module Lexers
    class Janet < RegexLexer
      def self.tag_name : String
        "janet"
      end

      def self.title_text : String
        "Janet"
      end

      def self.desc_text : String
        "Janet programming language"
      end

      def self.file_exts : Array(String)
        ["*.janet"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(def var fn do quote if splice while break set quasiquote unquote upscope let cond case match try catch loop for each repeat forever when unless coro defn defmacro import use require)
        constants = %w(nil true false)

        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/#[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/`[^`]*`/, Tokens::StrOther)
        root.add_rule Rule.new(/(?:#{constants.join("|")})\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/, Tokens::Keyword)
        root.add_rule Rule.new(/:[a-zA-Z_][\w-]*/, Tokens::StrSymbol)
        root.add_rule Rule.new(/-?\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/0[xX][0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/-?\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_!?.*+\-<>=][\w!?.*+\-<>=\/]*/, Tokens::Name)
        root.add_rule Rule.new(/[()'\[\]{}@~,;]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("janet", Janet)
  end
end
