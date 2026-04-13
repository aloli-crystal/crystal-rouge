module Rouge
  module Lexers
    class Puppet < RegexLexer
      def self.tag_name : String
        "puppet"
      end

      def self.title_text : String
        "Puppet"
      end

      def self.desc_text : String
        "Puppet configuration management language"
      end

      def self.file_exts : Array(String)
        ["*.pp"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(
          class define node inherits if elsif else unless case include require
          contain realize notify subscribe before after file package service
          exec user group cron mount host tidy augeas yumrepo apt template
          ensure present absent running stopped installed latest purged
          directory link
        )

        kw_pattern = keywords.join("|")

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/#.*/, Tokens::CommentSingle)
        root.add_rule Rule.new(Regex.new("\\b(?:#{kw_pattern})\\b"), Tokens::Keyword)
        root.add_rule Rule.new(/(?:true|false|undef)\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\$[a-zA-Z_]\w*(?:::[a-zA-Z_]\w*)*/, Tokens::NameVariable)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :double_string)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :single_string)
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[=!<>]+|=>|~>|\+>/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,:]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        states[:root] = root

        ds = State.new(:double_string)
        ds.add_rule Rule.new(/\$\{[^}]+\}/, Tokens::StrInterpol)
        ds.add_rule Rule.new(/\$[a-zA-Z_]\w*/, Tokens::NameVariable)
        ds.add_rule Rule.new(/\\./, Tokens::StrEscape)
        ds.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        ds.add_rule Rule.new(/[^"\\$]+/, Tokens::StrDouble)
        states[:double_string] = ds

        ss = State.new(:single_string)
        ss.add_rule Rule.new(/[^']+/, Tokens::StrSingle)
        ss.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        states[:single_string] = ss

        states
      end
    end

    RegexLexer.register("puppet", Puppet)
    RegexLexer.register("pp", Puppet)
  end
end
