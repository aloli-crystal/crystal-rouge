module Rouge
  module Lexers
    class XML < RegexLexer
      def self.tag_name : String
        "xml"
      end

      def self.title_text : String
        "XML"
      end

      def self.desc_text : String
        "Extensible Markup Language"
      end

      def self.file_exts : Array(String)
        ["*.xml", "*.xsl", "*.xslt", "*.xsd", "*.svg"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        # :root
        root = State.new(:root)

        # CDATA sections
        root.add_rule Rule.new(/<!\[CDATA\[[\s\S]*?\]\]>/m, Tokens::CommentPreproc)

        # Comments
        root.add_rule Rule.new(/<!--[\s\S]*?-->/, Tokens::Comment)

        # Processing instructions (including XML declaration)
        root.add_rule Rule.new(/<\?xml\b/, Tokens::KeywordDeclaration, next_state: :xml_decl)
        root.add_rule Rule.new(/<\?[\w:-]+/, Tokens::CommentPreproc, next_state: :pi)

        # Entity references
        root.add_rule Rule.new(/&\#?\w+;/, Tokens::NameEntity)

        # Tags (opening, closing, self-closing)
        root.add_rule Rule.new(/<\s*\/\s*[\w:-]+\s*>/, Tokens::NameTag)
        root.add_rule Rule.new(/<\s*[\w:-]+/, Tokens::NameTag, next_state: :tag)

        # Text content
        root.add_rule Rule.new(/[^<&]+/, Tokens::Text)
        root.add_rule Rule.new(/./, Tokens::Text)

        states[:root] = root

        # :xml_decl — <?xml version="1.0" ... ?>
        xml_decl = State.new(:xml_decl)
        xml_decl.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        xml_decl.add_rule Rule.new(
          /([\w:-]+)(\s*=\s*)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::NameAttribute, m[1]},
              {Tokens::Operator, m[2]},
            ] of TokenPair
          }
        )
        xml_decl.add_rule Rule.new(/"[^"]*"/, Tokens::StrDouble)
        xml_decl.add_rule Rule.new(/'[^']*'/, Tokens::StrSingle)
        xml_decl.add_rule Rule.new(/\?>/, Tokens::KeywordDeclaration, pop: true)
        states[:xml_decl] = xml_decl

        # :pi — processing instruction content
        pi = State.new(:pi)
        pi.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        pi.add_rule Rule.new(/\?>/, Tokens::CommentPreproc, pop: true)
        pi.add_rule Rule.new(/[^\s?]+/, Tokens::CommentPreproc)
        pi.add_rule Rule.new(/./, Tokens::CommentPreproc)
        states[:pi] = pi

        # :tag — inside a tag, after the tag name
        tag = State.new(:tag)
        tag.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        tag.add_rule Rule.new(
          /(xmlns(?::[\w-]+)?)(\s*=\s*)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::NameNamespace, m[1]},
              {Tokens::Operator, m[2]},
            ] of TokenPair
          }
        )
        tag.add_rule Rule.new(
          /([\w:-]+)(\s*=\s*)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::NameAttribute, m[1]},
              {Tokens::Operator, m[2]},
            ] of TokenPair
          }
        )
        tag.add_rule Rule.new(/"[^"]*"/, Tokens::StrDouble)
        tag.add_rule Rule.new(/'[^']*'/, Tokens::StrSingle)
        tag.add_rule Rule.new(/\/?\s*>/, Tokens::NameTag, pop: true)
        states[:tag] = tag

        states
      end
    end

    RegexLexer.register("xml", XML)
  end
end
