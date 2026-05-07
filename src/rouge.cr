require "./rouge/token"
require "./rouge/regex_lexer"
require "./rouge/formatters/html"
require "./rouge/themes/github"
require "./rouge/lexers/*"

module Rouge
  # Lue au compile-time depuis `shard.yml` via le macro `read_file`.
  # Cf. note mémoire `feedback_shard_version_macro.md` (mémoire ALOLI).
  VERSION = {{
              (read_file("#{__DIR__}/../shard.yml")
                .lines
                .find(&.starts_with?("version:")) || "version: 0.0.0")
                .gsub(/^version:\s*/, "")
                .chomp
            }}

  # Version de la gem Ruby Rouge utilisée comme référence pour le portage.
  UPSTREAM_VERSION = "4.7.0"

  # Convenience: highlight source code to HTML
  def self.highlight(source : String, lexer_tag : String, css_class : String = "highlight") : String
    lexer = RegexLexer.find(lexer_tag)
    raise "Unknown lexer: #{lexer_tag}" unless lexer

    tokens = lexer.lex(source)
    Formatters::HTML.new.format_wrapped(tokens, css_class)
  end
end
