module Rouge
  module Lexers
    class HOCON < RegexLexer
      def self.tag_name : String
        "hocon"
      end

      def self.title_text : String
        "HOCON"
      end

      def self.desc_text : String
        "HOCON configuration format"
      end

      def self.file_exts : Array(String)
        ["*.conf"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/#[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"""[\s\S]*?"""/, Tokens::StrDoc)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/include\b/, Tokens::Keyword)
        root.add_rule Rule.new(/(?:true|false|null)\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\$\{[^}]*\}/, Tokens::StrInterpol)
        root.add_rule Rule.new(/-?\d+\.\d*/, Tokens::NumFloat)
        root.add_rule Rule.new(/-?\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_][\w.-]*(?=\s*[=:{])/, Tokens::NameProperty)
        root.add_rule Rule.new(/[a-zA-Z_][\w.-]*/, Tokens::Str)
        root.add_rule Rule.new(/[=:+]/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\],]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("hocon", HOCON)
  end
end
