module Rouge
  module Lexers
    class Varnish < RegexLexer
      def self.tag_name : String
        "varnish"
      end

      def self.title_text : String
        "Varnish VCL"
      end

      def self.desc_text : String
        "Varnish Configuration Language"
      end

      def self.file_exts : Array(String)
        ["*.vcl"]
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
        root.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/#[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :multiline_comment)

        # Long strings {"..."}
        root.add_rule Rule.new(/\{"/, Tokens::StrDouble, next_state: :long_string)

        # Regular strings
        root.add_rule Rule.new(/"(?:\\.|[^"\\])*"/, Tokens::StrDouble)

        # Declaration keywords
        root.add_rule Rule.new(/\b(?:acl|backend|director|import|include|new|probe|sub)\b/, Tokens::KeywordDeclaration)

        # Subroutine names
        root.add_rule Rule.new(/\b(?:vcl_recv|vcl_pipe|vcl_pass|vcl_hash|vcl_hit|vcl_miss|vcl_deliver|vcl_synth|vcl_backend_fetch|vcl_backend_response|vcl_backend_error|vcl_init|vcl_fini|vcl_purge)\b/, Tokens::NameFunction)

        # Flow keywords
        root.add_rule Rule.new(/\b(?:if|else|elseif|elsif|return|call|set|unset|ban|rollback|synthetic|hash_data|regsub|regsuball)\b/, Tokens::Keyword)

        # Return actions
        root.add_rule Rule.new(/\b(?:pass|pipe|hit_for_pass|lookup|deliver|restart|retry|synth|purge|hash|miss|error)\b/, Tokens::NameBuiltin)

        # Constants
        root.add_rule Rule.new(/\b(?:true|false)\b/, Tokens::KeywordConstant)

        # Numbers with duration suffix
        root.add_rule Rule.new(/\d+\.\d+(?:s|ms)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+(?:s|ms)?/, Tokens::NumInteger)

        # Operators
        root.add_rule Rule.new(/[+\-*\/%=!<>&|^~]+/, Tokens::Operator)
        root.add_rule Rule.new(/~/, Tokens::Operator)

        # Punctuation
        root.add_rule Rule.new(/[{}\[\]();,.]/, Tokens::Punctuation)

        # Variables (req.*, bereq.*, etc.)
        root.add_rule Rule.new(/(?:req|bereq|resp|beresp|obj|client|server|local|remote)\.[a-zA-Z0-9_.-]+/, Tokens::NameVariable)

        # Identifiers
        root.add_rule Rule.new(/[a-zA-Z_][a-zA-Z0-9_]*/, Tokens::Name)

        root.add_rule Rule.new(/./, Tokens::Text)

        states[:root] = root

        mc = State.new(:multiline_comment)
        mc.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        mc.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        mc.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:multiline_comment] = mc

        ls = State.new(:long_string)
        ls.add_rule Rule.new(/"\}/, Tokens::StrDouble, pop: true)
        ls.add_rule Rule.new(/[^"]+/, Tokens::StrDouble)
        ls.add_rule Rule.new(/"/, Tokens::StrDouble)
        states[:long_string] = ls

        states
      end
    end

    RegexLexer.register("varnish", Varnish)
    RegexLexer.register("vcl", Varnish)
  end
end
