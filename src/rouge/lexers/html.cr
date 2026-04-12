module Rouge
  module Lexers
    class HTML < RegexLexer
      def self.tag_name : String
        "html"
      end

      def self.title_text : String
        "HTML"
      end

      def self.desc_text : String
        "HyperText Markup Language"
      end

      def self.file_exts : Array(String)
        ["*.html", "*.htm", "*.xhtml"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        # :root
        root = State.new(:root)
        root.add_rule Rule.new(/<!--[\s\S]*?-->/, Tokens::Comment)
        root.add_rule Rule.new(/<!DOCTYPE[^>]*>/i, Tokens::CommentPreproc)
        root.add_rule Rule.new(/&\#?\w+;/, Tokens::NameEntity)
        root.add_rule Rule.new(/<\s*\/?\s*[\w:-]+/, Tokens::NameTag, next_state: :tag)
        root.add_rule Rule.new(/[^<&]+/, Tokens::Text)
        root.add_rule Rule.new(/./, Tokens::Text)
        states[:root] = root

        # :tag — inside an opening or closing tag, after the tag name
        tag = State.new(:tag)
        tag.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
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
        tag.add_rule Rule.new(/[\w:-]+/, Tokens::NameAttribute)
        tag.add_rule Rule.new(/\/?\s*>/, Tokens::NameTag, pop: true)
        states[:tag] = tag

        # :attr (available for direct use)
        attr = State.new(:attr)
        attr.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        attr.add_rule Rule.new(/=\s*/, Tokens::Operator)
        attr.add_rule Rule.new(/"[^"]*"/, Tokens::StrDouble, pop: true)
        attr.add_rule Rule.new(/'[^']*'/, Tokens::StrSingle, pop: true)
        attr.add_rule Rule.new(/[\w-]+/, Tokens::Str, pop: true)
        states[:attr] = attr

        # :script_content
        script_content = State.new(:script_content)
        script_content.add_mixin :tag
        states[:script_content] = script_content

        # :style_content
        style_content = State.new(:style_content)
        style_content.add_mixin :tag
        states[:style_content] = style_content

        states
      end
    end

    # Register
    RegexLexer.register("html", HTML)
  end
end
