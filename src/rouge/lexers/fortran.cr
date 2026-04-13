module Rouge
  module Lexers
    class Fortran < RegexLexer
      def self.tag_name : String
        "fortran"
      end

      def self.title_text : String
        "Fortran"
      end

      def self.desc_text : String
        "Fortran programming language"
      end

      def self.file_exts : Array(String)
        ["*.f90", "*.f95", "*.f03", "*.f08", "*.f", "*.for"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(program end subroutine function module use implicit none integer real double precision character logical complex dimension allocatable intent in out inout do enddo if then else endif select case endselect where forall return call write read print format open close stop contains type class interface procedure abstract extends public private protected allocate deallocate cycle exit data common equivalence block endblock associate endassociate critical endcritical)
        constants = %w(true false)
        types = %w(integer real double precision character logical complex)

        comment = State.new(:comment)
        comment.add_rule Rule.new(/[^\n]*/, Tokens::CommentSingle, pop: true)
        states[:comment] = comment

        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/""/, Tokens::StrEscape)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        string_single = State.new(:string_single)
        string_single.add_rule Rule.new(/''/, Tokens::StrEscape)
        string_single.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        string_single.add_rule Rule.new(/[^']+/, Tokens::StrSingle)
        states[:string_single] = string_single

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/!/, Tokens::CommentSingle, next_state: :comment)
        root.add_rule Rule.new(/^[Cc*][^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)
        root.add_rule Rule.new(/\.(?:#{constants.join("|")})\./i, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\.(?:eq|ne|lt|le|gt|ge|and|or|not|eqv|neqv)\./i, Tokens::OperatorWord)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/i, Tokens::Keyword)
        root.add_rule Rule.new(/\d+\.\d*(?:[eEdD][+-]?\d+)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+[eEdD][+-]?\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/<>=:]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,%&]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("fortran", Fortran)
    RegexLexer.register("f90", Fortran)
    RegexLexer.register("f95", Fortran)
  end
end
