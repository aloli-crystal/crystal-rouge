require "./spec_helper"

describe Rouge::Lexers::Haskell do
  it "is registered as haskell and hs" do
    lexer = Rouge::RegexLexer.find("haskell")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::Haskell)

    lexer2 = Rouge::RegexLexer.find("hs")
    lexer2.should_not be_nil
    lexer2.should be_a(Rouge::Lexers::Haskell)
  end

  it "tokenizes keywords" do
    lexer = Rouge::Lexers::Haskell.new
    tokens = lexer.lex("module Main where")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "module" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "where" }.should be_true
  end

  it "tokenizes types" do
    lexer = Rouge::Lexers::Haskell.new
    tokens = lexer.lex("Int -> String -> Maybe Bool")
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "Int" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "String" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "Maybe" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "Bool" }.should be_true
  end

  it "tokenizes constants" do
    lexer = Rouge::Lexers::Haskell.new
    tokens = lexer.lex("True False Nothing Just")
    consts = tokens.select { |tok, _| tok == Rouge::Tokens::KeywordConstant }
    consts.size.should eq(4)
  end

  it "tokenizes single-line comments" do
    lexer = Rouge::Lexers::Haskell.new
    tokens = lexer.lex("-- this is a comment")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end

  it "tokenizes multi-line comments" do
    lexer = Rouge::Lexers::Haskell.new
    tokens = lexer.lex("{- multi line comment -}")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentMultiline }.should be_true
  end

  it "tokenizes strings" do
    lexer = Rouge::Lexers::Haskell.new
    tokens = lexer.lex(%("hello world"))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
  end

  it "tokenizes characters" do
    lexer = Rouge::Lexers::Haskell.new
    tokens = lexer.lex("'a'")
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrChar }.should be_true
  end

  it "tokenizes operators" do
    lexer = Rouge::Lexers::Haskell.new
    tokens = lexer.lex("x :: Int -> Int")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Operator && val == "::" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Operator && val == "->" }.should be_true
  end

  it "tokenizes numbers" do
    lexer = Rouge::Lexers::Haskell.new
    tokens = lexer.lex("42 3.14 0xFF")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumFloat && val == "3.14" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumHex && val == "0xFF" }.should be_true
  end

  it "tokenizes user-defined types" do
    lexer = Rouge::Lexers::Haskell.new
    tokens = lexer.lex("data MyType = Foo | Bar")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "data" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameClass && val == "MyType" }.should be_true
  end

  it "tokenizes a complete Haskell snippet" do
    hs_code = <<-HS
    module Main where

    -- Factorial function
    factorial :: Int -> Int
    factorial 0 = 1
    factorial n = n * factorial (n - 1)

    main :: IO ()
    main = print (factorial 10)
    HS

    lexer = Rouge::Lexers::Haskell.new
    tokens = lexer.lex(hs_code)
    tokens.size.should be > 10
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::KeywordType }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NumInteger }.should be_true
  end
end

describe Rouge::Lexers::Dart do
  it "is registered as dart" do
    lexer = Rouge::RegexLexer.find("dart")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::Dart)
  end

  it "tokenizes keywords" do
    lexer = Rouge::Lexers::Dart.new
    tokens = lexer.lex("class Foo extends Bar {}")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "class" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "extends" }.should be_true
  end

  it "tokenizes types" do
    lexer = Rouge::Lexers::Dart.new
    tokens = lexer.lex("int x = 1; String s;")
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "int" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "String" }.should be_true
  end

  it "tokenizes constants" do
    lexer = Rouge::Lexers::Dart.new
    tokens = lexer.lex("true false null")
    consts = tokens.select { |tok, _| tok == Rouge::Tokens::KeywordConstant }
    consts.size.should eq(3)
  end

  it "tokenizes strings with interpolation" do
    lexer = Rouge::Lexers::Dart.new
    tokens = lexer.lex(%("hello $name and ${expr}"))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrInterpol }.should be_true
  end

  it "tokenizes single-quoted strings" do
    lexer = Rouge::Lexers::Dart.new
    tokens = lexer.lex("'hello world'")
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrSingle }.should be_true
  end

  it "tokenizes annotations" do
    lexer = Rouge::Lexers::Dart.new
    tokens = lexer.lex("@override")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameDecorator && val == "@override" }.should be_true
  end

  it "tokenizes comments" do
    lexer = Rouge::Lexers::Dart.new
    tokens = lexer.lex("// single line comment")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true

    tokens = lexer.lex("/* block comment */")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentMultiline }.should be_true
  end

  it "tokenizes numbers" do
    lexer = Rouge::Lexers::Dart.new
    tokens = lexer.lex("42 3.14 0xFF")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumFloat && val == "3.14" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumHex && val == "0xFF" }.should be_true
  end

  it "tokenizes cascade operator" do
    lexer = Rouge::Lexers::Dart.new
    tokens = lexer.lex("foo..bar()")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Operator && val == ".." }.should be_true
  end

  it "tokenizes a complete Dart snippet" do
    dart_code = <<-DART
    import 'package:flutter/material.dart';

    @override
    void main() {
      final name = 'World';
      print('Hello, $name!');
      var x = 42;
    }
    DART

    lexer = Rouge::Lexers::Dart.new
    tokens = lexer.lex(dart_code)
    tokens.size.should be > 10
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameDecorator }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NumInteger }.should be_true
  end
end

describe Rouge::Lexers::PowerShell do
  it "is registered as powershell, posh, and ps1" do
    lexer = Rouge::RegexLexer.find("powershell")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::PowerShell)

    lexer2 = Rouge::RegexLexer.find("posh")
    lexer2.should_not be_nil
    lexer2.should be_a(Rouge::Lexers::PowerShell)

    lexer3 = Rouge::RegexLexer.find("ps1")
    lexer3.should_not be_nil
    lexer3.should be_a(Rouge::Lexers::PowerShell)
  end

  it "tokenizes keywords" do
    lexer = Rouge::Lexers::PowerShell.new
    tokens = lexer.lex("If ($x) { Return $x }")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "If" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "Return" }.should be_true
  end

  it "tokenizes variables" do
    lexer = Rouge::Lexers::PowerShell.new
    tokens = lexer.lex("$name $env:PATH $_")
    vars = tokens.select { |tok, _| tok == Rouge::Tokens::NameVariable }
    vars.size.should eq(3)
  end

  it "tokenizes cmdlets" do
    lexer = Rouge::Lexers::PowerShell.new
    tokens = lexer.lex("Get-Content Set-Content")
    builtins = tokens.select { |tok, _| tok == Rouge::Tokens::NameBuiltin }
    builtins.size.should eq(2)
  end

  it "tokenizes single-line comments" do
    lexer = Rouge::Lexers::PowerShell.new
    tokens = lexer.lex("# this is a comment")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end

  it "tokenizes multi-line comments" do
    lexer = Rouge::Lexers::PowerShell.new
    tokens = lexer.lex("<# multi line #>")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentMultiline }.should be_true
  end

  it "tokenizes double-quoted strings with interpolation" do
    lexer = Rouge::Lexers::PowerShell.new
    tokens = lexer.lex(%("Hello $name"))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrInterpol }.should be_true
  end

  it "tokenizes single-quoted strings" do
    lexer = Rouge::Lexers::PowerShell.new
    tokens = lexer.lex("'no interpolation'")
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrSingle }.should be_true
  end

  it "tokenizes word operators" do
    lexer = Rouge::Lexers::PowerShell.new
    tokens = lexer.lex("$x -eq 5 -and $y -ne 3")
    ops = tokens.select { |tok, _| tok == Rouge::Tokens::OperatorWord }
    ops.size.should eq(3)
  end

  it "tokenizes numbers" do
    lexer = Rouge::Lexers::PowerShell.new
    tokens = lexer.lex("42 3.14 0xFF")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumFloat && val == "3.14" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumHex && val == "0xFF" }.should be_true
  end

  it "tokenizes a complete PowerShell snippet" do
    ps_code = <<-PS
    # Read a file
    Function Get-Data {
        Param($path)
        If (Test-Path $path) {
            $content = Get-Content $path
            Write-Output $content
        }
    }
    PS

    lexer = Rouge::Lexers::PowerShell.new
    tokens = lexer.lex(ps_code)
    tokens.size.should be > 10
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameVariable }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameBuiltin }.should be_true
  end
end

describe Rouge::Lexers::Nginx do
  it "is registered as nginx" do
    lexer = Rouge::RegexLexer.find("nginx")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::Nginx)
  end

  it "tokenizes directives" do
    lexer = Rouge::Lexers::Nginx.new
    tokens = lexer.lex("server { listen 80; }")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "server" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "listen" }.should be_true
  end

  it "tokenizes comments" do
    lexer = Rouge::Lexers::Nginx.new
    tokens = lexer.lex("# nginx comment")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end

  it "tokenizes strings" do
    lexer = Rouge::Lexers::Nginx.new
    tokens = lexer.lex(%(server_name "example.com";))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
  end

  it "tokenizes variables" do
    lexer = Rouge::Lexers::Nginx.new
    tokens = lexer.lex("proxy_set_header Host $host;")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameVariable && val == "$host" }.should be_true
  end

  it "tokenizes numbers" do
    lexer = Rouge::Lexers::Nginx.new
    tokens = lexer.lex("listen 8080;")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "8080" }.should be_true
  end

  it "tokenizes numbers with units" do
    lexer = Rouge::Lexers::Nginx.new
    tokens = lexer.lex("client_max_body_size 10m;")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "client_max_body_size" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "10m" }.should be_true
  end

  it "tokenizes block structure" do
    lexer = Rouge::Lexers::Nginx.new
    tokens = lexer.lex("server { }")
    puncts = tokens.select { |tok, val| tok == Rouge::Tokens::Punctuation && (val == "{" || val == "}") }
    puncts.size.should eq(2)
  end

  it "tokenizes a complete Nginx snippet" do
    nginx_code = <<-NGINX
    server {
        listen 80;
        server_name example.com;
        root /var/www/html;

        location / {
            proxy_pass http://backend;
            proxy_set_header Host $host;
        }

        # Enable gzip
        gzip on;
    }
    NGINX

    lexer = Rouge::Lexers::Nginx.new
    tokens = lexer.lex(nginx_code)
    tokens.size.should be > 10
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NumInteger }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameVariable }.should be_true
  end
end

describe Rouge::Lexers::INI do
  it "is registered as ini, cfg, and properties" do
    lexer = Rouge::RegexLexer.find("ini")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::INI)

    lexer2 = Rouge::RegexLexer.find("cfg")
    lexer2.should_not be_nil
    lexer2.should be_a(Rouge::Lexers::INI)

    lexer3 = Rouge::RegexLexer.find("properties")
    lexer3.should_not be_nil
    lexer3.should be_a(Rouge::Lexers::INI)
  end

  it "tokenizes sections" do
    lexer = Rouge::Lexers::INI.new
    tokens = lexer.lex("[section]")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameNamespace && val == "section" }.should be_true
    puncts = tokens.select { |tok, val| tok == Rouge::Tokens::Punctuation && (val == "[" || val == "]") }
    puncts.size.should eq(2)
  end

  it "tokenizes key = value with equals" do
    lexer = Rouge::Lexers::INI.new
    tokens = lexer.lex("name = value")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameLabel && val == "name" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Operator && val == "=" }.should be_true
  end

  it "tokenizes key : value with colon" do
    lexer = Rouge::Lexers::INI.new
    tokens = lexer.lex("name: value")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameLabel && val == "name" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Operator && val == ":" }.should be_true
  end

  it "tokenizes comments with semicolons" do
    lexer = Rouge::Lexers::INI.new
    tokens = lexer.lex("; this is a comment")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end

  it "tokenizes comments with hash" do
    lexer = Rouge::Lexers::INI.new
    tokens = lexer.lex("# this is a comment")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end

  it "tokenizes boolean values" do
    lexer = Rouge::Lexers::INI.new
    tokens = lexer.lex("flag = true")
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordConstant && val == "true" }.should be_true
  end

  it "tokenizes numeric values" do
    lexer = Rouge::Lexers::INI.new
    tokens = lexer.lex("count = 42")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true
  end

  it "tokenizes float values" do
    lexer = Rouge::Lexers::INI.new
    tokens = lexer.lex("pi = 3.14")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumFloat && val == "3.14" }.should be_true
  end

  it "tokenizes quoted string values" do
    lexer = Rouge::Lexers::INI.new
    tokens = lexer.lex(%(name = "hello world"))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
  end

  it "tokenizes a complete INI snippet" do
    ini_code = <<-INI
    ; Database config
    [database]
    host = localhost
    port = 5432
    enabled = true

    [logging]
    level = debug
    file = "/var/log/app.log"
    INI

    lexer = Rouge::Lexers::INI.new
    tokens = lexer.lex(ini_code)
    tokens.size.should be > 10
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameNamespace }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameLabel }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NumInteger }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::KeywordConstant }.should be_true
  end
end
