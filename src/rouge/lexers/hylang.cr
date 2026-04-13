module Rouge
  module Lexers
    class HyLang < RegexLexer
      def self.tag_name : String
        "hylang"
      end

      def self.title_text : String
        "Hy"
      end

      def self.desc_text : String
        "Hy (Lisp on Python)"
      end

      def self.file_exts : Array(String)
        ["*.hy"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(defn defmacro defclass do if cond when unless for while let setv import require try except raise return yield with as and or not in is lambda fn global nonlocal assert del pass break continue else elif finally)
        constants = %w(True False None)

        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/;[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/(?:#{constants.join("|")})\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/, Tokens::Keyword)
        root.add_rule Rule.new(/:[a-zA-Z_][\w-]*/, Tokens::StrSymbol)
        root.add_rule Rule.new(/-?\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/-?\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_!?.*+\-<>=][\w!?.*+\-<>=]*/, Tokens::Name)
        root.add_rule Rule.new(/[()'\[\]{}]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[~@^`#]/, Tokens::Operator)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("hylang", HyLang)
    RegexLexer.register("hy", HyLang)
  end
end
