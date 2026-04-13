module Rouge
  module Lexers
    class Forth < RegexLexer
      def self.tag_name : String
        "forth"
      end

      def self.title_text : String
        "Forth"
      end

      def self.desc_text : String
        "The Forth programming language"
      end

      def self.file_exts : Array(String)
        ["*.fth", "*.4th", "*.forth"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        # :comment_paren
        cp = State.new(:comment_paren)
        cp.add_rule Rule.new(/[^)]+/, Tokens::Comment)
        cp.add_rule Rule.new(/\)/, Tokens::Comment, pop: true)
        states[:comment_paren] = cp

        # :string
        str = State.new(:string)
        str.add_rule Rule.new(/[^"]+/, Tokens::StrDouble)
        str.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        states[:string] = str

        # :root
        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\\[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\((?=\s)/, Tokens::Comment, next_state: :comment_paren)

        # Strings: s" ..." and ." ..."
        root.add_rule Rule.new(/(?:s"|\."|c"|abort")/, Tokens::StrDouble, next_state: :string)

        # Keywords / control flow
        root.add_rule Rule.new(/\b(?:IF|ELSE|THEN|DO|LOOP|\+LOOP|BEGIN|UNTIL|WHILE|REPEAT|DOES>|CREATE|VARIABLE|CONSTANT|VALUE|TO|CELL\+|CELLS|ALLOT|HERE|DEFINE|IMMEDIATE|RECURSE|EXIT|POSTPONE|LITERAL)\b/i, Tokens::Keyword)

        # Colon definition
        root.add_rule Rule.new(/:/, Tokens::KeywordDeclaration)
        root.add_rule Rule.new(/;/, Tokens::KeywordDeclaration)

        # Stack words
        root.add_rule Rule.new(/\b(?:DUP|DROP|SWAP|OVER|ROT|PICK|ROLL|NIP|TUCK|2DUP|2DROP|2SWAP|2OVER)\b/i, Tokens::NameBuiltin)

        # Memory
        root.add_rule Rule.new(/\b(?:@|!|C@|C!|2@|2!|\+!)\b/, Tokens::NameBuiltin)

        # Math
        root.add_rule Rule.new(/\b(?:MOD|\/MOD|ABS|NEGATE|MIN|MAX|AND|OR|XOR|INVERT|LSHIFT|RSHIFT)\b/i, Tokens::NameBuiltin)

        # Numbers
        root.add_rule Rule.new(/-?\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/-?\d+/, Tokens::NumInteger)

        root.add_rule Rule.new(/[+\-*\/%<>=]+/, Tokens::Operator)
        root.add_rule Rule.new(/\S+/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("forth", Forth)
    RegexLexer.register("fth", Forth)
  end
end
