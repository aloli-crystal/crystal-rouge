module Rouge
  module Lexers
    class MoonScript < RegexLexer
      def self.tag_name : String
        "moonscript"
      end

      def self.title_text : String
        "MoonScript"
      end

      def self.desc_text : String
        "MoonScript language"
      end

      def self.file_exts : Array(String)
        ["*.moon"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        sd = State.new(:string_double)
        sd.add_rule Rule.new(/\\./, Tokens::StrEscape)
        sd.add_rule Rule.new(/#\{/, Tokens::StrInterpol)
        sd.add_rule Rule.new(/[^"\\#]+/, Tokens::StrDouble)
        sd.add_rule Rule.new(/[#]/, Tokens::StrDouble)
        sd.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        states[:string_double] = sd

        ss = State.new(:string_single)
        ss.add_rule Rule.new(/\\./, Tokens::StrEscape)
        ss.add_rule Rule.new(/[^'\\]+/, Tokens::StrSingle)
        ss.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        states[:string_single] = ss

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/--[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)

        root.add_rule Rule.new(/\b(?:true|false|nil)\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\b(?:class|extends|export|from|import|if|else|elseif|switch|when|unless|for|in|while|with|do|return|break|continue|not|and|or|local|using|super|self)\b/, Tokens::Keyword)

        root.add_rule Rule.new(/=>|->/, Tokens::Operator)
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        root.add_rule Rule.new(/[+\-*\/<>=!%^~]+/, Tokens::Operator)
        root.add_rule Rule.new(/[(){};\[\],:.@\\]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("moonscript", MoonScript)
    RegexLexer.register("moon", MoonScript)
  end
end
