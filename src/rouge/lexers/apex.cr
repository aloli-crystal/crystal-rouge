module Rouge
  module Lexers
    class Apex < RegexLexer
      def self.tag_name : String
        "apex"
      end

      def self.title_text : String
        "Apex"
      end

      def self.desc_text : String
        "Salesforce Apex programming language"
      end

      def self.file_exts : Array(String)
        ["*.cls", "*.trigger"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(abstract break case catch class continue default do else enum extends final finally for global if implements import instanceof interface new null override private protected public return static super switch this throw transient trigger try virtual void webservice while with sharing without)
        soql_kw = %w(SELECT FROM WHERE AND OR NOT IN LIKE ORDER BY GROUP HAVING LIMIT OFFSET UPDATE TRACKING VIEWSTAT FOR REFERENCE VIEW ALL ROWS NULLS FIRST LAST ASC DESC)

        comment_block = State.new(:comment_block)
        comment_block.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        comment_block.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        comment_block.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment_block] = comment_block

        string_single = State.new(:string_single)
        string_single.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_single.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        string_single.add_rule Rule.new(/[^'\\]+/, Tokens::StrSingle)
        states[:string_single] = string_single

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_block)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)
        root.add_rule Rule.new(/(?:#{soql_kw.join("|")})\b/i, Tokens::KeywordReserved)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/, Tokens::Keyword)
        root.add_rule Rule.new(/(?:true|false)\b/i, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\d+\.\d*/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+[lL]?/, Tokens::NumInteger)
        root.add_rule Rule.new(/@[a-zA-Z_]\w*/, Tokens::NameDecorator)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/%=<>!&|^~?:]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("apex", Apex)
  end
end
