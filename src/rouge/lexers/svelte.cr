module Rouge
  module Lexers
    class Svelte < RegexLexer
      def self.tag_name : String
        "svelte"
      end

      def self.title_text : String
        "Svelte"
      end

      def self.desc_text : String
        "Svelte component framework"
      end

      def self.file_exts : Array(String)
        ["*.svelte"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/<!--/, Tokens::CommentMultiline, next_state: :comment)
        # Svelte blocks
        root.add_rule Rule.new(/\{#(?:if|each|await|key)\b/, Tokens::Keyword)
        root.add_rule Rule.new(/\{\/(?:if|each|await|key)\}/, Tokens::Keyword)
        root.add_rule Rule.new(/\{:(?:else|then|catch)\b/, Tokens::Keyword)
        root.add_rule Rule.new(/\{@(?:html|debug|const)\b/, Tokens::Keyword)
        # Expressions
        root.add_rule Rule.new(/\{/, Tokens::Punctuation, next_state: :expression)
        # HTML tags
        root.add_rule Rule.new(/<script[^>]*>/, Tokens::NameTag)
        root.add_rule Rule.new(/<\/script>/, Tokens::NameTag)
        root.add_rule Rule.new(/<style[^>]*>/, Tokens::NameTag)
        root.add_rule Rule.new(/<\/style>/, Tokens::NameTag)
        root.add_rule Rule.new(/<\/?[a-zA-Z][\w-]*/, Tokens::NameTag)
        root.add_rule Rule.new(/\/>/, Tokens::NameTag)
        root.add_rule Rule.new(/>/, Tokens::NameTag)
        root.add_rule Rule.new(/on:[a-zA-Z]+/, Tokens::NameAttribute)
        root.add_rule Rule.new(/bind:[a-zA-Z]+/, Tokens::NameAttribute)
        root.add_rule Rule.new(/[a-zA-Z][\w-]*=/, Tokens::NameAttribute)
        root.add_rule Rule.new(/"[^"]*"/, Tokens::StrDouble)
        root.add_rule Rule.new(/'[^']*'/, Tokens::StrSingle)
        root.add_rule Rule.new(/\b(?:var|let|const|function|return|if|else|for|while|import|export|default|from|class|extends|new|this|async|await)\b/, Tokens::Keyword)
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/./, Tokens::Text)
        states[:root] = root

        comment = State.new(:comment)
        comment.add_rule Rule.new(/-->/, Tokens::CommentMultiline, pop: true)
        comment.add_rule Rule.new(/[^-]+/, Tokens::CommentMultiline)
        comment.add_rule Rule.new(/-/, Tokens::CommentMultiline)
        states[:comment] = comment

        expr = State.new(:expression)
        expr.add_rule Rule.new(/\}/, Tokens::Punctuation, pop: true)
        expr.add_rule Rule.new(/[^}]+/, Tokens::Text)
        states[:expression] = expr

        states
      end
    end

    RegexLexer.register("svelte", Svelte)
  end
end
