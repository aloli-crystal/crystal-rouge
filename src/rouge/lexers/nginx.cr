module Rouge
  module Lexers
    class Nginx < RegexLexer
      def self.tag_name : String
        "nginx"
      end

      def self.title_text : String
        "Nginx"
      end

      def self.desc_text : String
        "Nginx configuration file (nginx.org)"
      end

      def self.file_exts : Array(String)
        ["*.conf", "*.nginx"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        # :whitespace
        ws = State.new(:whitespace)
        ws.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        states[:whitespace] = ws

        # :string_double
        sd = State.new(:string_double)
        sd.add_rule Rule.new(/\$[a-zA-Z_]\w*/, Tokens::NameVariable)
        sd.add_rule Rule.new(/\\./, Tokens::StrEscape)
        sd.add_rule Rule.new(/[^"\\$]+/, Tokens::StrDouble)
        sd.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        sd.add_rule Rule.new(/\$/, Tokens::StrDouble)
        states[:string_double] = sd

        # :string_single
        ss = State.new(:string_single)
        ss.add_rule Rule.new(/[^']+/, Tokens::StrSingle)
        ss.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        states[:string_single] = ss

        # :root
        root = State.new(:root)
        root.add_mixin :whitespace

        # Comments
        root.add_rule Rule.new(/#[^\n]*/, Tokens::CommentSingle)

        # Strings
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)

        # Variables
        root.add_rule Rule.new(/\$[a-zA-Z_]\w*/, Tokens::NameVariable)

        # Directives (keywords)
        root.add_rule Rule.new(/\b(?:server|location|upstream|http|events|stream|map|if|set|return|rewrite|proxy_pass|proxy_set_header|listen|server_name|root|index|try_files|error_page|access_log|error_log|include|worker_processes|worker_connections|sendfile|keepalive_timeout|gzip|ssl_certificate|ssl_certificate_key|ssl_protocols|ssl_ciphers|add_header|expires|client_max_body_size|fastcgi_pass|fastcgi_param|alias|deny|allow|auth_basic|log_format)\b/, Tokens::Keyword)

        # Numbers with units
        root.add_rule Rule.new(/\d+[kmgKMG]?\b/, Tokens::NumInteger)
        root.add_rule Rule.new(/\d+[smhdSMHD]\b/, Tokens::NumInteger)
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        # Regex location modifier
        root.add_rule Rule.new(/[~=^]/, Tokens::Operator)

        # Block delimiters and semicolons
        root.add_rule Rule.new(/[{}]/, Tokens::Punctuation)
        root.add_rule Rule.new(/;/, Tokens::Punctuation)

        # Unquoted values / identifiers
        root.add_rule Rule.new(/[a-zA-Z_][\w.\-\/]*/, Tokens::Name)

        # Paths and other values
        root.add_rule Rule.new(/\/[\w.\-\/]*/, Tokens::Name)

        # Other punctuation
        root.add_rule Rule.new(/[*:,]/, Tokens::Punctuation)

        states[:root] = root

        states
      end
    end

    RegexLexer.register("nginx", Nginx)
  end
end
