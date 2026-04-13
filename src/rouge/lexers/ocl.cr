module Rouge
  module Lexers
    class OCL < RegexLexer
      def self.tag_name : String
        "ocl"
      end

      def self.title_text : String
        "OCL"
      end

      def self.desc_text : String
        "Object Constraint Language"
      end

      def self.file_exts : Array(String)
        ["*.ocl"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        ss = State.new(:string_single)
        ss.add_rule Rule.new(/\\./, Tokens::StrEscape)
        ss.add_rule Rule.new(/[^'\\]+/, Tokens::StrSingle)
        ss.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        states[:string_single] = ss

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/--[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)

        root.add_rule Rule.new(/\b(?:true|false|null|invalid)\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\b(?:Set|Bag|Sequence|OrderedSet|Collection|OclAny|OclVoid|OclInvalid|Integer|Real|Boolean|String|UnlimitedNatural)\b/, Tokens::KeywordType)
        root.add_rule Rule.new(/\b(?:context|inv|pre|post|body|init|derive|def|let|in|if|then|else|endif|and|or|not|xor|implies|self|result)\b/, Tokens::Keyword)

        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        root.add_rule Rule.new(/->|\./, Tokens::Operator)
        root.add_rule Rule.new(/[+\-*\/<>=!]+/, Tokens::Operator)
        root.add_rule Rule.new(/[(){};\[\],:]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("ocl", OCL)
  end
end
