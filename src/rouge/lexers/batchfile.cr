module Rouge
  module Lexers
    class Batchfile < RegexLexer
      def self.tag_name : String
        "batchfile"
      end

      def self.title_text : String
        "Batchfile"
      end

      def self.desc_text : String
        "Windows batch scripting"
      end

      def self.file_exts : Array(String)
        ["*.bat", "*.cmd"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(echo set if else for goto call exit rem pause cls dir copy move del mkdir rmdir type find sort more start title color prompt path pushd popd setlocal endlocal enabledelayedexpansion do in not exist defined equ neq lss leq gtr geq nul)

        comment = State.new(:comment)
        comment.add_rule Rule.new(/[^\n]*/, Tokens::CommentSingle, pop: true)
        states[:comment] = comment

        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/^[Rr][Ee][Mm]\b[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/^::[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/^:[a-zA-Z_]\w*/, Tokens::NameLabel)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/%~?[0-9]/, Tokens::NameVariable)
        root.add_rule Rule.new(/%[a-zA-Z_]\w*%/, Tokens::NameVariable)
        root.add_rule Rule.new(/![a-zA-Z_]\w*!/, Tokens::NameVariable)
        root.add_rule Rule.new(/%%[a-zA-Z]/, Tokens::NameVariable)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/i, Tokens::Keyword)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/<>=!&|^]+/, Tokens::Operator)
        root.add_rule Rule.new(/[@{}()\[\];,.]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("batchfile", Batchfile)
    RegexLexer.register("bat", Batchfile)
    RegexLexer.register("cmd", Batchfile)
  end
end
