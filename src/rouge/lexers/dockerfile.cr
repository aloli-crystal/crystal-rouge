module Rouge
  module Lexers
    class Dockerfile < RegexLexer
      def self.tag_name : String
        "dockerfile"
      end

      def self.title_text : String
        "Dockerfile"
      end

      def self.desc_text : String
        "Dockerfile syntax for building container images"
      end

      def self.file_exts : Array(String)
        ["Dockerfile", "*.dockerfile"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        instructions = %w(
          FROM RUN CMD LABEL MAINTAINER EXPOSE ENV ADD COPY ENTRYPOINT
          VOLUME USER WORKDIR ARG ONBUILD STOPSIGNAL HEALTHCHECK SHELL
        )

        instr_pattern = instructions.join("|")

        # :string_double
        sd = State.new(:string_double)
        sd.add_rule Rule.new(/\\./, Tokens::StrEscape)
        sd.add_rule Rule.new(/\$\{[^}]+\}/, Tokens::NameVariable)
        sd.add_rule Rule.new(/\$[a-zA-Z_]\w*/, Tokens::NameVariable)
        sd.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        sd.add_rule Rule.new(/[^"\\$]+/, Tokens::StrDouble)
        sd.add_rule Rule.new(/\$/, Tokens::StrDouble)
        states[:string_double] = sd

        # :string_single
        ss = State.new(:string_single)
        ss.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        ss.add_rule Rule.new(/[^']+/, Tokens::StrSingle)
        states[:string_single] = ss

        # :root
        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)

        # Comments
        root.add_rule Rule.new(/#.*$/, Tokens::CommentSingle)

        # Instructions (case-insensitive)
        root.add_rule Rule.new(Regex.new("^\\s*(?:#{instr_pattern})\\b", Regex::Options::IGNORE_CASE), Tokens::Keyword)

        # Key=value pairs
        root.add_rule Rule.new(
          /([a-zA-Z_]\w*)(=)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::NameAttribute, m[1]},
              {Tokens::Operator, m[2]},
            ] of TokenPair
          }
        )

        # Variables
        root.add_rule Rule.new(/\$\{[^}]+\}/, Tokens::NameVariable)
        root.add_rule Rule.new(/\$[a-zA-Z_]\w*/, Tokens::NameVariable)

        # Strings
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)

        # Numbers
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        # Flags
        root.add_rule Rule.new(/--[a-zA-Z_][\w-]*/, Tokens::NameAttribute)

        # Punctuation
        root.add_rule Rule.new(/[\\:@]/, Tokens::Punctuation)

        # Generic text
        root.add_rule Rule.new(/[^\s#"'$\\:@=]+/, Tokens::Name)

        states[:root] = root

        states
      end
    end

    RegexLexer.register("dockerfile", Dockerfile)
    RegexLexer.register("docker", Dockerfile)
  end
end
