module Rouge
  module Lexers
    class Apache < RegexLexer
      def self.tag_name : String
        "apache"
      end

      def self.title_text : String
        "Apache"
      end

      def self.desc_text : String
        "Apache configuration files"
      end

      def self.file_exts : Array(String)
        [".htaccess", "httpd.conf", "apache.conf", "apache2.conf"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(ServerRoot Listen LoadModule Include IncludeOptional ServerName ServerAlias DocumentRoot DirectoryIndex Options AllowOverride Require Order Allow Deny ErrorLog CustomLog LogLevel LogFormat SetHandler AddHandler AddType RewriteEngine RewriteRule RewriteCond ProxyPass ProxyPassReverse SSLEngine SSLCertificateFile SSLCertificateKeyFile Redirect Alias ScriptAlias SetEnv Header ExpiresActive ExpiresByType ServerAdmin ErrorDocument AccessFileName TypesConfig HostnameLookups KeepAlive MaxKeepAliveRequests KeepAliveTimeout Timeout User Group)

        comment = State.new(:comment)
        comment.add_rule Rule.new(/[^\n]*/, Tokens::CommentSingle, pop: true)
        states[:comment] = comment

        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/#/, Tokens::CommentSingle, next_state: :comment)
        root.add_rule Rule.new(/<\/?\w+[^>]*>/, Tokens::NameTag)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/, Tokens::Keyword)
        root.add_rule Rule.new(/\b(?:On|Off|All|None)\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/<>=!]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("apache", Apache)
    RegexLexer.register("apacheconf", Apache)
  end
end
