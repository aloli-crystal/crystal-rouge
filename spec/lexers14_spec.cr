require "./spec_helper"

describe Rouge::Lexers::RobotFramework do
  it "is registered as robot_framework and robot" do
    Rouge::RegexLexer.find("robot_framework").should be_a(Rouge::Lexers::RobotFramework)
    Rouge::RegexLexer.find("robot").should be_a(Rouge::Lexers::RobotFramework)
  end

  it "tokenizes section headers and variables" do
    lexer = Rouge::Lexers::RobotFramework.new
    tokens = lexer.lex("*** Test Cases ***\n${variable}    keyword\n# comment")
    tokens.any? { |tok, _| tok == Rouge::Tokens::GenericHeading }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameVariable }.should be_true
  end
end

describe Rouge::Lexers::RML do
  it "is registered as rml" do
    Rouge::RegexLexer.find("rml").should be_a(Rouge::Lexers::RML)
  end

  it "tokenizes comments and strings" do
    lexer = Rouge::Lexers::RML.new
    tokens = lexer.lex("# comment\n\"hello\"")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
  end
end

describe Rouge::Lexers::SassLexer do
  it "is registered as sass" do
    Rouge::RegexLexer.find("sass").should be_a(Rouge::Lexers::SassLexer)
  end

  it "tokenizes variables and comments" do
    lexer = Rouge::Lexers::SassLexer.new
    tokens = lexer.lex("// comment\n$color: #333\n=mixin-name")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameVariable }.should be_true
  end
end

describe Rouge::Lexers::Sieve do
  it "is registered as sieve" do
    Rouge::RegexLexer.find("sieve").should be_a(Rouge::Lexers::Sieve)
  end

  it "tokenizes keywords and strings" do
    lexer = Rouge::Lexers::Sieve.new
    tokens = lexer.lex("require \"fileinto\";\nif header :contains \"Subject\" \"test\" {\n  fileinto \"INBOX\";\n}")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "require" }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
  end
end

describe Rouge::Lexers::SliceLexer do
  it "is registered as slice" do
    Rouge::RegexLexer.find("slice").should be_a(Rouge::Lexers::SliceLexer)
  end

  it "tokenizes keywords and types" do
    lexer = Rouge::Lexers::SliceLexer.new
    tokens = lexer.lex("module Demo {\n  interface Hello {\n    string sayHello();\n  };\n};")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "module" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "string" }.should be_true
  end
end

describe Rouge::Lexers::SQF do
  it "is registered as sqf" do
    Rouge::RegexLexer.find("sqf").should be_a(Rouge::Lexers::SQF)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::SQF.new
    tokens = lexer.lex("// comment\nprivate _x = 42;\nif (_x > 0) then { hint \"yes\"; };")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
  end
end

describe Rouge::Lexers::SSH do
  it "is registered as ssh and ssh_config" do
    Rouge::RegexLexer.find("ssh").should be_a(Rouge::Lexers::SSH)
    Rouge::RegexLexer.find("ssh_config").should be_a(Rouge::Lexers::SSH)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::SSH.new
    tokens = lexer.lex("# comment\nHost example.com\n  User admin\n  Port 22")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "Host" }.should be_true
  end
end

describe Rouge::Lexers::Stan do
  it "is registered as stan" do
    Rouge::RegexLexer.find("stan").should be_a(Rouge::Lexers::Stan)
  end

  it "tokenizes blocks and types" do
    lexer = Rouge::Lexers::Stan.new
    tokens = lexer.lex("data {\n  int N;\n  real y[N];\n}\nmodel {\n  y ~ normal(0, 1);\n}")
    tokens.any? { |tok, _| tok == Rouge::Tokens::KeywordNamespace }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "int" }.should be_true
  end
end

describe Rouge::Lexers::SuperCollider do
  it "is registered as supercollider and sc" do
    Rouge::RegexLexer.find("supercollider").should be_a(Rouge::Lexers::SuperCollider)
    Rouge::RegexLexer.find("sc").should be_a(Rouge::Lexers::SuperCollider)
  end

  it "tokenizes keywords and class names" do
    lexer = Rouge::Lexers::SuperCollider.new
    tokens = lexer.lex("var x = SinOsc.ar(440);\n// comment")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "var" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameClass && val == "SinOsc" }.should be_true
  end
end

describe Rouge::Lexers::Systemd do
  it "is registered as systemd" do
    Rouge::RegexLexer.find("systemd").should be_a(Rouge::Lexers::Systemd)
  end

  it "tokenizes sections and directives" do
    lexer = Rouge::Lexers::Systemd.new
    tokens = lexer.lex("[Unit]\nDescription=My Service\n[Service]\nExecStart=/usr/bin/myapp")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameNamespace && val == "Unit" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameAttribute && val == "ExecStart" }.should be_true
  end
end

describe Rouge::Lexers::Syzlang do
  it "is registered as syzlang" do
    Rouge::RegexLexer.find("syzlang").should be_a(Rouge::Lexers::Syzlang)
  end

  it "tokenizes keywords and types" do
    lexer = Rouge::Lexers::Syzlang.new
    tokens = lexer.lex("resource fd[int32]\n# comment\nopen(file ptr[in, string])")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "resource" }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end
end

describe Rouge::Lexers::Syzprog do
  it "is registered as syzprog" do
    Rouge::RegexLexer.find("syzprog").should be_a(Rouge::Lexers::Syzprog)
  end

  it "tokenizes syscalls and comments" do
    lexer = Rouge::Lexers::Syzprog.new
    tokens = lexer.lex("# comment\nr0 = openat(0xffffffffffffff9c, 0x0, 0x0, 0x0)")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameFunction && val == "openat" }.should be_true
  end
end

describe Rouge::Lexers::TAP do
  it "is registered as tap" do
    Rouge::RegexLexer.find("tap").should be_a(Rouge::Lexers::TAP)
  end

  it "tokenizes ok and not ok lines" do
    lexer = Rouge::Lexers::TAP.new
    tokens = lexer.lex("1..2\nok 1 test passed\nnot ok 2 test failed")
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::GenericInserted }.should be_true
  end
end

describe Rouge::Lexers::TTCN3 do
  it "is registered as ttcn3" do
    Rouge::RegexLexer.find("ttcn3").should be_a(Rouge::Lexers::TTCN3)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::TTCN3.new
    tokens = lexer.lex("module MyModule {\n  // comment\n  function f() { log(\"hello\"); }\n}")
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordDeclaration && val == "module" }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end
end

describe Rouge::Lexers::Tulip do
  it "is registered as tulip" do
    Rouge::RegexLexer.find("tulip").should be_a(Rouge::Lexers::Tulip)
  end

  it "tokenizes keywords and strings" do
    lexer = Rouge::Lexers::Tulip.new
    tokens = lexer.lex("# comment\nlet x = \"hello\"")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "let" }.should be_true
  end
end

describe Rouge::Lexers::Turtle do
  it "is registered as turtle and ttl" do
    Rouge::RegexLexer.find("turtle").should be_a(Rouge::Lexers::Turtle)
    Rouge::RegexLexer.find("ttl").should be_a(Rouge::Lexers::Turtle)
  end

  it "tokenizes prefixes and URIs" do
    lexer = Rouge::Lexers::Turtle.new
    tokens = lexer.lex("@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .\n# comment")
    tokens.any? { |tok, _| tok == Rouge::Tokens::KeywordNamespace }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end
end

describe Rouge::Lexers::Twig do
  it "is registered as twig" do
    Rouge::RegexLexer.find("twig").should be_a(Rouge::Lexers::Twig)
  end

  it "tokenizes template tags and expressions" do
    lexer = Rouge::Lexers::Twig.new
    tokens = lexer.lex("{{ name }}\n{% if x %}yes{% endif %}\n{# comment #}")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentPreproc }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentMultiline }.should be_true
  end
end

describe Rouge::Lexers::Vala do
  it "is registered as vala" do
    Rouge::RegexLexer.find("vala").should be_a(Rouge::Lexers::Vala)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::Vala.new
    tokens = lexer.lex("// comment\npublic class MyClass {\n  void method() { return; }\n}")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "public" }.should be_true
  end
end

describe Rouge::Lexers::Varnish do
  it "is registered as varnish and vcl" do
    Rouge::RegexLexer.find("varnish").should be_a(Rouge::Lexers::Varnish)
    Rouge::RegexLexer.find("vcl").should be_a(Rouge::Lexers::Varnish)
  end

  it "tokenizes keywords and subroutine names" do
    lexer = Rouge::Lexers::Varnish.new
    tokens = lexer.lex("sub vcl_recv {\n  if (req.url ~ \"/api\") {\n    return(pass);\n  }\n}")
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordDeclaration && val == "sub" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameFunction && val == "vcl_recv" }.should be_true
  end
end

describe Rouge::Lexers::Velocity do
  it "is registered as velocity and vtl" do
    Rouge::RegexLexer.find("velocity").should be_a(Rouge::Lexers::Velocity)
    Rouge::RegexLexer.find("vtl").should be_a(Rouge::Lexers::Velocity)
  end

  it "tokenizes directives and variables" do
    lexer = Rouge::Lexers::Velocity.new
    tokens = lexer.lex("## comment\n#set($x = 1)\n$name")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameVariable }.should be_true
  end
end

describe Rouge::Lexers::Veryl do
  it "is registered as veryl" do
    Rouge::RegexLexer.find("veryl").should be_a(Rouge::Lexers::Veryl)
  end

  it "tokenizes keywords and types" do
    lexer = Rouge::Lexers::Veryl.new
    tokens = lexer.lex("module test {\n  var x: logic;\n  // comment\n}")
    tokens.any? { |tok, _| tok == Rouge::Tokens::KeywordDeclaration }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "logic" }.should be_true
  end
end

describe Rouge::Lexers::Xojo do
  it "is registered as xojo" do
    Rouge::RegexLexer.find("xojo").should be_a(Rouge::Lexers::Xojo)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::Xojo.new
    tokens = lexer.lex("// comment\nDim x As Integer = 42\nIf x > 0 Then\n  Return True\nEnd If")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
  end
end

describe Rouge::Lexers::XPath do
  it "is registered as xpath" do
    Rouge::RegexLexer.find("xpath").should be_a(Rouge::Lexers::XPath)
  end

  it "tokenizes axes and functions" do
    lexer = Rouge::Lexers::XPath.new
    tokens = lexer.lex("//book[position() > 1]/child::title")
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameFunction }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::Operator }.should be_true
  end
end

describe Rouge::Lexers::XQuery do
  it "is registered as xquery" do
    Rouge::RegexLexer.find("xquery").should be_a(Rouge::Lexers::XQuery)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::XQuery.new
    tokens = lexer.lex("xquery version \"1.0\";\n(: comment :)\nfor $x in doc(\"test.xml\") return $x")
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordDeclaration && val == "xquery" }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentMultiline }.should be_true
  end
end

describe Rouge::Lexers::Yang do
  it "is registered as yang" do
    Rouge::RegexLexer.find("yang").should be_a(Rouge::Lexers::Yang)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::Yang.new
    tokens = lexer.lex("module test {\n  // comment\n  namespace \"urn:test\";\n  leaf name {\n    type string;\n  }\n}")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "module" }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end
end

describe Rouge::Lexers::EPP do
  it "is registered as epp" do
    Rouge::RegexLexer.find("epp").should be_a(Rouge::Lexers::EPP)
  end

  it "tokenizes EPP tags and plain text" do
    lexer = Rouge::Lexers::EPP.new
    tokens = lexer.lex("Hello <%= $name %>!\n<%# comment %>")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentPreproc }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentMultiline }.should be_true
  end
end

describe Rouge::Lexers::ReScript do
  it "is registered as rescript and res" do
    Rouge::RegexLexer.find("rescript").should be_a(Rouge::Lexers::ReScript)
    Rouge::RegexLexer.find("res").should be_a(Rouge::Lexers::ReScript)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::ReScript.new
    tokens = lexer.lex("// comment\nlet x = 42\nif true { \"hello\" } else { \"world\" }")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "let" }.should be_true
  end
end
