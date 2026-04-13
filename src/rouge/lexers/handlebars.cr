module Rouge
  module Lexers
    class Handlebars < RegexLexer
      def self.tag_name : String
        "handlebars"
      end

      def self.title_text : String
        "Handlebars"
      end

      def self.desc_text : String
        "Handlebars/Mustache templates"
      end

      def self.file_exts : Array(String)
        ["*.hbs", "*.handlebars", "*.mustache"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        helpers = %w(if else unless each with lookup log blockHelperMissing helperMissing)

        tag = State.new(:tag)
        tag.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        tag.add_rule Rule.new(/\}\}/, Tokens::Punctuation, pop: true)
        tag.add_rule Rule.new(/"(?:[^"\\]|\\.)*"/, Tokens::StrDouble)
        tag.add_rule Rule.new(/'(?:[^'\\]|\\.)*'/, Tokens::StrSingle)
        tag.add_rule Rule.new(/(?:#{helpers.join("|")})\b/, Tokens::Keyword)
        tag.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        tag.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        tag.add_rule Rule.new(/(?:true|false|null|undefined)\b/, Tokens::KeywordConstant)
        tag.add_rule Rule.new(/[a-zA-Z_][\w.\/-]*/, Tokens::Name)
        tag.add_rule Rule.new(/[=|]/, Tokens::Operator)
        tag.add_rule Rule.new(/[()]/, Tokens::Punctuation)
        states[:tag] = tag

        root = State.new(:root)
        root.add_rule Rule.new(/\{\{!--.*?--\}\}/m, Tokens::CommentMultiline)
        root.add_rule Rule.new(/\{\{![^}]*\}\}/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\{\{\{/, Tokens::Punctuation, next_state: :tag)
        root.add_rule Rule.new(/\{\{[#\/~>]?/, Tokens::Punctuation, next_state: :tag)
        root.add_rule Rule.new(/[^{]+/, Tokens::Text)
        root.add_rule Rule.new(/\{/, Tokens::Text)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("handlebars", Handlebars)
    RegexLexer.register("hbs", Handlebars)
  end
end
