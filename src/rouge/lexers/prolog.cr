module Rouge
  module Lexers
    class Prolog < RegexLexer
      def self.tag_name : String
        "prolog"
      end

      def self.title_text : String
        "Prolog"
      end

      def self.desc_text : String
        "Prolog logic programming language"
      end

      def self.file_exts : Array(String)
        ["*.pl", "*.pro"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        builtins = %w(
          is mod rem not true fail assert retract asserta assertz abolish
          findall bagof setof forall between succ plus arg functor copy_term
          term_variables numbervars predicate_property ground compound callable
          number integer float atom var nonvar read write writeln nl get_char
          put_char char_code atom_chars atom_codes atom_length atom_concat
          number_chars number_codes sub_atom char_type upcase_atom downcase_atom
        )

        bi_pattern = builtins.join("|")

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/%.*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :multiline_comment)
        root.add_rule Rule.new(Regex.new("\\b(?:#{bi_pattern})\\b"), Tokens::NameBuiltin)
        root.add_rule Rule.new(/[A-Z_]\w*/, Tokens::NameVariable)
        root.add_rule Rule.new(/'[^']*'/, Tokens::StrSingle)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string)
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/0x[0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/:-|\?-|-->|->|;|!|\|/, Tokens::Operator)
        root.add_rule Rule.new(/[=<>+\-*\/\\]+|=\.\.|\\=|=:=|=\\=|>=|=</, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\],.]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-z]\w*/, Tokens::Name)
        states[:root] = root

        mc = State.new(:multiline_comment)
        mc.add_rule Rule.new(/[^*\/]+/, Tokens::CommentMultiline)
        mc.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        mc.add_rule Rule.new(/[*\/]/, Tokens::CommentMultiline)
        states[:multiline_comment] = mc

        str = State.new(:string)
        str.add_rule Rule.new(/\\./, Tokens::StrEscape)
        str.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        str.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string] = str

        states
      end
    end

    RegexLexer.register("prolog", Prolog)
  end
end
