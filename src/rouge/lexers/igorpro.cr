module Rouge
  module Lexers
    class IgorPro < RegexLexer
      def self.tag_name : String
        "igorpro"
      end

      def self.title_text : String
        "Igor Pro"
      end

      def self.desc_text : String
        "Igor Pro scientific programming"
      end

      def self.file_exts : Array(String)
        ["*.ipf"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(Function End if else elseif endif for endfor do while switch case default endswitch break continue return strswitch try catch endtry static override threadsafe Menu Proc Macro Window Picture Constant)
        types = %w(Variable String Wave NVAR SVAR DFREF WAVE Struct EndStructure)

        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/(?:#{types.join("|")})\b/, Tokens::KeywordType)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/, Tokens::Keyword)
        root.add_rule Rule.new(/0[xX][0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/\d+\.\d*(?:[eE][+-]?\d+)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/%&|^~<>=!]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("igorpro", IgorPro)
    RegexLexer.register("igor", IgorPro)
  end
end
