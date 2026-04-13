module Rouge
  module Lexers
    class Systemd < RegexLexer
      def self.tag_name : String
        "systemd"
      end

      def self.title_text : String
        "Systemd"
      end

      def self.desc_text : String
        "Systemd unit file configuration"
      end

      def self.file_exts : Array(String)
        ["*.service", "*.timer", "*.socket", "*.mount", "*.path", "*.scope", "*.slice"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        value = State.new(:value)
        value.add_rule Rule.new(/[ \t]+/, Tokens::TextWhitespace)
        value.add_rule Rule.new(/[#;][^\n]*/, Tokens::CommentSingle, pop: true)
        value.add_rule Rule.new(/"[^"]*"/, Tokens::StrDouble)
        value.add_rule Rule.new(/\b(?:true|false|yes|no|on|off)\b/i, Tokens::KeywordConstant)
        value.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        value.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        value.add_rule Rule.new(/%[a-zA-Z]/, Tokens::NameVariable)
        value.add_rule Rule.new(/\n/, Tokens::TextWhitespace, pop: true)
        value.add_rule Rule.new(/[^\s#;"]+/, Tokens::Str)
        states[:value] = value

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)

        # Comments
        root.add_rule Rule.new(/[#;][^\n]*/, Tokens::CommentSingle)

        # Sections
        root.add_rule Rule.new(
          /(\[)(Unit|Service|Install|Timer|Socket|Mount|Automount|Swap|Path|Slice|Scope)(\])/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::Punctuation, m[1]},
              {Tokens::NameNamespace, m[2]},
              {Tokens::Punctuation, m[3]},
            ] of TokenPair
          }
        )

        # Directives
        root.add_rule Rule.new(
          /(Description|After|Before|Requires|Wants|Type|ExecStart|ExecStop|ExecReload|Restart|RestartSec|User|Group|WorkingDirectory|Environment|EnvironmentFile|WantedBy|RequiredBy|Also|Alias|TimeoutStartSec|TimeoutStopSec|KillMode|RemainAfterExit|StandardOutput|StandardError|SyslogIdentifier|LimitNOFILE|MemoryLimit|CPUQuota|PrivateTmp|ProtectSystem|ProtectHome|ReadOnlyDirectories|NoNewPrivileges|CapabilityBoundingSet)(\s*=)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::NameAttribute, m[1]},
              {Tokens::Operator, m[2]},
            ] of TokenPair
          },
          next_state: :value
        )

        # Generic key=value
        root.add_rule Rule.new(
          /([a-zA-Z][a-zA-Z0-9_]*)(\s*=)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::NameAttribute, m[1]},
              {Tokens::Operator, m[2]},
            ] of TokenPair
          },
          next_state: :value
        )

        root.add_rule Rule.new(/./, Tokens::Text)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("systemd", Systemd)
  end
end
