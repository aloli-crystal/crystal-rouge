require "./spec_helper"

describe Rouge::Lexers::LLVM do
  it "is registered as llvm" do
    Rouge::RegexLexer.find("llvm").should be_a(Rouge::Lexers::LLVM)
  end

  it "tokenizes keywords, types and comments" do
    lexer = Rouge::Lexers::LLVM.new
    tokens = lexer.lex("; comment\ndefine i32 @main() {\n  %x = add i32 1, 2\n  ret i32 %x\n}")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "define" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "i32" }.should be_true
  end
end

describe Rouge::Lexers::Lustre do
  it "is registered as lustre" do
    Rouge::RegexLexer.find("lustre").should be_a(Rouge::Lexers::Lustre)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::Lustre.new
    tokens = lexer.lex("-- comment\nnode counter(reset: bool) returns (c: int);\nlet\n  c = 0 -> pre c + 1;\ntel")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "node" }.should be_true
  end
end

describe Rouge::Lexers::Lutin do
  it "is registered as lutin" do
    Rouge::RegexLexer.find("lutin").should be_a(Rouge::Lexers::Lutin)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::Lutin.new
    tokens = lexer.lex("-- comment\nnode main() =\nlet\n  assert x > 0\ntel")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "node" }.should be_true
  end
end

describe Rouge::Lexers::M68k do
  it "is registered as m68k" do
    Rouge::RegexLexer.find("m68k").should be_a(Rouge::Lexers::M68k)
  end

  it "tokenizes instructions, registers and comments" do
    lexer = Rouge::Lexers::M68k.new
    tokens = lexer.lex("; comment\nmove.l #42, d0\nadd.w d1, d0\nrts")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameBuiltin && val == "d0" }.should be_true
  end
end

describe Rouge::Lexers::Magik do
  it "is registered as magik" do
    Rouge::RegexLexer.find("magik").should be_a(Rouge::Lexers::Magik)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::Magik.new
    tokens = lexer.lex("# comment\n_method my_class.my_method\n  _return _true\n_endmethod")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "_method" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordConstant && val == "_true" }.should be_true
  end
end

describe Rouge::Lexers::Mason do
  it "is registered as mason" do
    Rouge::RegexLexer.find("mason").should be_a(Rouge::Lexers::Mason)
  end

  it "tokenizes mason tags" do
    lexer = Rouge::Lexers::Mason.new
    tokens = lexer.lex("<%perl>\nmy $x = 1;\n</%perl>\n<div>hello</div>")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentPreproc }.should be_true
  end
end

describe Rouge::Lexers::Mathematica do
  it "is registered as mathematica and wolfram" do
    Rouge::RegexLexer.find("mathematica").should be_a(Rouge::Lexers::Mathematica)
    Rouge::RegexLexer.find("wolfram").should be_a(Rouge::Lexers::Mathematica)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::Mathematica.new
    tokens = lexer.lex("(* comment *)\nModule[{x = 42}, Print[x]]")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentMultiline }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "Module" }.should be_true
  end
end

describe Rouge::Lexers::Meson do
  it "is registered as meson" do
    Rouge::RegexLexer.find("meson").should be_a(Rouge::Lexers::Meson)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::Meson.new
    tokens = lexer.lex("# comment\nproject('myapp', 'c')\nexecutable('main', 'main.c')")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameBuiltin && val == "project" }.should be_true
  end
end

describe Rouge::Lexers::MiniZinc do
  it "is registered as minizinc and mzn" do
    Rouge::RegexLexer.find("minizinc").should be_a(Rouge::Lexers::MiniZinc)
    Rouge::RegexLexer.find("mzn").should be_a(Rouge::Lexers::MiniZinc)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::MiniZinc.new
    tokens = lexer.lex("% comment\nvar int: x;\nconstraint x > 0;\nsolve satisfy;")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "constraint" }.should be_true
  end
end

describe Rouge::Lexers::MoonScript do
  it "is registered as moonscript and moon" do
    Rouge::RegexLexer.find("moonscript").should be_a(Rouge::Lexers::MoonScript)
    Rouge::RegexLexer.find("moon").should be_a(Rouge::Lexers::MoonScript)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::MoonScript.new
    tokens = lexer.lex("-- comment\nclass Hello\n  new: =>\n    @name = \"world\"")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "class" }.should be_true
  end
end

describe Rouge::Lexers::Mosel do
  it "is registered as mosel" do
    Rouge::RegexLexer.find("mosel").should be_a(Rouge::Lexers::Mosel)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::Mosel.new
    tokens = lexer.lex("! comment\nmodel example\nuses \"mmxprs\"\nend-model")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "model" }.should be_true
  end
end

describe Rouge::Lexers::MsgTrans do
  it "is registered as msgtrans" do
    Rouge::RegexLexer.find("msgtrans").should be_a(Rouge::Lexers::MsgTrans)
  end

  it "tokenizes key:value pairs and comments" do
    lexer = Rouge::Lexers::MsgTrans.new
    tokens = lexer.lex("# comment\nHello:World")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameLabel && val == "Hello" }.should be_true
  end
end

describe Rouge::Lexers::MXML do
  it "is registered as mxml" do
    Rouge::RegexLexer.find("mxml").should be_a(Rouge::Lexers::MXML)
  end

  it "tokenizes XML tags" do
    lexer = Rouge::Lexers::MXML.new
    tokens = lexer.lex("<?xml version=\"1.0\"?>\n<mx:Application>\n</mx:Application>")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentPreproc }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameTag }.should be_true
  end
end

describe Rouge::Lexers::NESASM do
  it "is registered as nesasm" do
    Rouge::RegexLexer.find("nesasm").should be_a(Rouge::Lexers::NESASM)
  end

  it "tokenizes instructions and directives" do
    lexer = Rouge::Lexers::NESASM.new
    tokens = lexer.lex("; comment\n.inesprg 1\nlda #$00\nsta $2000")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumHex && val == "$00" }.should be_true
  end
end

describe Rouge::Lexers::Nial do
  it "is registered as nial" do
    Rouge::RegexLexer.find("nial").should be_a(Rouge::Lexers::Nial)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::Nial.new
    tokens = lexer.lex("% comment\nx is 42;\nif x > 0 then\n  sum x\nendif;")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "is" }.should be_true
  end
end

describe Rouge::Lexers::ObjectiveCpp do
  it "is registered as objective_cpp and objcpp" do
    Rouge::RegexLexer.find("objective_cpp").should be_a(Rouge::Lexers::ObjectiveCpp)
    Rouge::RegexLexer.find("objcpp").should be_a(Rouge::Lexers::ObjectiveCpp)
  end

  it "tokenizes ObjC and C++ keywords" do
    lexer = Rouge::Lexers::ObjectiveCpp.new
    tokens = lexer.lex("// comment\n@interface Foo\n@end\nclass Bar {};")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "class" }.should be_true
  end
end

describe Rouge::Lexers::OCL do
  it "is registered as ocl" do
    Rouge::RegexLexer.find("ocl").should be_a(Rouge::Lexers::OCL)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::OCL.new
    tokens = lexer.lex("-- comment\ncontext Person inv:\n  self.age > 0")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "context" }.should be_true
  end
end

describe Rouge::Lexers::OpenEdge do
  it "is registered as openedge, progress, and abl" do
    Rouge::RegexLexer.find("openedge").should be_a(Rouge::Lexers::OpenEdge)
    Rouge::RegexLexer.find("progress").should be_a(Rouge::Lexers::OpenEdge)
    Rouge::RegexLexer.find("abl").should be_a(Rouge::Lexers::OpenEdge)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::OpenEdge.new
    tokens = lexer.lex("/* comment */\nDEFINE VARIABLE x AS INTEGER NO-UNDO.\nASSIGN x = 42.")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentMultiline }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val =~ /DEFINE/i }.should be_true
  end
end

describe Rouge::Lexers::OpenTypeFeatureFile do
  it "is registered as opentype_feature_file and fea" do
    Rouge::RegexLexer.find("opentype_feature_file").should be_a(Rouge::Lexers::OpenTypeFeatureFile)
    Rouge::RegexLexer.find("fea").should be_a(Rouge::Lexers::OpenTypeFeatureFile)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::OpenTypeFeatureFile.new
    tokens = lexer.lex("# comment\nfeature liga {\n  sub f i by fi;\n} liga;")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "feature" }.should be_true
  end
end

describe Rouge::Lexers::P4 do
  it "is registered as p4" do
    Rouge::RegexLexer.find("p4").should be_a(Rouge::Lexers::P4)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::P4.new
    tokens = lexer.lex("// comment\nheader ethernet_t {\n  bit<48> dstAddr;\n}")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "header" }.should be_true
  end
end

describe Rouge::Lexers::PDFLexer do
  it "is registered as pdf" do
    Rouge::RegexLexer.find("pdf").should be_a(Rouge::Lexers::PDFLexer)
  end

  it "tokenizes PDF syntax" do
    lexer = Rouge::Lexers::PDFLexer.new
    tokens = lexer.lex("% comment\n1 0 obj\n<< /Type /Catalog >>\nendobj")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "obj" }.should be_true
  end
end

describe Rouge::Lexers::Plist do
  it "is registered as plist" do
    Rouge::RegexLexer.find("plist").should be_a(Rouge::Lexers::Plist)
  end

  it "tokenizes plist XML tags" do
    lexer = Rouge::Lexers::Plist.new
    tokens = lexer.lex("<?xml version=\"1.0\"?>\n<dict>\n<key>name</key>\n<string>value</string>\n</dict>")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentPreproc }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameTag }.should be_true
  end
end

describe Rouge::Lexers::PLSQL do
  it "is registered as plsql" do
    Rouge::RegexLexer.find("plsql").should be_a(Rouge::Lexers::PLSQL)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::PLSQL.new
    tokens = lexer.lex("-- comment\nDECLARE\n  x NUMBER := 42;\nBEGIN\n  RETURN x;\nEND;")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val =~ /DECLARE/i }.should be_true
  end
end

describe Rouge::Lexers::PostScript do
  it "is registered as postscript and ps" do
    Rouge::RegexLexer.find("postscript").should be_a(Rouge::Lexers::PostScript)
    Rouge::RegexLexer.find("ps").should be_a(Rouge::Lexers::PostScript)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::PostScript.new
    tokens = lexer.lex("% comment\n/myvar 42 def\n(Hello) print")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "def" }.should be_true
  end
end

describe Rouge::Lexers::Praat do
  it "is registered as praat" do
    Rouge::RegexLexer.find("praat").should be_a(Rouge::Lexers::Praat)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::Praat.new
    tokens = lexer.lex("# comment\nif x > 0\n  printline hello\nendif")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "if" }.should be_true
  end
end

describe Rouge::Lexers::Prometheus do
  it "is registered as prometheus and promql" do
    Rouge::RegexLexer.find("prometheus").should be_a(Rouge::Lexers::Prometheus)
    Rouge::RegexLexer.find("promql").should be_a(Rouge::Lexers::Prometheus)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::Prometheus.new
    tokens = lexer.lex("# comment\nsum(rate(http_requests_total[5m])) by (status)")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "sum" }.should be_true
  end
end

describe Rouge::Lexers::QLang do
  it "is registered as q and kdb" do
    Rouge::RegexLexer.find("q").should be_a(Rouge::Lexers::QLang)
    Rouge::RegexLexer.find("kdb").should be_a(Rouge::Lexers::QLang)
  end

  it "tokenizes keywords and symbols" do
    lexer = Rouge::Lexers::QLang.new
    tokens = lexer.lex("select sum qty from trades where date=2024.01.01")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "select" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "from" }.should be_true
  end
end

describe Rouge::Lexers::ReasonML do
  it "is registered as reasonml, re, and reason" do
    Rouge::RegexLexer.find("reasonml").should be_a(Rouge::Lexers::ReasonML)
    Rouge::RegexLexer.find("re").should be_a(Rouge::Lexers::ReasonML)
    Rouge::RegexLexer.find("reason").should be_a(Rouge::Lexers::ReasonML)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::ReasonML.new
    tokens = lexer.lex("/* comment */\nlet x = 42;\nswitch (x) {\n| 1 => true\n| _ => false\n};")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentMultiline }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "let" }.should be_true
  end
end

describe Rouge::Lexers::Rego do
  it "is registered as rego" do
    Rouge::RegexLexer.find("rego").should be_a(Rouge::Lexers::Rego)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::Rego.new
    tokens = lexer.lex("# comment\npackage example\nimport data.users\ndefault allow = false")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "package" }.should be_true
  end
end
