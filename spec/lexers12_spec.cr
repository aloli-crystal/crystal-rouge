require "./spec_helper"

describe Rouge::Lexers::Fluent do
  it "is registered as fluent" do
    Rouge::RegexLexer.find("fluent").should be_a(Rouge::Lexers::Fluent)
  end

  it "tokenizes messages and placeables" do
    lexer = Rouge::Lexers::Fluent.new
    tokens = lexer.lex("# Comment\nhello = Hello {$name}")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameVariable && val == "$name" }.should be_true
  end
end

describe Rouge::Lexers::FreeFem do
  it "is registered as freefem and edp" do
    Rouge::RegexLexer.find("freefem").should be_a(Rouge::Lexers::FreeFem)
    Rouge::RegexLexer.find("edp").should be_a(Rouge::Lexers::FreeFem)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::FreeFem.new
    tokens = lexer.lex("// comment\nreal x = 1.0;")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "real" }.should be_true
  end
end

describe Rouge::Lexers::GhcCmm do
  it "is registered as cmm" do
    Rouge::RegexLexer.find("cmm").should be_a(Rouge::Lexers::GhcCmm)
  end

  it "tokenizes keywords and types" do
    lexer = Rouge::Lexers::GhcCmm.new
    tokens = lexer.lex("// comment\nif (bits32 x) { return; }")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "return" }.should be_true
  end
end

describe Rouge::Lexers::GhcCore do
  it "is registered as ghc_core and core" do
    Rouge::RegexLexer.find("ghc_core").should be_a(Rouge::Lexers::GhcCore)
    Rouge::RegexLexer.find("core").should be_a(Rouge::Lexers::GhcCore)
  end

  it "tokenizes keywords and type constructors" do
    lexer = Rouge::Lexers::GhcCore.new
    tokens = lexer.lex("-- comment\ncase x of { Int -> 42 }")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "case" }.should be_true
  end
end

describe Rouge::Lexers::Gherkin do
  it "is registered as gherkin, cucumber, and feature" do
    Rouge::RegexLexer.find("gherkin").should be_a(Rouge::Lexers::Gherkin)
    Rouge::RegexLexer.find("cucumber").should be_a(Rouge::Lexers::Gherkin)
    Rouge::RegexLexer.find("feature").should be_a(Rouge::Lexers::Gherkin)
  end

  it "tokenizes features and tags" do
    lexer = Rouge::Lexers::Gherkin.new
    tokens = lexer.lex("@login\nFeature: Login\n  Given a user")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val.includes?("Feature") }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameDecorator && val == "@login" }.should be_true
  end
end

describe Rouge::Lexers::GJS do
  it "is registered as gjs" do
    Rouge::RegexLexer.find("gjs").should be_a(Rouge::Lexers::GJS)
  end

  it "tokenizes template tags and JavaScript" do
    lexer = Rouge::Lexers::GJS.new
    tokens = lexer.lex("const x = 1;\n<template><div>hello</div></template>")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "const" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameTag && val == "<template>" }.should be_true
  end
end

describe Rouge::Lexers::Gradle do
  it "is registered as gradle" do
    Rouge::RegexLexer.find("gradle").should be_a(Rouge::Lexers::Gradle)
  end

  it "tokenizes Gradle DSL" do
    lexer = Rouge::Lexers::Gradle.new
    tokens = lexer.lex("// comment\napply plugin: 'java'\ndependencies { implementation 'lib:1.0' }")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "apply" }.should be_true
  end
end

describe Rouge::Lexers::GTS do
  it "is registered as gts" do
    Rouge::RegexLexer.find("gts").should be_a(Rouge::Lexers::GTS)
  end

  it "tokenizes TypeScript with template tags" do
    lexer = Rouge::Lexers::GTS.new
    tokens = lexer.lex("const x: number = 1;\n<template><div></div></template>")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "const" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameTag && val == "<template>" }.should be_true
  end
end

describe Rouge::Lexers::Hack do
  it "is registered as hack and hh" do
    Rouge::RegexLexer.find("hack").should be_a(Rouge::Lexers::Hack)
    Rouge::RegexLexer.find("hh").should be_a(Rouge::Lexers::Hack)
  end

  it "tokenizes Hack code" do
    lexer = Rouge::Lexers::Hack.new
    tokens = lexer.lex("// comment\nfunction foo(int $x): void { return; }")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "function" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameVariable && val == "$x" }.should be_true
  end
end

describe Rouge::Lexers::Haml do
  it "is registered as haml" do
    Rouge::RegexLexer.find("haml").should be_a(Rouge::Lexers::Haml)
  end

  it "tokenizes HAML elements" do
    lexer = Rouge::Lexers::Haml.new
    tokens = lexer.lex("%div.container\n  %p Hello")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameTag && val == "%div" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameClass && val == ".container" }.should be_true
  end
end

describe Rouge::Lexers::HLSL do
  it "is registered as hlsl" do
    Rouge::RegexLexer.find("hlsl").should be_a(Rouge::Lexers::HLSL)
  end

  it "tokenizes HLSL code" do
    lexer = Rouge::Lexers::HLSL.new
    tokens = lexer.lex("// comment\nfloat4 main(float4 pos : SV_Position) : SV_Target { return pos; }")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "float4" }.should be_true
  end
end

describe Rouge::Lexers::HOCON do
  it "is registered as hocon" do
    Rouge::RegexLexer.find("hocon").should be_a(Rouge::Lexers::HOCON)
  end

  it "tokenizes HOCON config" do
    lexer = Rouge::Lexers::HOCON.new
    tokens = lexer.lex("# comment\nkey = ${other.key}\nport = 8080")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::StrInterpol && val == "${other.key}" }.should be_true
  end
end

describe Rouge::Lexers::HQL do
  it "is registered as hql" do
    Rouge::RegexLexer.find("hql").should be_a(Rouge::Lexers::HQL)
  end

  it "tokenizes Hive SQL" do
    lexer = Rouge::Lexers::HQL.new
    tokens = lexer.lex("-- comment\nSELECT * FROM table STORED AS ORC;")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val =~ /SELECT/i }.should be_true
  end
end

describe Rouge::Lexers::HyLang do
  it "is registered as hylang and hy" do
    Rouge::RegexLexer.find("hylang").should be_a(Rouge::Lexers::HyLang)
    Rouge::RegexLexer.find("hy").should be_a(Rouge::Lexers::HyLang)
  end

  it "tokenizes Hy code" do
    lexer = Rouge::Lexers::HyLang.new
    tokens = lexer.lex("; comment\n(defn hello [name] (print name))")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "defn" }.should be_true
  end
end

describe Rouge::Lexers::IDLang do
  it "is registered as idlang and idl" do
    Rouge::RegexLexer.find("idlang").should be_a(Rouge::Lexers::IDLang)
    Rouge::RegexLexer.find("idl").should be_a(Rouge::Lexers::IDLang)
  end

  it "tokenizes IDL code" do
    lexer = Rouge::Lexers::IDLang.new
    tokens = lexer.lex("; comment\nPRO hello\n  PRINT, 'world'\nEND")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val =~ /PRO/i }.should be_true
  end
end

describe Rouge::Lexers::Idris do
  it "is registered as idris and idr" do
    Rouge::RegexLexer.find("idris").should be_a(Rouge::Lexers::Idris)
    Rouge::RegexLexer.find("idr").should be_a(Rouge::Lexers::Idris)
  end

  it "tokenizes Idris code" do
    lexer = Rouge::Lexers::Idris.new
    tokens = lexer.lex("-- comment\nmodule Main\nmain : IO ()\nmain = putStrLn \"hello\"")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "module" }.should be_true
  end
end

describe Rouge::Lexers::IECST do
  it "is registered as iecst" do
    Rouge::RegexLexer.find("iecst").should be_a(Rouge::Lexers::IECST)
  end

  it "tokenizes Structured Text" do
    lexer = Rouge::Lexers::IECST.new
    tokens = lexer.lex("// comment\nPROGRAM Main\nVAR\n  x : INT;\nEND_VAR\nEND_PROGRAM")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val =~ /PROGRAM/i }.should be_true
  end
end

describe Rouge::Lexers::IgorPro do
  it "is registered as igorpro and igor" do
    Rouge::RegexLexer.find("igorpro").should be_a(Rouge::Lexers::IgorPro)
    Rouge::RegexLexer.find("igor").should be_a(Rouge::Lexers::IgorPro)
  end

  it "tokenizes Igor Pro code" do
    lexer = Rouge::Lexers::IgorPro.new
    tokens = lexer.lex("// comment\nFunction hello()\n  Variable x = 42\nEnd")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "Function" }.should be_true
  end
end

describe Rouge::Lexers::IRB do
  it "is registered as irb and pry" do
    Rouge::RegexLexer.find("irb").should be_a(Rouge::Lexers::IRB)
    Rouge::RegexLexer.find("pry").should be_a(Rouge::Lexers::IRB)
  end

  it "tokenizes IRB sessions" do
    lexer = Rouge::Lexers::IRB.new
    tokens = lexer.lex("irb(main):001:0> puts \"hello\"\nhello\n=> nil")
    tokens.any? { |tok, _| tok == Rouge::Tokens::GenericPrompt }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "puts" }.should be_true
  end
end

describe Rouge::Lexers::Isabelle do
  it "is registered as isabelle" do
    Rouge::RegexLexer.find("isabelle").should be_a(Rouge::Lexers::Isabelle)
  end

  it "tokenizes Isabelle code" do
    lexer = Rouge::Lexers::Isabelle.new
    tokens = lexer.lex("theory Main\nimports Main\nbegin\nlemma \"True\" by auto\nend")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "theory" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "lemma" }.should be_true
  end
end

describe Rouge::Lexers::ISBL do
  it "is registered as isbl" do
    Rouge::RegexLexer.find("isbl").should be_a(Rouge::Lexers::ISBL)
  end

  it "tokenizes ISBL code" do
    lexer = Rouge::Lexers::ISBL.new
    tokens = lexer.lex("// comment\nif x then\n  dim y\nendif")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "if" }.should be_true
  end
end

describe Rouge::Lexers::Janet do
  it "is registered as janet" do
    Rouge::RegexLexer.find("janet").should be_a(Rouge::Lexers::Janet)
  end

  it "tokenizes Janet code" do
    lexer = Rouge::Lexers::Janet.new
    tokens = lexer.lex("# comment\n(defn hello [name] (print name))")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "defn" }.should be_true
  end
end

describe Rouge::Lexers::JSL do
  it "is registered as jsl" do
    Rouge::RegexLexer.find("jsl").should be_a(Rouge::Lexers::JSL)
  end

  it "tokenizes JSL code" do
    lexer = Rouge::Lexers::JSL.new
    tokens = lexer.lex("// comment\nIf(x > 0, Show(x))")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "If" }.should be_true
  end
end

describe Rouge::Lexers::JSONDoc do
  it "is registered as json_doc" do
    Rouge::RegexLexer.find("json_doc").should be_a(Rouge::Lexers::JSONDoc)
  end

  it "tokenizes JSONC with comments" do
    lexer = Rouge::Lexers::JSONDoc.new
    tokens = lexer.lex("// comment\n{\"key\": true}")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::KeywordConstant }.should be_true
  end
end

describe Rouge::Lexers::JSP do
  it "is registered as jsp" do
    Rouge::RegexLexer.find("jsp").should be_a(Rouge::Lexers::JSP)
  end

  it "tokenizes JSP code" do
    lexer = Rouge::Lexers::JSP.new
    tokens = lexer.lex("<%= request.getParameter(\"name\") %>\n<html><body></body></html>")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentPreproc }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameTag && val.includes?("html") }.should be_true
  end
end

describe Rouge::Lexers::KickAssembler do
  it "is registered as kickassembler and kick_asm" do
    Rouge::RegexLexer.find("kickassembler").should be_a(Rouge::Lexers::KickAssembler)
    Rouge::RegexLexer.find("kick_asm").should be_a(Rouge::Lexers::KickAssembler)
  end

  it "tokenizes 6502 assembly" do
    lexer = Rouge::Lexers::KickAssembler.new
    tokens = lexer.lex("// comment\n.pc = $0801\nlda #$00\nsta $d020")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val =~ /lda/i }.should be_true
  end
end

describe Rouge::Lexers::LiterateCoffeeScript do
  it "is registered as literate_coffeescript and litcoffee" do
    Rouge::RegexLexer.find("literate_coffeescript").should be_a(Rouge::Lexers::LiterateCoffeeScript)
    Rouge::RegexLexer.find("litcoffee").should be_a(Rouge::Lexers::LiterateCoffeeScript)
  end

  it "tokenizes literate coffeescript" do
    lexer = Rouge::Lexers::LiterateCoffeeScript.new
    tokens = lexer.lex("Some text.\n    if true\n    console.log 42")
    tokens.any? { |tok, _| tok == Rouge::Tokens::GenericOutput }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "if" }.should be_true
  end
end

describe Rouge::Lexers::LiterateHaskell do
  it "is registered as literate_haskell and lhs" do
    Rouge::RegexLexer.find("literate_haskell").should be_a(Rouge::Lexers::LiterateHaskell)
    Rouge::RegexLexer.find("lhs").should be_a(Rouge::Lexers::LiterateHaskell)
  end

  it "tokenizes bird-style literate haskell" do
    lexer = Rouge::Lexers::LiterateHaskell.new
    tokens = lexer.lex("This is a comment.\n\n> main = putStrLn \"hello\"")
    tokens.any? { |tok, _| tok == Rouge::Tokens::GenericPrompt }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end
end

describe Rouge::Lexers::LiveScript do
  it "is registered as livescript and ls" do
    Rouge::RegexLexer.find("livescript").should be_a(Rouge::Lexers::LiveScript)
    Rouge::RegexLexer.find("ls").should be_a(Rouge::Lexers::LiveScript)
  end

  it "tokenizes LiveScript code" do
    lexer = Rouge::Lexers::LiveScript.new
    tokens = lexer.lex("# comment\nif true then console.log \"hello\"")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "if" }.should be_true
  end
end
