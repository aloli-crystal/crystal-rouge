module Rouge
  module Lexers
    class CiscoIOS < RegexLexer
      def self.tag_name : String
        "cisco_ios"
      end

      def self.title_text : String
        "Cisco IOS"
      end

      def self.desc_text : String
        "Cisco IOS configuration"
      end

      def self.file_exts : Array(String)
        ["*.ios"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(interface ip router hostname enable no permit deny any host log shutdown description vlan switchport trunk encapsulation service banner line username password crypto ntp logging)
        commands = %w(access-list spanning-tree snmp-server)

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/![^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"[^"]*"/, Tokens::StrDouble)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/i, Tokens::Keyword)
        root.add_rule Rule.new(/(?:#{commands.map { |c| Regex.escape(c) }.join("|")})\b/i, Tokens::Keyword)
        root.add_rule Rule.new(/\d+\.\d+\.\d+\.\d+/, Tokens::NumOther)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_][\w\-]*/, Tokens::Name)
        root.add_rule Rule.new(/[\/=]/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("cisco_ios", CiscoIOS)
    RegexLexer.register("ios", CiscoIOS)
  end
end
