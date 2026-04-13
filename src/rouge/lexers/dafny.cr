module Rouge
  module Lexers
    class Dafny < RegexLexer
      def self.tag_name : String
        "dafny"
      end

      def self.title_text : String
        "Dafny"
      end

      def self.desc_text : String
        "Dafny verification-aware programming language"
      end

      def self.file_exts : Array(String)
        ["*.dfy"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(abstract assert assume break by calc case class codatatype colemma constructor copredicate datatype decreases else ensures exists extends forall fresh function ghost if import in include inductive invariant iterator label lemma match method modifies modify module new newtype old opened predicate print provides reads refines requires return returns reveal static then this trait twostate type unchanged var while witness yield yields)

        comment_block = State.new(:comment_block)
        comment_block.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        comment_block.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        comment_block.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment_block] = comment_block

        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_block)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'[^'\\]'/, Tokens::StrChar)
        root.add_rule Rule.new(/'\\.'/, Tokens::StrChar)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/, Tokens::Keyword)
        root.add_rule Rule.new(/(?:true|false|null)\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\d+\.\d*/, Tokens::NumFloat)
        root.add_rule Rule.new(/0x[0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/%=<>!&|^~?:]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("dafny", Dafny)
  end
end
