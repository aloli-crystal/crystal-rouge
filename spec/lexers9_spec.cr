require "./spec_helper"

describe Rouge::Lexers::Io do
  it "is registered as io" do
    lexer = Rouge::RegexLexer.find("io")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::Io)
  end

  it "tokenizes keywords and strings" do
    lexer = Rouge::Lexers::Io.new
    tokens = lexer.lex("if (x == true) method(\"hello\")")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "if" }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
  end
end

describe Rouge::Lexers::J do
  it "is registered as j" do
    lexer = Rouge::RegexLexer.find("j")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::J)
  end

  it "tokenizes comments and strings" do
    lexer = Rouge::Lexers::J.new
    tokens = lexer.lex("NB. comment\n'hello'")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrSingle }.should be_true
  end
end

describe Rouge::Lexers::Factor do
  it "is registered as factor" do
    lexer = Rouge::RegexLexer.find("factor")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::Factor)
  end

  it "tokenizes keywords and numbers" do
    lexer = Rouge::Lexers::Factor.new
    tokens = lexer.lex("USING: math ; 42 3.14")
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true
  end
end

describe Rouge::Lexers::NASM do
  it "is registered as nasm and asm" do
    lexer = Rouge::RegexLexer.find("nasm")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::NASM)

    lexer2 = Rouge::RegexLexer.find("asm")
    lexer2.should_not be_nil
    lexer2.should be_a(Rouge::Lexers::NASM)
  end

  it "tokenizes instructions and registers" do
    lexer = Rouge::Lexers::NASM.new
    tokens = lexer.lex("mov eax, 0xFF ; comment")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "mov" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameBuiltin && val == "eax" }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NumHex }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end
end

describe Rouge::Lexers::COBOL do
  it "is registered as cobol" do
    lexer = Rouge::RegexLexer.find("cobol")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::COBOL)
  end

  it "tokenizes keywords and strings" do
    lexer = Rouge::Lexers::COBOL.new
    tokens = lexer.lex("DISPLAY \"Hello World\".")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "DISPLAY" }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
  end
end

describe Rouge::Lexers::Pony do
  it "is registered as pony" do
    lexer = Rouge::RegexLexer.find("pony")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::Pony)
  end

  it "tokenizes keywords and capabilities" do
    lexer = Rouge::Lexers::Pony.new
    tokens = lexer.lex("actor Main\n  let x: iso = recover \"hi\" end")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "actor" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "iso" }.should be_true
  end
end

describe Rouge::Lexers::Lean do
  it "is registered as lean" do
    lexer = Rouge::RegexLexer.find("lean")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::Lean)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::Lean.new
    tokens = lexer.lex("theorem foo : Nat := by -- prove\n  42")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "theorem" }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end
end

describe Rouge::Lexers::QML do
  it "is registered as qml" do
    lexer = Rouge::RegexLexer.find("qml")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::QML)
  end

  it "tokenizes imports and types" do
    lexer = Rouge::Lexers::QML.new
    tokens = lexer.lex("import QtQuick 2.0\nRectangle { width: 100 }")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "import" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "Rectangle" }.should be_true
  end
end

describe Rouge::Lexers::Fish do
  it "is registered as fish" do
    lexer = Rouge::RegexLexer.find("fish")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::Fish)
  end

  it "tokenizes keywords and variables" do
    lexer = Rouge::Lexers::Fish.new
    tokens = lexer.lex("set -l name \"world\"\necho $name")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "set" }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameVariable }.should be_true
  end
end

describe Rouge::Lexers::SAS do
  it "is registered as sas" do
    lexer = Rouge::RegexLexer.find("sas")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::SAS)
  end

  it "tokenizes keywords and macro keywords" do
    lexer = Rouge::Lexers::SAS.new
    tokens = lexer.lex("data test; set input; %let x = 1; run;")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "data" }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::KeywordReserved }.should be_true
  end
end

describe Rouge::Lexers::Smalltalk do
  it "is registered as smalltalk and st" do
    lexer = Rouge::RegexLexer.find("smalltalk")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::Smalltalk)

    lexer2 = Rouge::RegexLexer.find("st")
    lexer2.should_not be_nil
    lexer2.should be_a(Rouge::Lexers::Smalltalk)
  end

  it "tokenizes keywords and symbols" do
    lexer = Rouge::Lexers::Smalltalk.new
    tokens = lexer.lex("self value. #symbol 'string' $A 42")
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordConstant && val == "self" }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrSymbol }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrSingle }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrChar }.should be_true
  end
end

describe Rouge::Lexers::Forth do
  it "is registered as forth and fth" do
    lexer = Rouge::RegexLexer.find("forth")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::Forth)

    lexer2 = Rouge::RegexLexer.find("fth")
    lexer2.should_not be_nil
    lexer2.should be_a(Rouge::Lexers::Forth)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::Forth.new
    tokens = lexer.lex(": square DUP * ; \\ compute square")
    tokens.any? { |tok, _| tok == Rouge::Tokens::KeywordDeclaration }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameBuiltin && val == "DUP" }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end
end

describe Rouge::Lexers::VLang do
  it "is registered as vlang and v" do
    lexer = Rouge::RegexLexer.find("vlang")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::VLang)

    lexer2 = Rouge::RegexLexer.find("vlang")
    lexer2.should_not be_nil
  end

  it "tokenizes keywords and strings with interpolation" do
    lexer = Rouge::Lexers::VLang.new
    tokens = lexer.lex("fn main() {\n  x := 42\n  println(\"val: ${x}\")\n}")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "fn" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true
  end
end
