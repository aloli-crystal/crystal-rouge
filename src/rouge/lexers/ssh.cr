module Rouge
  module Lexers
    class SSH < RegexLexer
      def self.tag_name : String
        "ssh"
      end

      def self.title_text : String
        "SSH Config"
      end

      def self.desc_text : String
        "SSH client configuration"
      end

      def self.file_exts : Array(String)
        ["*.ssh_config"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)

        # Comments
        root.add_rule Rule.new(/#[^\n]*/, Tokens::CommentSingle)

        # Keywords with values
        root.add_rule Rule.new(
          /(Host|Match|HostName|User|Port|IdentityFile|IdentitiesOnly|ForwardAgent|ProxyJump|ProxyCommand|StrictHostKeyChecking|UserKnownHostsFile|ServerAliveInterval|ServerAliveCountMax|AddKeysToAgent|UseKeychain|PasswordAuthentication|PubkeyAuthentication|PreferredAuthentications|Compression|LogLevel|TCPKeepAlive|ConnectTimeout|Include|SendEnv|SetEnv|LocalForward|RemoteForward|DynamicForward|ControlMaster|ControlPath|ControlPersist)(\s+)([^\n]*)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::Keyword, m[1]},
              {Tokens::TextWhitespace, m[2]},
              {Tokens::Str, m[3]},
            ] of TokenPair
          }
        )

        # Any other key=value
        root.add_rule Rule.new(
          /([a-zA-Z][a-zA-Z0-9]*)(\s*=\s*)([^\n]*)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::NameAttribute, m[1]},
              {Tokens::Operator, m[2]},
              {Tokens::Str, m[3]},
            ] of TokenPair
          }
        )

        # Identifiers
        root.add_rule Rule.new(/[a-zA-Z_][a-zA-Z0-9_]*/, Tokens::Name)

        root.add_rule Rule.new(/./, Tokens::Text)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("ssh", SSH)
    RegexLexer.register("ssh_config", SSH)
  end
end
