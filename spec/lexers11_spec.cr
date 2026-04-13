require "./spec_helper"

describe Rouge::Lexers::Apex do
  it "is registered as apex" do
    Rouge::RegexLexer.find("apex").should be_a(Rouge::Lexers::Apex)
  end

  it "tokenizes keywords, strings and comments" do
    lexer = Rouge::Lexers::Apex.new
    tokens = lexer.lex("// comment\npublic class MyClass { String s = 'hello'; }")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "public" }.should be_true
  end
end

describe Rouge::Lexers::APIBlueprint do
  it "is registered as apiblueprint and apib" do
    Rouge::RegexLexer.find("apiblueprint").should be_a(Rouge::Lexers::APIBlueprint)
    Rouge::RegexLexer.find("apib").should be_a(Rouge::Lexers::APIBlueprint)
  end

  it "tokenizes HTTP methods and headings" do
    lexer = Rouge::Lexers::APIBlueprint.new
    tokens = lexer.lex("# My API\nGET /users")
    tokens.any? { |tok, _| tok == Rouge::Tokens::GenericHeading }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordReserved && val == "GET" }.should be_true
  end
end

describe Rouge::Lexers::ArmAsm do
  it "is registered as armasm and arm" do
    Rouge::RegexLexer.find("armasm").should be_a(Rouge::Lexers::ArmAsm)
    Rouge::RegexLexer.find("arm").should be_a(Rouge::Lexers::ArmAsm)
  end

  it "tokenizes instructions and registers" do
    lexer = Rouge::Lexers::ArmAsm.new
    tokens = lexer.lex("MOV R0, #42\n; comment")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val =~ /MOV/i }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end
end

describe Rouge::Lexers::Augeas do
  it "is registered as augeas" do
    Rouge::RegexLexer.find("augeas").should be_a(Rouge::Lexers::Augeas)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::Augeas.new
    tokens = lexer.lex("(* comment *)\nmodule Test = let x = \"hello\"")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentMultiline }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "module" }.should be_true
  end
end

describe Rouge::Lexers::BBCBasic do
  it "is registered as bbcbasic" do
    Rouge::RegexLexer.find("bbcbasic").should be_a(Rouge::Lexers::BBCBasic)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::BBCBasic.new
    tokens = lexer.lex("REM This is a comment\nPRINT \"Hello\"")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val =~ /PRINT/i }.should be_true
  end
end

describe Rouge::Lexers::Bicep do
  it "is registered as bicep" do
    Rouge::RegexLexer.find("bicep").should be_a(Rouge::Lexers::Bicep)
  end

  it "tokenizes keywords and strings" do
    lexer = Rouge::Lexers::Bicep.new
    tokens = lexer.lex("// comment\nparam name string = 'hello'")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "param" }.should be_true
  end
end

describe Rouge::Lexers::BIML do
  it "is registered as biml" do
    Rouge::RegexLexer.find("biml").should be_a(Rouge::Lexers::BIML)
  end

  it "tokenizes XML tags" do
    lexer = Rouge::Lexers::BIML.new
    tokens = lexer.lex("<Biml xmlns=\"http://example.com\"><!-- comment --></Biml>")
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameTag }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::Comment }.should be_true
  end
end

describe Rouge::Lexers::BPF do
  it "is registered as bpf" do
    Rouge::RegexLexer.find("bpf").should be_a(Rouge::Lexers::BPF)
  end

  it "tokenizes instructions and registers" do
    lexer = Rouge::Lexers::BPF.new
    tokens = lexer.lex("mov r0, 0\n; comment\nexit")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val =~ /mov/i }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end
end

describe Rouge::Lexers::BrightScript do
  it "is registered as brightscript and brs" do
    Rouge::RegexLexer.find("brightscript").should be_a(Rouge::Lexers::BrightScript)
    Rouge::RegexLexer.find("brs").should be_a(Rouge::Lexers::BrightScript)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::BrightScript.new
    tokens = lexer.lex("' comment\nfunction hello()\n  print \"hi\"\nend function")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val =~ /function/i }.should be_true
  end
end

describe Rouge::Lexers::BSL do
  it "is registered as bsl and 1c" do
    Rouge::RegexLexer.find("bsl").should be_a(Rouge::Lexers::BSL)
    Rouge::RegexLexer.find("1c").should be_a(Rouge::Lexers::BSL)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::BSL.new
    tokens = lexer.lex("// comment\nIf x = 1 Then\n  Return;\nEndIf;")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val =~ /If/i }.should be_true
  end
end

describe Rouge::Lexers::Ceylon do
  it "is registered as ceylon" do
    Rouge::RegexLexer.find("ceylon").should be_a(Rouge::Lexers::Ceylon)
  end

  it "tokenizes keywords, strings and comments" do
    lexer = Rouge::Lexers::Ceylon.new
    tokens = lexer.lex("// comment\nclass Hello() {\n  void run() { print(\"hello\"); }\n}")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "class" }.should be_true
  end
end

describe Rouge::Lexers::CFScript do
  it "is registered as cfscript and cfc" do
    Rouge::RegexLexer.find("cfscript").should be_a(Rouge::Lexers::CFScript)
    Rouge::RegexLexer.find("cfc").should be_a(Rouge::Lexers::CFScript)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::CFScript.new
    tokens = lexer.lex("// comment\nvar x = 42;\nfunction test() { return x; }")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "var" }.should be_true
  end
end

describe Rouge::Lexers::CiscoIOS do
  it "is registered as cisco_ios and ios" do
    Rouge::RegexLexer.find("cisco_ios").should be_a(Rouge::Lexers::CiscoIOS)
    Rouge::RegexLexer.find("ios").should be_a(Rouge::Lexers::CiscoIOS)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::CiscoIOS.new
    tokens = lexer.lex("! comment\ninterface GigabitEthernet0/0\n ip address 10.0.0.1")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val =~ /interface/i }.should be_true
  end
end

describe Rouge::Lexers::Clean do
  it "is registered as clean" do
    Rouge::RegexLexer.find("clean").should be_a(Rouge::Lexers::Clean)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::Clean.new
    tokens = lexer.lex("// comment\nmodule Main\nimport StdEnv\nStart = 42")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "module" }.should be_true
  end
end

describe Rouge::Lexers::CMHG do
  it "is registered as cmhg" do
    Rouge::RegexLexer.find("cmhg").should be_a(Rouge::Lexers::CMHG)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::CMHG.new
    tokens = lexer.lex("; comment\ntitle-string: \"My Module\"")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
  end
end

describe Rouge::Lexers::Codeowners do
  it "is registered as codeowners" do
    Rouge::RegexLexer.find("codeowners").should be_a(Rouge::Lexers::Codeowners)
  end

  it "tokenizes patterns and owners" do
    lexer = Rouge::Lexers::Codeowners.new
    tokens = lexer.lex("# comment\n*.js @user/team")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameBuiltin }.should be_true
  end
end

describe Rouge::Lexers::CommonLisp do
  it "is registered as common_lisp, lisp and cl" do
    Rouge::RegexLexer.find("common_lisp").should be_a(Rouge::Lexers::CommonLisp)
    Rouge::RegexLexer.find("lisp").should be_a(Rouge::Lexers::CommonLisp)
    Rouge::RegexLexer.find("cl").should be_a(Rouge::Lexers::CommonLisp)
  end

  it "tokenizes keywords, strings and comments" do
    lexer = Rouge::Lexers::CommonLisp.new
    tokens = lexer.lex("; comment\n(defun hello () (format t \"Hello\"))")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "defun" }.should be_true
  end
end

describe Rouge::Lexers::Conf do
  it "is registered as conf and config" do
    Rouge::RegexLexer.find("conf").should be_a(Rouge::Lexers::Conf)
    Rouge::RegexLexer.find("config").should be_a(Rouge::Lexers::Conf)
  end

  it "tokenizes sections, keys and comments" do
    lexer = Rouge::Lexers::Conf.new
    tokens = lexer.lex("# comment\n[section]\nkey = value")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameNamespace }.should be_true
  end
end

describe Rouge::Lexers::CSVS do
  it "is registered as csvs" do
    Rouge::RegexLexer.find("csvs").should be_a(Rouge::Lexers::CSVS)
  end

  it "tokenizes keywords" do
    lexer = Rouge::Lexers::CSVS.new
    tokens = lexer.lex("version 1.0\ntotalColumns 3")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val =~ /version/i }.should be_true
  end
end

describe Rouge::Lexers::Cypher do
  it "is registered as cypher" do
    Rouge::RegexLexer.find("cypher").should be_a(Rouge::Lexers::Cypher)
  end

  it "tokenizes keywords, strings and comments" do
    lexer = Rouge::Lexers::Cypher.new
    tokens = lexer.lex("// comment\nMATCH (n:Person) WHERE n.name = 'Alice' RETURN n")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "MATCH" }.should be_true
  end
end

describe Rouge::Lexers::Cython do
  it "is registered as cython and pyx" do
    Rouge::RegexLexer.find("cython").should be_a(Rouge::Lexers::Cython)
    Rouge::RegexLexer.find("pyx").should be_a(Rouge::Lexers::Cython)
  end

  it "tokenizes Cython and Python keywords" do
    lexer = Rouge::Lexers::Cython.new
    tokens = lexer.lex("# comment\ncdef int x = 42\ndef hello():\n  print('hi')")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordReserved && val == "cdef" }.should be_true
  end
end

describe Rouge::Lexers::Dafny do
  it "is registered as dafny" do
    Rouge::RegexLexer.find("dafny").should be_a(Rouge::Lexers::Dafny)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::Dafny.new
    tokens = lexer.lex("// comment\nmethod Max(a: int, b: int) returns (c: int)\n  ensures c >= a")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "method" }.should be_true
  end
end

describe Rouge::Lexers::DataStudio do
  it "is registered as datastudio" do
    Rouge::RegexLexer.find("datastudio").should be_a(Rouge::Lexers::DataStudio)
  end

  it "tokenizes functions and numbers" do
    lexer = Rouge::Lexers::DataStudio.new
    tokens = lexer.lex("SUM(Revenue) + COUNT(Users)")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameBuiltin && val == "SUM" }.should be_true
  end
end

describe Rouge::Lexers::Digdag do
  it "is registered as digdag" do
    Rouge::RegexLexer.find("digdag").should be_a(Rouge::Lexers::Digdag)
  end

  it "tokenizes tasks and operators" do
    lexer = Rouge::Lexers::Digdag.new
    tokens = lexer.lex("# comment\n+task:\n  sh>: echo hello")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameFunction }.should be_true
  end
end

describe Rouge::Lexers::Dylan do
  it "is registered as dylan" do
    Rouge::RegexLexer.find("dylan").should be_a(Rouge::Lexers::Dylan)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::Dylan.new
    tokens = lexer.lex("// comment\ndefine method hello ()\n  \"Hello\"\nend method;")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "define" }.should be_true
  end
end

describe Rouge::Lexers::ECL do
  it "is registered as ecl" do
    Rouge::RegexLexer.find("ecl").should be_a(Rouge::Lexers::ECL)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::ECL.new
    tokens = lexer.lex("// comment\nOUTPUT('Hello');")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val =~ /OUTPUT/i }.should be_true
  end
end

describe Rouge::Lexers::EEx do
  it "is registered as eex" do
    Rouge::RegexLexer.find("eex").should be_a(Rouge::Lexers::EEx)
  end

  it "tokenizes EEx tags and HTML" do
    lexer = Rouge::Lexers::EEx.new
    tokens = lexer.lex("<div><%= @name %></div>")
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameTag }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentPreproc }.should be_true
  end
end

describe Rouge::Lexers::Email do
  it "is registered as email" do
    Rouge::RegexLexer.find("email").should be_a(Rouge::Lexers::Email)
  end

  it "tokenizes headers" do
    lexer = Rouge::Lexers::Email.new
    tokens = lexer.lex("From: user@example.com\nSubject: Hello")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameAttribute && val == "From" }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameLabel }.should be_true
  end
end

describe Rouge::Lexers::EscapeSequence do
  it "is registered as escape" do
    Rouge::RegexLexer.find("escape").should be_a(Rouge::Lexers::EscapeSequence)
  end

  it "tokenizes escape sequences and plain text" do
    lexer = Rouge::Lexers::EscapeSequence.new
    tokens = lexer.lex("\e[31mHello\e[0m")
    tokens.any? { |tok, _| tok == Rouge::Tokens::Escape }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Text && val == "Hello" }.should be_true
  end
end
