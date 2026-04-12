require "./spec_helper"

describe Rouge::Token do
  it "has qualname and shortname" do
    tok = Rouge::Tokens::Keyword
    tok.qualname.should eq("Keyword")
    tok.shortname.should eq("k")
  end

  it "has parent reference" do
    tok = Rouge::Tokens::KeywordType
    tok.parent.should eq(Rouge::Tokens::Keyword)
  end

  it "can be looked up by qualname" do
    Rouge::Tokens["Keyword"].should eq(Rouge::Tokens::Keyword)
    Rouge::Tokens["Keyword.Type"].should eq(Rouge::Tokens::KeywordType)
  end

  it "has all standard token types" do
    Rouge::Tokens["Text"].should eq(Rouge::Tokens::Text)
    Rouge::Tokens["Error"].should eq(Rouge::Tokens::Error)
    Rouge::Tokens["Keyword"].should eq(Rouge::Tokens::Keyword)
    Rouge::Tokens["Name"].should eq(Rouge::Tokens::Name)
    Rouge::Tokens["Literal"].should eq(Rouge::Tokens::Literal)
    Rouge::Tokens["Operator"].should eq(Rouge::Tokens::Operator)
    Rouge::Tokens["Punctuation"].should eq(Rouge::Tokens::Punctuation)
    Rouge::Tokens["Comment"].should eq(Rouge::Tokens::Comment)
    Rouge::Tokens["Generic"].should eq(Rouge::Tokens::Generic)
  end
end

describe Rouge::RegexLexer do
  it "finds lexer by tag" do
    lexer = Rouge::RegexLexer.find("json")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::JSON)
  end

  it "returns nil for unknown tag" do
    lexer = Rouge::RegexLexer.find("unknown_language_xyz")
    lexer.should be_nil
  end

  it "lists registered tags" do
    tags = Rouge::RegexLexer.registered_tags
    tags.should contain("json")
  end
end

describe Rouge::Lexers::JSON do
  it "tokenizes a simple number" do
    lexer = Rouge::Lexers::JSON.new
    tokens = lexer.lex("42")
    tokens.size.should be > 0
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true
  end

  it "tokenizes a string" do
    lexer = Rouge::Lexers::JSON.new
    tokens = lexer.lex(%("hello"))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
  end

  it "tokenizes boolean and null" do
    lexer = Rouge::Lexers::JSON.new
    tokens = lexer.lex("true")
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordConstant && val == "true" }.should be_true

    tokens = lexer.lex("false")
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordConstant && val == "false" }.should be_true

    tokens = lexer.lex("null")
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordConstant && val == "null" }.should be_true
  end

  it "tokenizes a simple object" do
    lexer = Rouge::Lexers::JSON.new
    tokens = lexer.lex(%({"key": "value"}))
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameLabel }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::Punctuation }.should be_true
  end

  it "tokenizes nested objects" do
    lexer = Rouge::Lexers::JSON.new
    tokens = lexer.lex(%({"a": {"b": 1}}))
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "1" }.should be_true
  end

  it "tokenizes arrays" do
    lexer = Rouge::Lexers::JSON.new
    tokens = lexer.lex(%([1, 2, 3]))
    integers = tokens.select { |tok, _| tok == Rouge::Tokens::NumInteger }
    integers.size.should eq(3)
  end

  it "tokenizes float numbers" do
    lexer = Rouge::Lexers::JSON.new
    tokens = lexer.lex("3.14")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumFloat && val == "3.14" }.should be_true
  end

  it "tokenizes string escapes" do
    lexer = Rouge::Lexers::JSON.new
    tokens = lexer.lex(%("hello\\nworld"))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrEscape }.should be_true
  end

  it "tokenizes a complete JSON document" do
    json = <<-JSON
    {
      "name": "Crystal",
      "version": 1.19,
      "stable": true,
      "features": ["fast", "safe"],
      "meta": null
    }
    JSON

    lexer = Rouge::Lexers::JSON.new
    tokens = lexer.lex(json)
    tokens.size.should be > 10

    # Should have labels, strings, numbers, booleans, null
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameLabel }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NumFloat }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::KeywordConstant }.should be_true
  end
end

describe Rouge::Formatters::HTML do
  it "formats tokens as HTML spans" do
    tokens = [
      {Rouge::Tokens::Keyword, "def"},
      {Rouge::Tokens::Text, " "},
      {Rouge::Tokens::NameFunction, "hello"},
    ]
    html = Rouge::Formatters::HTML.new.format(tokens)
    html.should contain(%(<span class="k">def</span>))
    html.should contain(%(<span class="nf">hello</span>))
    html.should contain(" ")
  end

  it "escapes HTML entities" do
    tokens = [{Rouge::Tokens::Text, "<script>alert('xss')</script>"}]
    html = Rouge::Formatters::HTML.new.format(tokens)
    html.should contain("&lt;script&gt;")
    html.should_not contain("<script>")
  end

  it "wraps in pre/code tags" do
    tokens = [{Rouge::Tokens::Keyword, "puts"}]
    html = Rouge::Formatters::HTML.new.format_wrapped(tokens)
    html.should contain(%(<pre class="highlight"><code>))
    html.should contain(%(</code></pre>))
  end
end

describe Rouge::Themes::Github do
  it "renders CSS with default scope" do
    css = Rouge::Themes::Github.render
    css.should contain(".highlight")
    css.should contain(".k ")
    css.should contain("color:")
  end

  it "renders CSS with custom scope" do
    css = Rouge::Themes::Github.render(scope: ".code-block")
    css.should contain(".code-block")
    css.should_not contain(".highlight")
  end
end

describe Rouge::Lexers::SQL do
  it "tokenizes keywords" do
    lexer = Rouge::Lexers::SQL.new
    tokens = lexer.lex("SELECT * FROM users WHERE id = 1")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "SELECT" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "FROM" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "WHERE" }.should be_true
  end

  it "tokenizes case-insensitive keywords" do
    lexer = Rouge::Lexers::SQL.new
    tokens = lexer.lex("select from where")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "select" }.should be_true
  end

  it "tokenizes types" do
    lexer = Rouge::Lexers::SQL.new
    tokens = lexer.lex("INTEGER VARCHAR BOOLEAN")
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "INTEGER" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "VARCHAR" }.should be_true
  end

  it "tokenizes strings" do
    lexer = Rouge::Lexers::SQL.new
    tokens = lexer.lex("'hello world'")
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrSingle }.should be_true
  end

  it "tokenizes numbers" do
    lexer = Rouge::Lexers::SQL.new
    tokens = lexer.lex("42 3.14")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumFloat && val == "3.14" }.should be_true
  end

  it "tokenizes single-line comments" do
    lexer = Rouge::Lexers::SQL.new
    tokens = lexer.lex("-- this is a comment")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end

  it "tokenizes multiline comments" do
    lexer = Rouge::Lexers::SQL.new
    tokens = lexer.lex("/* comment */")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentMultiline }.should be_true
  end

  it "tokenizes operators and punctuation" do
    lexer = Rouge::Lexers::SQL.new
    tokens = lexer.lex("a = 1;")
    tokens.any? { |tok, _| tok == Rouge::Tokens::Operator }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Punctuation && val == ";" }.should be_true
  end

  it "can be found by tag" do
    lexer = Rouge::RegexLexer.find("sql")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::SQL)
  end
end

describe Rouge::Lexers::Shell do
  it "tokenizes keywords" do
    lexer = Rouge::Lexers::Shell.new
    tokens = lexer.lex("if true; then echo hi; fi")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "if" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "then" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "fi" }.should be_true
  end

  it "tokenizes builtins" do
    lexer = Rouge::Lexers::Shell.new
    tokens = lexer.lex("echo hello")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameBuiltin && val == "echo" }.should be_true
  end

  it "tokenizes comments" do
    lexer = Rouge::Lexers::Shell.new
    tokens = lexer.lex("# this is a comment")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end

  it "tokenizes double-quoted strings" do
    lexer = Rouge::Lexers::Shell.new
    tokens = lexer.lex(%("hello world"))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
  end

  it "tokenizes single-quoted strings" do
    lexer = Rouge::Lexers::Shell.new
    tokens = lexer.lex("'hello world'")
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrSingle }.should be_true
  end

  it "tokenizes variables" do
    lexer = Rouge::Lexers::Shell.new
    tokens = lexer.lex("$HOME ${PATH} $0 $?")
    vars = tokens.select { |tok, _| tok == Rouge::Tokens::NameVariable }
    vars.size.should be >= 3
  end

  it "tokenizes operators" do
    lexer = Rouge::Lexers::Shell.new
    tokens = lexer.lex("a && b || c | d")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Operator && val == "&&" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Operator && val == "||" }.should be_true
  end

  it "tokenizes numbers" do
    lexer = Rouge::Lexers::Shell.new
    tokens = lexer.lex("42")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true
  end

  it "can be found by multiple tags" do
    %w(shell bash sh zsh).each do |tag|
      lexer = Rouge::RegexLexer.find(tag)
      lexer.should_not be_nil
      lexer.should be_a(Rouge::Lexers::Shell)
    end
  end
end

describe Rouge::Lexers::Crystal do
  it "tokenizes keywords" do
    lexer = Rouge::Lexers::Crystal.new
    tokens = lexer.lex("def foo; end")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "def" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "end" }.should be_true
  end

  it "tokenizes constants" do
    lexer = Rouge::Lexers::Crystal.new
    tokens = lexer.lex("true false nil")
    consts = tokens.select { |tok, _| tok == Rouge::Tokens::KeywordConstant }
    consts.size.should eq(3)
  end

  it "tokenizes builtin types" do
    lexer = Rouge::Lexers::Crystal.new
    tokens = lexer.lex("Int32 String Array")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameBuiltin && val == "Int32" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameBuiltin && val == "String" }.should be_true
  end

  it "tokenizes strings with interpolation" do
    lexer = Rouge::Lexers::Crystal.new
    tokens = lexer.lex(%("hello \#{name}"))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrInterpol }.should be_true
  end

  it "tokenizes comments" do
    lexer = Rouge::Lexers::Crystal.new
    tokens = lexer.lex("# a comment")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end

  it "tokenizes symbols" do
    lexer = Rouge::Lexers::Crystal.new
    tokens = lexer.lex(":hello")
    tokens.any? { |tok, val| tok == Rouge::Tokens::StrSymbol && val == ":hello" }.should be_true
  end

  it "tokenizes numbers" do
    lexer = Rouge::Lexers::Crystal.new
    tokens = lexer.lex("42 3.14 0xff 0b1010 0o77")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumFloat && val == "3.14" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumHex && val == "0xff" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumBin && val == "0b1010" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumOct && val == "0o77" }.should be_true
  end

  it "tokenizes instance variables" do
    lexer = Rouge::Lexers::Crystal.new
    tokens = lexer.lex("@name @@count")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameVariableInstance && val == "@name" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameVariableClass && val == "@@count" }.should be_true
  end

  it "tokenizes annotations" do
    lexer = Rouge::Lexers::Crystal.new
    tokens = lexer.lex("@[JSON::Field]")
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameDecorator }.should be_true
  end

  it "tokenizes operators" do
    lexer = Rouge::Lexers::Crystal.new
    tokens = lexer.lex("a + b == c")
    tokens.any? { |tok, _| tok == Rouge::Tokens::Operator }.should be_true
  end

  it "can be found by tag" do
    lexer = Rouge::RegexLexer.find("crystal")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::Crystal)
  end
end

describe Rouge do
  it "highlights JSON with convenience method" do
    html = Rouge.highlight(%({"key": 42}), "json")
    html.should contain(%(<pre class="highlight">))
    html.should contain(%(<span class="))
    html.should contain("42")
  end

  it "raises on unknown lexer" do
    expect_raises(Exception, "Unknown lexer") do
      Rouge.highlight("code", "nonexistent_xyz")
    end
  end
end
