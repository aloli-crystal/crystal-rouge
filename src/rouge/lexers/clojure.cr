module Rouge
  module Lexers
    class Clojure < RegexLexer
      def self.tag_name : String
        "clojure"
      end

      def self.title_text : String
        "Clojure"
      end

      def self.desc_text : String
        "Clojure programming language"
      end

      def self.file_exts : Array(String)
        ["*.clj", "*.cljs", "*.cljc", "*.edn"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(def defn defn- defmacro defmethod defmulti defonce defprotocol defrecord defstruct deftype fn let letfn if if-let if-not do when when-let when-not when-first cond condp case loop for doseq dotimes recur ns require use import quote try catch finally throw)
        constants = %w(nil true false)

        comment = State.new(:comment)
        comment.add_rule Rule.new(/[^\n]*/, Tokens::CommentSingle, pop: true)
        states[:comment] = comment

        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/;/, Tokens::CommentSingle, next_state: :comment)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/\\(?:newline|space|tab|formfeed|backspace|return|.)/, Tokens::StrChar)
        root.add_rule Rule.new(/(?:#{constants.join("|")})\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/, Tokens::Keyword)
        root.add_rule Rule.new(/:[a-zA-Z_!?+\-*\/.><=%][a-zA-Z0-9_!?+\-*\/.><=%]*/, Tokens::StrSymbol)
        root.add_rule Rule.new(/#"/, Tokens::StrRegex)
        root.add_rule Rule.new(/\d+\.\d*/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+\/\d+/, Tokens::Num)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_!?+\-*\/.><=%][a-zA-Z0-9_!?+\-*\/.><=%]*/, Tokens::Name)
        root.add_rule Rule.new(/['`~@^]/, Tokens::Operator)
        root.add_rule Rule.new(/#?\{|\}|#?\(|\)|\[|\]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("clojure", Clojure)
    RegexLexer.register("clj", Clojure)
  end
end
