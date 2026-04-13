module Rouge
  module Lexers
    class Mason < RegexLexer
      def self.tag_name : String
        "mason"
      end

      def self.title_text : String
        "Mason"
      end

      def self.desc_text : String
        "Mason template language (Perl)"
      end

      def self.file_exts : Array(String)
        ["*.mas", "*.mhtml", "*.mcomp"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        # :perl_block
        pb = State.new(:perl_block)
        pb.add_rule Rule.new(/%>/, Tokens::CommentPreproc, pop: true)
        pb.add_rule Rule.new(/[^%]+/, Tokens::Other)
        pb.add_rule Rule.new(/%/, Tokens::Other)
        states[:perl_block] = pb

        # :perl_section
        ps = State.new(:perl_section)
        ps.add_rule Rule.new(/<\/%[a-zA-Z]+>/, Tokens::CommentPreproc, pop: true)
        ps.add_rule Rule.new(/[^<]+/, Tokens::Other)
        ps.add_rule Rule.new(/</, Tokens::Other)
        states[:perl_section] = ps

        # :component_call
        cc = State.new(:component_call)
        cc.add_rule Rule.new(/&>/, Tokens::Punctuation, pop: true)
        cc.add_rule Rule.new(/[^&]+/, Tokens::Str)
        cc.add_rule Rule.new(/&/, Tokens::Str)
        states[:component_call] = cc

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/<%(?:perl|init|cleanup|once|shared|doc|text|args|flags|attr|def|method)>/i, Tokens::CommentPreproc, next_state: :perl_section)
        root.add_rule Rule.new(/<%/, Tokens::CommentPreproc, next_state: :perl_block)
        root.add_rule Rule.new(/<&/, Tokens::Punctuation, next_state: :component_call)

        # HTML
        root.add_rule Rule.new(/<[^%&][^>]*>/, Tokens::NameTag)
        root.add_rule Rule.new(/[^<\s]+/, Tokens::Text)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("mason", Mason)
  end
end
