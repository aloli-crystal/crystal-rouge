module Rouge
  module Lexers
    class Smarty < RegexLexer
      def self.tag_name : String
        "smarty"
      end

      def self.title_text : String
        "Smarty"
      end

      def self.desc_text : String
        "Smarty PHP template engine"
      end

      def self.file_exts : Array(String)
        ["*.tpl"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        root = State.new(:root)
        root.add_rule Rule.new(/\{\*/, Tokens::CommentMultiline, next_state: :comment)
        root.add_rule Rule.new(/\{\/(?:if|foreach|for|while|section|block|capture|function|strip|literal)\}/, Tokens::Keyword)
        root.add_rule Rule.new(/\{(?:if|else|elseif|foreach|for|while|section|block|capture|function|assign|include|extends|literal|strip|nocache)\b/, Tokens::Keyword)
        root.add_rule Rule.new(/\$[a-zA-Z_]\w*(?:\.\w+)*/, Tokens::NameVariable)
        root.add_rule Rule.new(/\{/, Tokens::Punctuation)
        root.add_rule Rule.new(/\}/, Tokens::Punctuation)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :double_string)
        root.add_rule Rule.new(/'[^']*'/, Tokens::StrSingle)
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[=!<>]+|&&|\|\|/, Tokens::Operator)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/./, Tokens::Text)
        states[:root] = root

        comment = State.new(:comment)
        comment.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        comment.add_rule Rule.new(/\*\}/, Tokens::CommentMultiline, pop: true)
        comment.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment] = comment

        ds = State.new(:double_string)
        ds.add_rule Rule.new(/\\./, Tokens::StrEscape)
        ds.add_rule Rule.new(/\$[a-zA-Z_]\w*/, Tokens::NameVariable)
        ds.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        ds.add_rule Rule.new(/[^"\\$]+/, Tokens::StrDouble)
        states[:double_string] = ds

        states
      end
    end

    RegexLexer.register("smarty", Smarty)
  end
end
