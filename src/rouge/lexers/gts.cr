module Rouge
  module Lexers
    class GTS < RegexLexer
      def self.tag_name : String
        "gts"
      end

      def self.title_text : String
        "GTS"
      end

      def self.desc_text : String
        "Ember GTS (Glimmer TS) with template tags"
      end

      def self.file_exts : Array(String)
        ["*.gts"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(break case catch continue debugger default delete do else finally for function if in instanceof new return switch this throw try typeof var void while with let const class extends export import yield async await of type interface enum declare namespace abstract as implements private protected public static readonly)

        template = State.new(:template)
        template.add_rule Rule.new(/<\/template>/, Tokens::NameTag, pop: true)
        template.add_rule Rule.new(/\{\{/, Tokens::StrInterpol)
        template.add_rule Rule.new(/\}\}/, Tokens::StrInterpol)
        template.add_rule Rule.new(/<[a-zA-Z][\w.-]*/, Tokens::NameTag)
        template.add_rule Rule.new(/<\/[a-zA-Z][\w.-]*>/, Tokens::NameTag)
        template.add_rule Rule.new(/\/>/, Tokens::NameTag)
        template.add_rule Rule.new(/>/, Tokens::NameTag)
        template.add_rule Rule.new(/[a-zA-Z_][\w-]*(?==)/, Tokens::NameAttribute)
        template.add_rule Rule.new(/=/, Tokens::Operator)
        template.add_rule Rule.new(/"[^"]*"/, Tokens::StrDouble)
        template.add_rule Rule.new(/'[^']*'/, Tokens::StrSingle)
        template.add_rule Rule.new(/[^<>{}'"\s]+/, Tokens::Text)
        template.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        states[:template] = template

        comment_multi = State.new(:comment_multi)
        comment_multi.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        comment_multi.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        comment_multi.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment_multi] = comment_multi

        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        string_single = State.new(:string_single)
        string_single.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_single.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        string_single.add_rule Rule.new(/[^'\\]+/, Tokens::StrSingle)
        states[:string_single] = string_single

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multi)
        root.add_rule Rule.new(/<template>/, Tokens::NameTag, next_state: :template)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)
        root.add_rule Rule.new(/`[^`]*`/, Tokens::StrBacktick)
        root.add_rule Rule.new(/(?:true|false|null|undefined|NaN|Infinity)\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/, Tokens::Keyword)
        root.add_rule Rule.new(/0[xX][0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/\d+\.\d*(?:[eE][+-]?\d+)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_$]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/%&|^~<>=!?:]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("gts", GTS)
  end
end
