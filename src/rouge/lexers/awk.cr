module Rouge
  module Lexers
    class Awk < RegexLexer
      def self.tag_name : String
        "awk"
      end

      def self.title_text : String
        "Awk"
      end

      def self.desc_text : String
        "Awk programming language"
      end

      def self.file_exts : Array(String)
        ["*.awk"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(BEGIN END if else while for do break continue delete exit function getline next print printf return split sprintf sub gsub match length substr index tolower toupper system in)
        builtins = %w(NR NF FS RS OFS ORS FILENAME ARGC ARGV ENVIRON FNR OFMT RSTART RLENGTH SUBSEP)

        comment = State.new(:comment)
        comment.add_rule Rule.new(/[^\n]*/, Tokens::CommentSingle, pop: true)
        states[:comment] = comment

        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        regex = State.new(:regex)
        regex.add_rule Rule.new(/\\./, Tokens::StrEscape)
        regex.add_rule Rule.new(/\//, Tokens::StrRegex, pop: true)
        regex.add_rule Rule.new(/[^\/\\]+/, Tokens::StrRegex)
        states[:regex] = regex

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/#/, Tokens::CommentSingle, next_state: :comment)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/\/(?!=)/, Tokens::StrRegex, next_state: :regex)
        root.add_rule Rule.new(/\$\d+/, Tokens::NameVariable)
        root.add_rule Rule.new(/(?:#{builtins.join("|")})\b/, Tokens::NameBuiltin)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/, Tokens::Keyword)
        root.add_rule Rule.new(/\d+\.\d*(?:[eE][+-]?\d+)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/%^~<>=!&|?:]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("awk", Awk)
  end
end
