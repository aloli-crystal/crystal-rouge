require "./spec_helper"

describe Rouge::Lexers::HTML do
  it "is registered as html" do
    lexer = Rouge::RegexLexer.find("html")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::HTML)
  end

  it "tokenizes a simple tag" do
    lexer = Rouge::Lexers::HTML.new
    tokens = lexer.lex("<div>")
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameTag }.should be_true
  end

  it "tokenizes text content" do
    lexer = Rouge::Lexers::HTML.new
    tokens = lexer.lex("<p>Hello</p>")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Text && val == "Hello" }.should be_true
  end

  it "tokenizes attributes" do
    lexer = Rouge::Lexers::HTML.new
    tokens = lexer.lex(%(<div class="main">))
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameAttribute && val == "class" }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
  end

  it "tokenizes comments" do
    lexer = Rouge::Lexers::HTML.new
    tokens = lexer.lex("<!-- comment -->")
    tokens.any? { |tok, _| tok == Rouge::Tokens::Comment }.should be_true
  end

  it "tokenizes DOCTYPE" do
    lexer = Rouge::Lexers::HTML.new
    tokens = lexer.lex("<!DOCTYPE html>")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentPreproc }.should be_true
  end

  it "tokenizes entity references" do
    lexer = Rouge::Lexers::HTML.new
    tokens = lexer.lex("&amp; &lt; &#123;")
    entities = tokens.select { |tok, _| tok == Rouge::Tokens::NameEntity }
    entities.size.should eq(3)
  end

  it "tokenizes a complete HTML snippet" do
    html = <<-HTML
    <!DOCTYPE html>
    <html lang="en">
    <head><title>Test</title></head>
    <body>
      <h1 class="title">Hello &amp; World</h1>
      <!-- comment -->
    </body>
    </html>
    HTML

    lexer = Rouge::Lexers::HTML.new
    tokens = lexer.lex(html)
    tokens.size.should be > 10
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentPreproc }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameTag }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameAttribute }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::Comment }.should be_true
  end
end

describe Rouge::Lexers::CSS do
  it "is registered as css" do
    lexer = Rouge::RegexLexer.find("css")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::CSS)
  end

  it "tokenizes selectors" do
    lexer = Rouge::Lexers::CSS.new
    tokens = lexer.lex("div { }")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameTag && val == "div" }.should be_true
  end

  it "tokenizes class selectors" do
    lexer = Rouge::Lexers::CSS.new
    tokens = lexer.lex(".container { }")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameClass && val == ".container" }.should be_true
  end

  it "tokenizes id selectors" do
    lexer = Rouge::Lexers::CSS.new
    tokens = lexer.lex("#main { }")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameFunction && val == "#main" }.should be_true
  end

  it "tokenizes properties and values" do
    lexer = Rouge::Lexers::CSS.new
    tokens = lexer.lex("div { color: red; }")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameProperty && val == "color" }.should be_true
  end

  it "tokenizes comments" do
    lexer = Rouge::Lexers::CSS.new
    tokens = lexer.lex("/* comment */")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentMultiline }.should be_true
  end

  it "tokenizes hex colors" do
    lexer = Rouge::Lexers::CSS.new
    tokens = lexer.lex("div { color: #ff0000; }")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumHex && val == "#ff0000" }.should be_true
  end

  it "tokenizes @rules" do
    lexer = Rouge::Lexers::CSS.new
    tokens = lexer.lex("@media screen { }")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "@media" }.should be_true
  end

  it "tokenizes a complete CSS snippet" do
    css = <<-CSS
    /* Main styles */
    body {
      font-size: 16px;
      color: #333;
    }
    .container {
      margin: 0 auto;
    }
    @media (max-width: 768px) {
      .container { width: 100%; }
    }
    CSS

    lexer = Rouge::Lexers::CSS.new
    tokens = lexer.lex(css)
    tokens.size.should be > 10
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentMultiline }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameProperty }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
  end
end

describe Rouge::Lexers::Javascript do
  it "is registered as javascript and js" do
    lexer = Rouge::RegexLexer.find("javascript")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::Javascript)

    lexer2 = Rouge::RegexLexer.find("js")
    lexer2.should_not be_nil
    lexer2.should be_a(Rouge::Lexers::Javascript)
  end

  it "tokenizes keywords" do
    lexer = Rouge::Lexers::Javascript.new
    tokens = lexer.lex("const x = 1;")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "const" }.should be_true
  end

  it "tokenizes constants" do
    lexer = Rouge::Lexers::Javascript.new
    tokens = lexer.lex("true false null undefined")
    consts = tokens.select { |tok, _| tok == Rouge::Tokens::KeywordConstant }
    consts.size.should eq(4)
  end

  it "tokenizes strings" do
    lexer = Rouge::Lexers::Javascript.new

    tokens = lexer.lex(%("hello"))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true

    tokens = lexer.lex("'world'")
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrSingle }.should be_true

    tokens = lexer.lex("`template`")
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrBacktick }.should be_true
  end

  it "tokenizes numbers" do
    lexer = Rouge::Lexers::Javascript.new

    tokens = lexer.lex("42")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true

    tokens = lexer.lex("0xFF")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumHex && val == "0xFF" }.should be_true

    tokens = lexer.lex("0b1010")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumBin && val == "0b1010" }.should be_true
  end

  it "tokenizes single-line comments" do
    lexer = Rouge::Lexers::Javascript.new
    tokens = lexer.lex("// a comment")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end

  it "tokenizes multi-line comments" do
    lexer = Rouge::Lexers::Javascript.new
    tokens = lexer.lex("/* comment */")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentMultiline }.should be_true
  end

  it "tokenizes arrow functions" do
    lexer = Rouge::Lexers::Javascript.new
    tokens = lexer.lex("(x) => x + 1")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Operator && val == "=>" }.should be_true
  end

  it "tokenizes builtins" do
    lexer = Rouge::Lexers::Javascript.new
    tokens = lexer.lex("console.log(JSON.parse(x))")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameBuiltin && val == "console" }.should be_true
  end

  it "tokenizes a complete JS snippet" do
    js = <<-JS
    // Greet function
    async function greet(name) {
      const msg = `Hello, ${name}!`;
      console.log(msg);
      return true;
    }
    JS

    lexer = Rouge::Lexers::Javascript.new
    tokens = lexer.lex(js)
    tokens.size.should be > 10
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameFunction }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::KeywordConstant }.should be_true
  end
end

describe Rouge::Lexers::Python do
  it "is registered as python and py" do
    lexer = Rouge::RegexLexer.find("python")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::Python)

    lexer2 = Rouge::RegexLexer.find("py")
    lexer2.should_not be_nil
    lexer2.should be_a(Rouge::Lexers::Python)
  end

  it "tokenizes keywords" do
    lexer = Rouge::Lexers::Python.new
    tokens = lexer.lex("if x: return y")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "if" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "return" }.should be_true
  end

  it "tokenizes constants" do
    lexer = Rouge::Lexers::Python.new
    tokens = lexer.lex("None True False")
    consts = tokens.select { |tok, _| tok == Rouge::Tokens::KeywordConstant }
    consts.size.should eq(3)
  end

  it "tokenizes builtins" do
    lexer = Rouge::Lexers::Python.new
    tokens = lexer.lex("print(len(x))")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameBuiltin && val == "print" }.should be_true
  end

  it "tokenizes strings" do
    lexer = Rouge::Lexers::Python.new

    tokens = lexer.lex(%("hello"))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true

    tokens = lexer.lex("'world'")
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrSingle }.should be_true
  end

  it "tokenizes triple-quoted strings" do
    lexer = Rouge::Lexers::Python.new
    tokens = lexer.lex(%("""docstring"""))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDoc }.should be_true
  end

  it "tokenizes comments" do
    lexer = Rouge::Lexers::Python.new
    tokens = lexer.lex("# a comment")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end

  it "tokenizes numbers" do
    lexer = Rouge::Lexers::Python.new

    tokens = lexer.lex("42")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true

    tokens = lexer.lex("3.14")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumFloat && val == "3.14" }.should be_true

    tokens = lexer.lex("0xFF")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumHex && val == "0xFF" }.should be_true
  end

  it "tokenizes decorators" do
    lexer = Rouge::Lexers::Python.new
    tokens = lexer.lex("@staticmethod")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameDecorator && val == "@staticmethod" }.should be_true
  end

  it "tokenizes f-strings" do
    lexer = Rouge::Lexers::Python.new
    tokens = lexer.lex(%(f"hello {name}"))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrAffix }.should be_true
  end

  it "tokenizes a complete Python snippet" do
    py = <<-PY
    # Calculator
    def add(a, b):
        """Add two numbers."""
        return a + b

    @staticmethod
    def multiply(x, y):
        result = x * y
        print(f"Result: {result}")
        return result
    PY

    lexer = Rouge::Lexers::Python.new
    tokens = lexer.lex(py)
    tokens.size.should be > 10
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameDecorator }.should be_true
  end
end
