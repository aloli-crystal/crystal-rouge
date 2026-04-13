module Rouge
  module Lexers
    class Jinja < RegexLexer
      def self.tag_name : String
        "jinja"
      end

      def self.title_text : String
        "Jinja2"
      end

      def self.desc_text : String
        "Jinja2 template engine"
      end

      def self.file_exts : Array(String)
        ["*.j2", "*.jinja", "*.jinja2"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(block endblock for endfor if elif else endif macro endmacro call endcall filter endfilter set extends include import from with without context raw endraw autoescape endautoescape trans endtrans pluralize do continue break as recursive scoped)
        constants = %w(true false none True False None)

        expr = State.new(:expr)
        expr.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        expr.add_rule Rule.new(/%\}/, Tokens::Punctuation, pop: true)
        expr.add_rule Rule.new(/\}\}/, Tokens::Punctuation, pop: true)
        expr.add_rule Rule.new(/"(?:[^"\\]|\\.)*"/, Tokens::StrDouble)
        expr.add_rule Rule.new(/'(?:[^'\\]|\\.)*'/, Tokens::StrSingle)
        expr.add_rule Rule.new(/(?:#{constants.join("|")})\b/, Tokens::KeywordConstant)
        expr.add_rule Rule.new(/(?:#{keywords.join("|")})\b/, Tokens::Keyword)
        expr.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        expr.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        expr.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        expr.add_rule Rule.new(/\|/, Tokens::Operator)
        expr.add_rule Rule.new(/[+\-*\/%~<>=!&|]+/, Tokens::Operator)
        expr.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        states[:expr] = expr

        root = State.new(:root)
        root.add_rule Rule.new(/\{#.*?#\}/m, Tokens::CommentMultiline)
        root.add_rule Rule.new(/\{\{/, Tokens::Punctuation, next_state: :expr)
        root.add_rule Rule.new(/\{%[-+]?/, Tokens::Punctuation, next_state: :expr)
        root.add_rule Rule.new(/[^{]+/, Tokens::Text)
        root.add_rule Rule.new(/\{/, Tokens::Text)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("jinja", Jinja)
    RegexLexer.register("jinja2", Jinja)
  end
end
