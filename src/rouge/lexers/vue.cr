module Rouge
  module Lexers
    class Vue < RegexLexer
      def self.tag_name : String
        "vue"
      end

      def self.title_text : String
        "Vue"
      end

      def self.desc_text : String
        "Vue.js Single File Components"
      end

      def self.file_exts : Array(String)
        ["*.vue"]
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
        root.add_rule Rule.new(/<template[^>]*>/, Tokens::NameTag)
        root.add_rule Rule.new(/<\/template>/, Tokens::NameTag)
        root.add_rule Rule.new(/<script[^>]*>/, Tokens::NameTag)
        root.add_rule Rule.new(/<\/script>/, Tokens::NameTag)
        root.add_rule Rule.new(/<style[^>]*>/, Tokens::NameTag)
        root.add_rule Rule.new(/<\/style>/, Tokens::NameTag)
        root.add_rule Rule.new(/<\/?[a-zA-Z][\w-]*/, Tokens::NameTag)
        root.add_rule Rule.new(/\/>/, Tokens::NameTag)
        root.add_rule Rule.new(/>/, Tokens::NameTag)
        root.add_rule Rule.new(/\{\{/, Tokens::StrInterpol, next_state: :interpolation)
        root.add_rule Rule.new(/v-(?:if|else|else-if|for|on|bind|model|show|slot|html|text|once|pre|cloak)\b/, Tokens::NameAttribute)
        root.add_rule Rule.new(/@[a-zA-Z][\w.-]*/, Tokens::NameAttribute)
        root.add_rule Rule.new(/:[a-zA-Z][\w.-]*/, Tokens::NameAttribute)
        root.add_rule Rule.new(/[a-zA-Z][\w-]*=/, Tokens::NameAttribute)
        root.add_rule Rule.new(/"[^"]*"/, Tokens::StrDouble)
        root.add_rule Rule.new(/'[^']*'/, Tokens::StrSingle)
        root.add_rule Rule.new(/\b(?:var|let|const|function|return|if|else|for|while|import|export|default|from|class|extends|new|this|async|await)\b/, Tokens::Keyword)
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[=!<>]+|&&|\|\|/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.:?]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/./, Tokens::Text)
        states[:root] = root

        comment = State.new(:comment)
        comment.add_rule Rule.new(/-->/, Tokens::CommentMultiline, pop: true)
        comment.add_rule Rule.new(/[^-]+/, Tokens::CommentMultiline)
        comment.add_rule Rule.new(/-/, Tokens::CommentMultiline)
        states[:comment] = comment

        interp = State.new(:interpolation)
        interp.add_rule Rule.new(/\}\}/, Tokens::StrInterpol, pop: true)
        interp.add_rule Rule.new(/[^}]+/, Tokens::StrInterpol)
        states[:interpolation] = interp

        states
      end
    end

    RegexLexer.register("vue", Vue)
  end
end
