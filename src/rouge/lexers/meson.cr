module Rouge
  module Lexers
    class Meson < RegexLexer
      def self.tag_name : String
        "meson"
      end

      def self.title_text : String
        "Meson"
      end

      def self.desc_text : String
        "Meson build system"
      end

      def self.file_exts : Array(String)
        ["meson.build", "meson_options.txt"]
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

        ts = State.new(:triple_string)
        ts.add_rule Rule.new(/'''/, Tokens::StrSingle, pop: true)
        ts.add_rule Rule.new(/[^']+/, Tokens::StrSingle)
        ts.add_rule Rule.new(/'/, Tokens::StrSingle)
        states[:triple_string] = ts

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/#[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/'''/, Tokens::StrSingle, next_state: :triple_string)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)

        root.add_rule Rule.new(/\b(?:true|false)\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\b(?:if|elif|else|endif|foreach|endforeach|break|continue)\b/, Tokens::Keyword)
        root.add_rule Rule.new(/\b(?:project|executable|library|shared_library|static_library|custom_target|run_target|test|benchmark|install_data|install_headers|install_subdir|subdir|subproject|dependency|declare_dependency|find_program|include_directories|configuration_data|configure_file|vcs_tag|environment|generator|get_option|option|error|warning|message|summary|add_project_arguments|add_project_link_arguments|assert|files|join_paths|meson)\b/, Tokens::NameBuiltin)

        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        root.add_rule Rule.new(/[+\-*\/<>=!]+/, Tokens::Operator)
        root.add_rule Rule.new(/[(){};\[\],:.]+/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("meson", Meson)
  end
end
