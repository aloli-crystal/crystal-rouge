module Rouge
  module Lexers
    class AppleScript < RegexLexer
      def self.tag_name : String
        "applescript"
      end

      def self.title_text : String
        "AppleScript"
      end

      def self.desc_text : String
        "AppleScript scripting language"
      end

      def self.file_exts : Array(String)
        ["*.applescript", "*.scpt"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(
          about above after against and apart around as aside at back before
          beginning behind below beneath beside between but by considering
          contain contains continue copy div does eighth else end equal equals
          error every exit fifth first for fourth from front get given global if
          ignoring in instead into is it its last local me middle mod my ninth
          not of on onto or other out over prop property put ref reference repeat
          return returning script second set seventh since sixth some tell tenth
          than that the then third through thru timeout times to transaction
          try until where while whose with without
        )

        kw_pattern = keywords.join("|")

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/--.*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\(\*/, Tokens::CommentMultiline, next_state: :multiline_comment)
        root.add_rule Rule.new(Regex.new("\\b(?:#{kw_pattern})\\b", Regex::Options::IGNORE_CASE), Tokens::Keyword)
        root.add_rule Rule.new(/(?:true|false|missing value|null)\b/i, Tokens::KeywordConstant)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string)
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[+\-*\/&=<>^]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        states[:root] = root

        mc = State.new(:multiline_comment)
        mc.add_rule Rule.new(/\(\*/, Tokens::CommentMultiline, next_state: :multiline_comment)
        mc.add_rule Rule.new(/\*\)/, Tokens::CommentMultiline, pop: true)
        mc.add_rule Rule.new(/[^(*)+]+/, Tokens::CommentMultiline)
        mc.add_rule Rule.new(/[(*)]/, Tokens::CommentMultiline)
        states[:multiline_comment] = mc

        str = State.new(:string)
        str.add_rule Rule.new(/\\./, Tokens::StrEscape)
        str.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        str.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string] = str

        states
      end
    end

    RegexLexer.register("applescript", AppleScript)
  end
end
