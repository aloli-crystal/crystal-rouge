require "./spec_helper"

describe Rouge::Lexers::Markdown do
  it "is registered as markdown and md" do
    lexer = Rouge::RegexLexer.find("markdown")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::Markdown)

    lexer2 = Rouge::RegexLexer.find("md")
    lexer2.should_not be_nil
    lexer2.should be_a(Rouge::Lexers::Markdown)
  end

  it "tokenizes headings" do
    lexer = Rouge::Lexers::Markdown.new
    tokens = lexer.lex("# Heading 1")
    tokens.any? { |tok, val| tok == Rouge::Tokens::GenericHeading && val.includes?("Heading 1") }.should be_true

    tokens = lexer.lex("### Heading 3")
    tokens.any? { |tok, val| tok == Rouge::Tokens::GenericHeading && val.includes?("Heading 3") }.should be_true
  end

  it "tokenizes bold text" do
    lexer = Rouge::Lexers::Markdown.new
    tokens = lexer.lex("**bold text**")
    tokens.any? { |tok, _| tok == Rouge::Tokens::GenericStrong }.should be_true
  end

  it "tokenizes italic text" do
    lexer = Rouge::Lexers::Markdown.new
    tokens = lexer.lex("*italic text*")
    tokens.any? { |tok, _| tok == Rouge::Tokens::GenericEmph }.should be_true
  end

  it "tokenizes inline code" do
    lexer = Rouge::Lexers::Markdown.new
    tokens = lexer.lex("`code here`")
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrBacktick }.should be_true
  end

  it "tokenizes links" do
    lexer = Rouge::Lexers::Markdown.new
    tokens = lexer.lex("[text](http://example.com)")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameLabel && val == "text" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameAttribute && val == "http://example.com" }.should be_true
  end

  it "tokenizes images" do
    lexer = Rouge::Lexers::Markdown.new
    tokens = lexer.lex("![alt text](image.png)")
    tokens.any? { |tok, val| tok == Rouge::Tokens::StrDouble && val == "alt text" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameAttribute && val == "image.png" }.should be_true
  end

  it "tokenizes blockquotes" do
    lexer = Rouge::Lexers::Markdown.new
    tokens = lexer.lex("> quoted text")
    tokens.any? { |tok, _| tok == Rouge::Tokens::GenericTraceback }.should be_true
  end

  it "tokenizes HTML entities" do
    lexer = Rouge::Lexers::Markdown.new
    tokens = lexer.lex("&amp; &lt;")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameEntity && val == "&amp;" }.should be_true
  end

  it "tokenizes a complete Markdown snippet" do
    md_code = <<-MD
    # Title

    Some **bold** and *italic* text.

    - list item
    - another item

    [link](http://example.com)

    `inline code`
    MD

    lexer = Rouge::Lexers::Markdown.new
    tokens = lexer.lex(md_code)
    tokens.size.should be > 5
    tokens.any? { |tok, _| tok == Rouge::Tokens::GenericHeading }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::GenericStrong }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::GenericEmph }.should be_true
  end
end

describe Rouge::Lexers::XML do
  it "is registered as xml" do
    lexer = Rouge::RegexLexer.find("xml")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::XML)
  end

  it "tokenizes tags" do
    lexer = Rouge::Lexers::XML.new
    tokens = lexer.lex("<root>text</root>")
    tags = tokens.select { |tok, _| tok == Rouge::Tokens::NameTag }
    tags.size.should be >= 2
  end

  it "tokenizes attributes" do
    lexer = Rouge::Lexers::XML.new
    tokens = lexer.lex(%(<item id="1">))
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameAttribute && val == "id" }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
  end

  it "tokenizes comments" do
    lexer = Rouge::Lexers::XML.new
    tokens = lexer.lex("<!-- a comment -->")
    tokens.any? { |tok, _| tok == Rouge::Tokens::Comment }.should be_true
  end

  it "tokenizes XML declaration" do
    lexer = Rouge::Lexers::XML.new
    tokens = lexer.lex(%(<?xml version="1.0" encoding="UTF-8"?>))
    tokens.any? { |tok, _| tok == Rouge::Tokens::KeywordDeclaration }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameAttribute && val == "version" }.should be_true
  end

  it "tokenizes CDATA" do
    lexer = Rouge::Lexers::XML.new
    tokens = lexer.lex("<![CDATA[some data]]>")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentPreproc }.should be_true
  end

  it "tokenizes entity references" do
    lexer = Rouge::Lexers::XML.new
    tokens = lexer.lex("&amp; &lt; &#x20;")
    entities = tokens.select { |tok, _| tok == Rouge::Tokens::NameEntity }
    entities.size.should eq(3)
  end

  it "tokenizes namespaces" do
    lexer = Rouge::Lexers::XML.new
    tokens = lexer.lex(%(<root xmlns:ns="http://example.com">))
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameNamespace && val == "xmlns:ns" }.should be_true
  end

  it "tokenizes self-closing tags" do
    lexer = Rouge::Lexers::XML.new
    tokens = lexer.lex("<br/>")
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameTag }.should be_true
  end

  it "tokenizes a complete XML snippet" do
    xml_code = <<-XML
    <?xml version="1.0"?>
    <root xmlns:ns="http://example.com">
      <!-- comment -->
      <item id="1">&amp;</item>
    </root>
    XML

    lexer = Rouge::Lexers::XML.new
    tokens = lexer.lex(xml_code)
    tokens.size.should be > 10
    tokens.any? { |tok, _| tok == Rouge::Tokens::KeywordDeclaration }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::Comment }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameTag }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameEntity }.should be_true
  end
end

describe Rouge::Lexers::TOML do
  it "is registered as toml" do
    lexer = Rouge::RegexLexer.find("toml")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::TOML)
  end

  it "tokenizes bare keys" do
    lexer = Rouge::Lexers::TOML.new
    tokens = lexer.lex("name = \"value\"")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameLabel && val == "name" }.should be_true
  end

  it "tokenizes tables" do
    lexer = Rouge::Lexers::TOML.new
    tokens = lexer.lex("[section]")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameNamespace && val == "section" }.should be_true
  end

  it "tokenizes array of tables" do
    lexer = Rouge::Lexers::TOML.new
    tokens = lexer.lex("[[items]]")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameNamespace && val == "items" }.should be_true
  end

  it "tokenizes strings" do
    lexer = Rouge::Lexers::TOML.new
    tokens = lexer.lex(%(key = "hello"))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true

    tokens = lexer.lex("key = 'literal'")
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrSingle }.should be_true
  end

  it "tokenizes booleans" do
    lexer = Rouge::Lexers::TOML.new
    tokens = lexer.lex("flag = true")
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordConstant && val == "true" }.should be_true
  end

  it "tokenizes integers" do
    lexer = Rouge::Lexers::TOML.new
    tokens = lexer.lex("count = 42")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true
  end

  it "tokenizes floats" do
    lexer = Rouge::Lexers::TOML.new
    tokens = lexer.lex("pi = 3.14")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumFloat && val == "3.14" }.should be_true
  end

  it "tokenizes hex, octal, and binary" do
    lexer = Rouge::Lexers::TOML.new
    tokens = lexer.lex("hex = 0xFF")
    tokens.any? { |tok, _| tok == Rouge::Tokens::NumHex }.should be_true

    tokens = lexer.lex("oct = 0o77")
    tokens.any? { |tok, _| tok == Rouge::Tokens::NumOct }.should be_true

    tokens = lexer.lex("bin = 0b1010")
    tokens.any? { |tok, _| tok == Rouge::Tokens::NumBin }.should be_true
  end

  it "tokenizes dates" do
    lexer = Rouge::Lexers::TOML.new
    tokens = lexer.lex("date = 2024-01-15")
    tokens.any? { |tok, _| tok == Rouge::Tokens::LiteralDate }.should be_true
  end

  it "tokenizes comments" do
    lexer = Rouge::Lexers::TOML.new
    tokens = lexer.lex("# a comment")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end

  it "tokenizes special float values" do
    lexer = Rouge::Lexers::TOML.new
    tokens = lexer.lex("val = inf")
    tokens.any? { |tok, _| tok == Rouge::Tokens::NumFloat }.should be_true

    tokens = lexer.lex("val = nan")
    tokens.any? { |tok, _| tok == Rouge::Tokens::NumFloat }.should be_true
  end

  it "tokenizes a complete TOML snippet" do
    toml_code = <<-TOML
    [package]
    name = "my-app"
    version = "0.1.0"
    enabled = true

    [dependencies]
    crystal = ">=1.0"

    [[items]]
    id = 42
    weight = 3.14
    TOML

    lexer = Rouge::Lexers::TOML.new
    tokens = lexer.lex(toml_code)
    tokens.size.should be > 10
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameNamespace }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameLabel }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::KeywordConstant }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NumInteger }.should be_true
  end
end

describe Rouge::Lexers::Kotlin do
  it "is registered as kotlin and kt" do
    lexer = Rouge::RegexLexer.find("kotlin")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::Kotlin)

    lexer2 = Rouge::RegexLexer.find("kt")
    lexer2.should_not be_nil
    lexer2.should be_a(Rouge::Lexers::Kotlin)
  end

  it "tokenizes keywords" do
    lexer = Rouge::Lexers::Kotlin.new
    tokens = lexer.lex("fun main() { val x = 1 }")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "fun" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "val" }.should be_true
  end

  it "tokenizes types" do
    lexer = Rouge::Lexers::Kotlin.new
    tokens = lexer.lex("Int String Boolean List Map")
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "Int" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "String" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "Boolean" }.should be_true
  end

  it "tokenizes constants" do
    lexer = Rouge::Lexers::Kotlin.new
    tokens = lexer.lex("true false null")
    consts = tokens.select { |tok, _| tok == Rouge::Tokens::KeywordConstant }
    consts.size.should eq(3)
  end

  it "tokenizes strings with interpolation" do
    lexer = Rouge::Lexers::Kotlin.new
    tokens = lexer.lex(%("hello ${name}"))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrInterpol }.should be_true
  end

  it "tokenizes raw strings" do
    lexer = Rouge::Lexers::Kotlin.new
    tokens = lexer.lex(%(val s = """\nraw string\n"""))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
  end

  it "tokenizes numbers" do
    lexer = Rouge::Lexers::Kotlin.new
    tokens = lexer.lex("42 3.14 0xFF 0b1010")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumFloat && val == "3.14" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumHex && val == "0xFF" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumBin && val == "0b1010" }.should be_true
  end

  it "tokenizes long integers" do
    lexer = Rouge::Lexers::Kotlin.new
    tokens = lexer.lex("100L")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumIntegerLong && val == "100L" }.should be_true
  end

  it "tokenizes comments" do
    lexer = Rouge::Lexers::Kotlin.new
    tokens = lexer.lex("// single line")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true

    tokens = lexer.lex("/* multi line */")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentMultiline }.should be_true
  end

  it "tokenizes annotations" do
    lexer = Rouge::Lexers::Kotlin.new
    tokens = lexer.lex("@JvmStatic")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameDecorator && val == "@JvmStatic" }.should be_true
  end

  it "tokenizes a complete Kotlin snippet" do
    kt_code = <<-KT
    package com.example

    import kotlin.collections.List

    @JvmStatic
    fun main(args: Array<String>) {
        val x: Int = 42
        val msg = "Hello, ${args[0]}!"
        println(msg)
    }
    KT

    lexer = Rouge::Lexers::Kotlin.new
    tokens = lexer.lex(kt_code)
    tokens.size.should be > 10
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::KeywordType }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameDecorator }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NumInteger }.should be_true
  end
end

describe Rouge::Lexers::Lua do
  it "is registered as lua" do
    lexer = Rouge::RegexLexer.find("lua")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::Lua)
  end

  it "tokenizes keywords" do
    lexer = Rouge::Lexers::Lua.new
    tokens = lexer.lex("local x = 1")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "local" }.should be_true
  end

  it "tokenizes function keyword" do
    lexer = Rouge::Lexers::Lua.new
    tokens = lexer.lex("function foo() end")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "function" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "end" }.should be_true
  end

  it "tokenizes constants" do
    lexer = Rouge::Lexers::Lua.new
    tokens = lexer.lex("true false nil")
    consts = tokens.select { |tok, _| tok == Rouge::Tokens::KeywordConstant }
    consts.size.should eq(3)
  end

  it "tokenizes builtins" do
    lexer = Rouge::Lexers::Lua.new
    tokens = lexer.lex("print(type(x))")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameBuiltin && val == "print" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameBuiltin && val == "type" }.should be_true
  end

  it "tokenizes strings" do
    lexer = Rouge::Lexers::Lua.new
    tokens = lexer.lex(%("hello world"))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true

    tokens = lexer.lex("'hello world'")
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrSingle }.should be_true
  end

  it "tokenizes long strings" do
    lexer = Rouge::Lexers::Lua.new
    tokens = lexer.lex("[[long string]]")
    tokens.any? { |tok, _| tok == Rouge::Tokens::Str }.should be_true
  end

  it "tokenizes numbers" do
    lexer = Rouge::Lexers::Lua.new
    tokens = lexer.lex("42 3.14 0xFF")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumFloat && val == "3.14" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumHex && val == "0xFF" }.should be_true
  end

  it "tokenizes single-line comments" do
    lexer = Rouge::Lexers::Lua.new
    tokens = lexer.lex("-- a comment")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end

  it "tokenizes multi-line comments" do
    lexer = Rouge::Lexers::Lua.new
    tokens = lexer.lex("--[[ multi\nline ]]")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentMultiline }.should be_true
  end

  it "tokenizes operators" do
    lexer = Rouge::Lexers::Lua.new
    tokens = lexer.lex("x = 1 + 2 .. 'a' ~= 'b'")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Operator && val == ".." }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Operator && val == "~=" }.should be_true
  end

  it "tokenizes varargs" do
    lexer = Rouge::Lexers::Lua.new
    tokens = lexer.lex("function f(...) end")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Operator && val == "..." }.should be_true
  end

  it "tokenizes a complete Lua snippet" do
    lua_code = <<-LUA
    -- Factorial function
    local function factorial(n)
        if n <= 1 then
            return 1
        end
        return n * factorial(n - 1)
    end

    print(factorial(10))
    LUA

    lexer = Rouge::Lexers::Lua.new
    tokens = lexer.lex(lua_code)
    tokens.size.should be > 10
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameBuiltin }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NumInteger }.should be_true
  end
end
