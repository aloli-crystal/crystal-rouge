module Rouge
  module Lexers
    class HTTP < RegexLexer
      def self.tag_name : String
        "http"
      end

      def self.title_text : String
        "HTTP"
      end

      def self.desc_text : String
        "HTTP request/response"
      end

      def self.file_exts : Array(String)
        ["*.http"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        # Request line: GET /path HTTP/1.1
        root.add_rule Rule.new(
          /(GET|POST|PUT|DELETE|PATCH|HEAD|OPTIONS|CONNECT|TRACE)(\s+)(\S+)(\s+)(HTTP\/[\d.]+)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::Keyword, m[1]},
              {Tokens::TextWhitespace, m[2]},
              {Tokens::NameAttribute, m[3]},
              {Tokens::TextWhitespace, m[4]},
              {Tokens::KeywordConstant, m[5]},
            ] of TokenPair
          }
        )
        # Response line: HTTP/1.1 200 OK
        root.add_rule Rule.new(
          /(HTTP\/[\d.]+)(\s+)(\d{3})(\s+)([^\n]*)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::KeywordConstant, m[1]},
              {Tokens::TextWhitespace, m[2]},
              {Tokens::NumInteger, m[3]},
              {Tokens::TextWhitespace, m[4]},
              {Tokens::Name, m[5]},
            ] of TokenPair
          }
        )
        # Headers: Name: Value
        root.add_rule Rule.new(
          /([\w-]+)(:)(\s*)([^\n]*)/,
          block: ->(m : Regex::MatchData) {
            [
              {Tokens::NameAttribute, m[1]},
              {Tokens::Punctuation, m[2]},
              {Tokens::TextWhitespace, m[3]},
              {Tokens::Str, m[4]},
            ] of TokenPair
          }
        )
        root.add_rule Rule.new(/[^\n]+/, Tokens::Text)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("http", HTTP)
  end
end
