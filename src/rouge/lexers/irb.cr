module Rouge
  module Lexers
    class IRB < RegexLexer
      def self.tag_name : String
        "irb"
      end

      def self.title_text : String
        "IRB"
      end

      def self.desc_text : String
        "Ruby IRB/Pry console sessions"
      end

      def self.file_exts : Array(String)
        [] of String
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        ruby_keywords = %w(def end class module if else elsif unless while until for do begin rescue ensure raise return yield break next in when case then require include extend attr_reader attr_writer attr_accessor private protected public puts print)
        constants = %w(true false nil self)

        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_double.add_rule Rule.new(/#\{[^}]*\}/, Tokens::StrInterpol)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\#]+/, Tokens::StrDouble)
        string_double.add_rule Rule.new(/#/, Tokens::StrDouble)
        states[:string_double] = string_double

        string_single = State.new(:string_single)
        string_single.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_single.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        string_single.add_rule Rule.new(/[^'\\]+/, Tokens::StrSingle)
        states[:string_single] = string_single

        root = State.new(:root)
        root.add_rule Rule.new(/irb\([^)]*\):\d+:\d+>/, Tokens::GenericPrompt)
        root.add_rule Rule.new(/>>/, Tokens::GenericPrompt)
        root.add_rule Rule.new(/=>/, Tokens::GenericOutput)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/#[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)
        root.add_rule Rule.new(/:[a-zA-Z_]\w*/, Tokens::StrSymbol)
        root.add_rule Rule.new(/(?:#{constants.join("|")})\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/(?:#{ruby_keywords.join("|")})\b/, Tokens::Keyword)
        root.add_rule Rule.new(/@[a-zA-Z_]\w*/, Tokens::NameVariableInstance)
        root.add_rule Rule.new(/\$[a-zA-Z_]\w*/, Tokens::NameVariableGlobal)
        root.add_rule Rule.new(/[A-Z]\w*/, Tokens::NameClass)
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/%&|^~<>=!]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("irb", IRB)
    RegexLexer.register("pry", IRB)
  end
end
