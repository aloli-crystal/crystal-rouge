module Rouge
  module Lexers
    class EEx < RegexLexer
      def self.tag_name : String
        "eex"
      end

      def self.title_text : String
        "EEx"
      end

      def self.desc_text : String
        "Elixir EEx templates"
      end

      def self.file_exts : Array(String)
        ["*.eex", "*.leex", "*.heex"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        elixir_keywords = %w(def defp defmodule do end if else unless case cond fn for with raise rescue try catch after quote unquote require import use alias when in and or not true false nil)

        eex_code = State.new(:eex_code)
        eex_code.add_rule Rule.new(/%>/, Tokens::CommentPreproc, pop: true)
        eex_code.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        eex_code.add_rule Rule.new(/"[^"]*"/, Tokens::StrDouble)
        eex_code.add_rule Rule.new(/'[^']*'/, Tokens::StrSingle)
        eex_code.add_rule Rule.new(/(?:#{elixir_keywords.join("|")})\b/, Tokens::Keyword)
        eex_code.add_rule Rule.new(/:[a-zA-Z_]\w*/, Tokens::StrSymbol)
        eex_code.add_rule Rule.new(/@[a-zA-Z_]\w*/, Tokens::NameVariable)
        eex_code.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        eex_code.add_rule Rule.new(/[a-zA-Z_]\w*[!?]?/, Tokens::Name)
        eex_code.add_rule Rule.new(/[+\-*\/%=<>!&|^~]+/, Tokens::Operator)
        eex_code.add_rule Rule.new(/[{}()\[\];,.|]/, Tokens::Punctuation)
        states[:eex_code] = eex_code

        tag = State.new(:tag)
        tag.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        tag.add_rule Rule.new(/[a-zA-Z_][\w\-]*\s*=/, Tokens::NameAttribute)
        tag.add_rule Rule.new(/"[^"]*"/, Tokens::StrDouble)
        tag.add_rule Rule.new(/'[^']*'/, Tokens::StrSingle)
        tag.add_rule Rule.new(/\/?>/, Tokens::NameTag, pop: true)
        states[:tag] = tag

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/<%#[^\n]*%>/, Tokens::Comment)
        root.add_rule Rule.new(/<%=?/, Tokens::CommentPreproc, next_state: :eex_code)
        root.add_rule Rule.new(/<!--/, Tokens::Comment, next_state: :html_comment)
        root.add_rule Rule.new(/<\/[a-zA-Z_][\w\-]*\s*>/, Tokens::NameTag)
        root.add_rule Rule.new(/<[a-zA-Z_][\w\-]*/, Tokens::NameTag, next_state: :tag)
        root.add_rule Rule.new(/&\w+;/, Tokens::NameEntity)
        root.add_rule Rule.new(/[^<&\s]+/, Tokens::Text)
        states[:root] = root

        html_comment = State.new(:html_comment)
        html_comment.add_rule Rule.new(/-->/, Tokens::Comment, pop: true)
        html_comment.add_rule Rule.new(/[^-]+/, Tokens::Comment)
        html_comment.add_rule Rule.new(/-/, Tokens::Comment)
        states[:html_comment] = html_comment

        states
      end
    end

    RegexLexer.register("eex", EEx)
  end
end
