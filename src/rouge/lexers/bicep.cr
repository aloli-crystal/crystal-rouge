module Rouge
  module Lexers
    class Bicep < RegexLexer
      def self.tag_name : String
        "bicep"
      end

      def self.title_text : String
        "Bicep"
      end

      def self.desc_text : String
        "Azure Bicep infrastructure language"
      end

      def self.file_exts : Array(String)
        ["*.bicep"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(resource module param var output type targetScope existing if for in import using metadata func)
        types = %w(string int bool object array)

        string_single = State.new(:string_single)
        string_single.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_single.add_rule Rule.new(/\$\{/, Tokens::StrInterpol, next_state: :interpolation)
        string_single.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        string_single.add_rule Rule.new(/[^'\\$]+/, Tokens::StrSingle)
        string_single.add_rule Rule.new(/\$/, Tokens::StrSingle)
        states[:string_single] = string_single

        interpolation = State.new(:interpolation)
        interpolation.add_rule Rule.new(/\}/, Tokens::StrInterpol, pop: true)
        interpolation.add_rule Rule.new(/[^}]+/, Tokens::Name)
        states[:interpolation] = interpolation

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_block)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/, Tokens::Keyword)
        root.add_rule Rule.new(/(?:#{types.join("|")})\b/, Tokens::KeywordType)
        root.add_rule Rule.new(/(?:true|false)\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/%=<>!&|^~?:]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        states[:root] = root

        comment_block = State.new(:comment_block)
        comment_block.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        comment_block.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        comment_block.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment_block] = comment_block

        states
      end
    end

    RegexLexer.register("bicep", Bicep)
  end
end
