module Rouge
  module Lexers
    class Elm < RegexLexer
      def self.tag_name : String
        "elm"
      end

      def self.title_text : String
        "Elm"
      end

      def self.desc_text : String
        "Elm programming language"
      end

      def self.file_exts : Array(String)
        ["*.elm"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(
          if then else case of let in type alias module where import exposing as
          port effect command subscription
        )

        kw_pattern = keywords.join("|")

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\{-/, Tokens::CommentMultiline, next_state: :multiline_comment)
        root.add_rule Rule.new(/--.*/, Tokens::CommentSingle)
        root.add_rule Rule.new(Regex.new("\\b(?:#{kw_pattern})\\b"), Tokens::Keyword)
        root.add_rule Rule.new(/(?:True|False)\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/"""/, Tokens::StrDoc, next_state: :triple_string)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string)
        root.add_rule Rule.new(/'[^'\\]'|'\\.'/, Tokens::StrChar)
        root.add_rule Rule.new(/\|>|<\||>>|<<|::|\+\+|&&|\|\|/, Tokens::Operator)
        root.add_rule Rule.new(/[+\-*\/=<>!|&^]+/, Tokens::Operator)
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/0x[0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/[{}()\[\];,.:_\\]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[A-Z][a-zA-Z0-9_]*/, Tokens::NameClass)
        root.add_rule Rule.new(/[a-z_][a-zA-Z0-9_]*/, Tokens::Name)
        states[:root] = root

        mc = State.new(:multiline_comment)
        mc.add_rule Rule.new(/\{-/, Tokens::CommentMultiline, next_state: :multiline_comment)
        mc.add_rule Rule.new(/-\}/, Tokens::CommentMultiline, pop: true)
        mc.add_rule Rule.new(/[^{}-]+/, Tokens::CommentMultiline)
        mc.add_rule Rule.new(/[{}-]/, Tokens::CommentMultiline)
        states[:multiline_comment] = mc

        str = State.new(:string)
        str.add_rule Rule.new(/\\./, Tokens::StrEscape)
        str.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        str.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string] = str

        ts = State.new(:triple_string)
        ts.add_rule Rule.new(/"""/, Tokens::StrDoc, pop: true)
        ts.add_rule Rule.new(/\\./, Tokens::StrEscape)
        ts.add_rule Rule.new(/[^"\\]+/, Tokens::StrDoc)
        ts.add_rule Rule.new(/"/, Tokens::StrDoc)
        states[:triple_string] = ts

        states
      end
    end

    RegexLexer.register("elm", Elm)
  end
end
