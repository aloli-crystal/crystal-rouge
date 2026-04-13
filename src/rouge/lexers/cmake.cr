module Rouge
  module Lexers
    class CMake < RegexLexer
      def self.tag_name : String
        "cmake"
      end

      def self.title_text : String
        "CMake"
      end

      def self.desc_text : String
        "CMake build system"
      end

      def self.file_exts : Array(String)
        ["CMakeLists.txt", "*.cmake"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(if else elseif endif foreach endforeach while endwhile function endfunction macro endmacro return set unset option project add_executable add_library target_link_libraries find_package include message install list string file cmake_minimum_required add_subdirectory target_include_directories target_compile_definitions target_compile_options enable_testing add_test configure_file)
        constants = %w(TRUE FALSE ON OFF YES NO)

        comment = State.new(:comment)
        comment.add_rule Rule.new(/[^\n]*/, Tokens::CommentSingle, pop: true)
        states[:comment] = comment

        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_double.add_rule Rule.new(/\$\{[^}]*\}/, Tokens::StrInterpol)
        string_double.add_rule Rule.new(/\$ENV\{[^}]*\}/, Tokens::StrInterpol)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\$]+/, Tokens::StrDouble)
        string_double.add_rule Rule.new(/\$/, Tokens::StrDouble)
        states[:string_double] = string_double

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/#/, Tokens::CommentSingle, next_state: :comment)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/\$\{[^}]*\}/, Tokens::NameVariable)
        root.add_rule Rule.new(/\$ENV\{[^}]*\}/, Tokens::NameVariable)
        root.add_rule Rule.new(/(?:#{constants.join("|")})\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/i, Tokens::Keyword)
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/<>=!]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("cmake", CMake)
  end
end
