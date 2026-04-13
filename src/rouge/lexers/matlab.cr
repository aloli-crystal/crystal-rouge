module Rouge
  module Lexers
    class Matlab < RegexLexer
      def self.tag_name : String
        "matlab"
      end

      def self.title_text : String
        "MATLAB"
      end

      def self.desc_text : String
        "MATLAB / GNU Octave"
      end

      def self.file_exts : Array(String)
        ["*.m"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(
          break case catch classdef continue else elseif end enumeration events
          for function global if methods otherwise parfor persistent properties
          return spmd switch try while
        )

        kw_pattern = keywords.join("|")

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/%\{/, Tokens::CommentMultiline, next_state: :block_comment)
        root.add_rule Rule.new(/%.*/, Tokens::CommentSingle)
        root.add_rule Rule.new(Regex.new("\\b(?:#{kw_pattern})\\b"), Tokens::Keyword)
        root.add_rule Rule.new(/(?:true|false|inf|Inf|NaN|nan|pi|eps)\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string)
        root.add_rule Rule.new(/"[^"]*"/, Tokens::StrDouble)
        root.add_rule Rule.new(/\d+\.\d*(?:e[+-]?\d+)?/i, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+e[+-]?\d+/i, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/0x[0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/\.\*|\.\/|\.\^|\.'+|[+\-*\/\\^=<>~&|]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.:@]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        states[:root] = root

        bc = State.new(:block_comment)
        bc.add_rule Rule.new(/%\}/, Tokens::CommentMultiline, pop: true)
        bc.add_rule Rule.new(/[^%]+/, Tokens::CommentMultiline)
        bc.add_rule Rule.new(/%/, Tokens::CommentMultiline)
        states[:block_comment] = bc

        str = State.new(:string)
        str.add_rule Rule.new(/''/, Tokens::StrEscape)
        str.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        str.add_rule Rule.new(/[^']+/, Tokens::StrSingle)
        states[:string] = str

        states
      end
    end

    RegexLexer.register("matlab", Matlab)
    RegexLexer.register("octave", Matlab)
  end
end
