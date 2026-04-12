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
