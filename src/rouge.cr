require "./rouge/token"
require "./rouge/regex_lexer"
require "./rouge/formatters/html"
require "./rouge/themes/github"
require "./rouge/lexers/*"

module Rouge
  VERSION = "0.1.0"

  # Convenience: highlight source code to HTML
  def self.highlight(source : String, lexer_tag : String, css_class : String = "highlight") : String
    lexer = RegexLexer.find(lexer_tag)
    raise "Unknown lexer: #{lexer_tag}" unless lexer

    tokens = lexer.lex(source)
    Formatters::HTML.new.format_wrapped(tokens, css_class)
  end
end
