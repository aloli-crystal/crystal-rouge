module Rouge
  module Lexers
    class Nial < RegexLexer
      def self.tag_name : String
        "nial"
      end

      def self.title_text : String
        "Nial"
      end

      def self.desc_text : String
        "Nial programming language"
      end

      def self.file_exts : Array(String)
        ["*.ndf", "*.nial"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        sd = State.new(:string_double)
        sd.add_rule Rule.new(/\\./, Tokens::StrEscape)
        sd.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        sd.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        states[:string_double] = sd

        ss = State.new(:string_single)
        ss.add_rule Rule.new(/\\./, Tokens::StrEscape)
        ss.add_rule Rule.new(/[^'\\]+/, Tokens::StrSingle)
        ss.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        states[:string_single] = ss

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/%[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)

        root.add_rule Rule.new(/\b(?:true|false|null)\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\b(?:is|gets|op|operation|transformer|begin|end|if|then|else|elseif|endif|case|from|endcase|while|do|endwhile|for|with|endfor|repeat|until|endrepeat|loopbody|exit|execute|tell|fault|type|reshape|solitary|tally|link|list|floor|ceiling|abs|opposite|reciprocal|sqrt|sin|cos|tan|exp|ln|power|quotient|mod|sum|product|max|min|and|or|not)\b/, Tokens::Keyword)

        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        root.add_rule Rule.new(/[+\-*\/<>=!]+/, Tokens::Operator)
        root.add_rule Rule.new(/[(){};\[\],:]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("nial", Nial)
  end
end
