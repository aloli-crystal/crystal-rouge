module Rouge
  module Lexers
    class Terraform < RegexLexer
      def self.tag_name : String
        "terraform"
      end

      def self.title_text : String
        "Terraform"
      end

      def self.desc_text : String
        "HashiCorp Terraform / HCL"
      end

      def self.file_exts : Array(String)
        ["*.tf", "*.hcl"]
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

        # :comment_multiline
        comment_ml = State.new(:comment_multiline)
        comment_ml.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        comment_ml.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        comment_ml.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment_multiline] = comment_ml

        # :string_double
        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_double.add_rule Rule.new(/\$\{/, Tokens::StrInterpol, next_state: :interpolation)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\$]+/, Tokens::StrDouble)
        string_double.add_rule Rule.new(/\$/, Tokens::StrDouble)
        states[:string_double] = string_double

        # :interpolation
        interpolation = State.new(:interpolation)
        interpolation.add_rule Rule.new(/\}/, Tokens::StrInterpol, pop: true)
        interpolation.add_rule Rule.new(/\b(?:true|false|null)\b/, Tokens::KeywordConstant)
        interpolation.add_rule Rule.new(/\b(?:file|templatefile|lookup|element|length|join|split|format|replace|lower|upper|title|trimspace|concat|flatten|merge|keys|values|tolist|toset|tomap|try|can|coalesce|coalescelist|contains|distinct|chunklist|range|cidrsubnet|cidrhost|base64encode|base64decode|jsonencode|jsondecode|yamlencode|yamldecode|md5|sha1|sha256|sha512|uuid|timestamp|formatdate|timeadd|max|min|abs|ceil|floor|log|pow|signum|parseint)\s*(?=\()/, Tokens::NameBuiltin)
        interpolation.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        interpolation.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        interpolation.add_rule Rule.new(/"[^"]*"/, Tokens::StrDouble)
        interpolation.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        interpolation.add_rule Rule.new(/[.,()\[\]]/, Tokens::Punctuation)
        interpolation.add_rule Rule.new(/[+\-*\/%=<>!&|?:]/, Tokens::Operator)
        interpolation.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        states[:interpolation] = interpolation

        # :heredoc
        heredoc = State.new(:heredoc)
        heredoc.add_rule Rule.new(/\$\{/, Tokens::StrInterpol, next_state: :interpolation)
        heredoc.add_rule Rule.new(/[^\n$]+/, Tokens::StrHeredoc)
        heredoc.add_rule Rule.new(/\$/, Tokens::StrHeredoc)
        heredoc.add_rule Rule.new(/\n/, Tokens::StrHeredoc)
        states[:heredoc] = heredoc

        # :root
        root = State.new(:root)
        root.add_mixin :whitespace
        # Comments
        root.add_rule Rule.new(/#[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multiline)
        # Heredoc
        root.add_rule Rule.new(
          /(<<-?)([\w]+)\s*\n([\s\S]*?\n\s*\2)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::Operator, m[1]},
              {Tokens::NameLabel, m[2]},
              {Tokens::StrHeredoc, m[3]},
            ] of TokenPair
          }
        )
        # Strings
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        # Keywords
        root.add_rule Rule.new(/\b(?:resource|data|variable|output|module|provider|terraform|locals|backend|provisioner|connection|lifecycle|depends_on|count|for_each|dynamic|content)\b/, Tokens::Keyword)
        # Constants
        root.add_rule Rule.new(/\b(?:true|false|null)\b/, Tokens::KeywordConstant)
        # Functions
        root.add_rule Rule.new(/\b(?:file|templatefile|lookup|element|length|join|split|format|replace|lower|upper|title|trimspace|concat|flatten|merge|keys|values|tolist|toset|tomap|try|can|coalesce|coalescelist|contains|distinct|chunklist|range|cidrsubnet|cidrhost|base64encode|base64decode|jsonencode|jsondecode|yamlencode|yamldecode|md5|sha1|sha256|sha512|uuid|timestamp|formatdate|timeadd|max|min|abs|ceil|floor|log|pow|signum|parseint)\s*(?=\()/, Tokens::NameBuiltin)
        # Numbers
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        # Block type names (capitalized or after keywords)
        root.add_rule Rule.new(/\b[A-Z][a-zA-Z0-9_]*\b/, Tokens::NameClass)
        # Operators
        root.add_rule Rule.new(/[=!<>+\-*\/%?:]/, Tokens::Operator)
        # Punctuation
        root.add_rule Rule.new(/[{}()\[\],.]/, Tokens::Punctuation)
        # Identifiers
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("terraform", Terraform)
    RegexLexer.register("tf", Terraform)
    RegexLexer.register("hcl", Terraform)
  end
end
