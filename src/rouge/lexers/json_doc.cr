module Rouge
  module Lexers
    class JSONDoc < RegexLexer
      def self.tag_name : String
        "json_doc"
      end

      def self.title_text : String
        "JSONC"
      end

      def self.desc_text : String
        "JSON with comments (JSONC)"
      end

      def self.file_exts : Array(String)
        ["*.jsonc"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        comment_multi = State.new(:comment_multi)
        comment_multi.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        comment_multi.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        comment_multi.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment_multi] = comment_multi

        string = State.new(:string)
        string.add_rule Rule.new(/[^\\"]+/, Tokens::StrDouble)
        string.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        states[:string] = string

        name = State.new(:name)
        name.add_rule Rule.new(
          /("(?:\\.|[^"\\\n])*?")(\s*)(:)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::NameLabel, m[1]},
              {Tokens::TextWhitespace, m[2]},
              {Tokens::Punctuation, m[3]},
            ] of TokenPair
          }
        )
        states[:name] = name

        value = State.new(:value)
        value.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        value.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        value.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multi)
        value.add_rule Rule.new(/(?:true|false|null)\b/, Tokens::KeywordConstant)
        value.add_rule Rule.new(/-?(?:0|[1-9]\d*)\.\d+(?:e[+-]?\d+)?/i, Tokens::NumFloat)
        value.add_rule Rule.new(/-?(?:0|[1-9]\d*)(?:e[+-]?\d+)?/i, Tokens::NumInteger)
        value.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string)
        value.add_rule Rule.new(/\[/, Tokens::Punctuation, next_state: :array)
        value.add_rule Rule.new(/\{/, Tokens::Punctuation, next_state: :object)
        states[:value] = value

        array = State.new(:array)
        array.add_mixin :value
        array.add_rule Rule.new(/\]/, Tokens::Punctuation, pop: true)
        array.add_rule Rule.new(/,/, Tokens::Punctuation)
        states[:array] = array

        object = State.new(:object)
        object.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        object.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        object.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multi)
        object.add_mixin :name
        object.add_mixin :value
        object.add_rule Rule.new(/\}/, Tokens::Punctuation, pop: true)
        object.add_rule Rule.new(/,/, Tokens::Punctuation)
        states[:object] = object

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multi)
        root.add_rule Rule.new(/\{/, Tokens::Punctuation, next_state: :object)
        root.add_rule Rule.new(/\[/, Tokens::Punctuation, next_state: :array)
        root.add_mixin :name
        root.add_mixin :value
        root.add_rule Rule.new(/[\]\}]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("json_doc", JSONDoc)
  end
end
