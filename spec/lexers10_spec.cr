require "./spec_helper"

describe Rouge::Lexers::ABAP do
  it "is registered as abap" do
    lexer = Rouge::RegexLexer.find("abap")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::ABAP)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::ABAP.new
    tokens = lexer.lex("REPORT ztest.")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val =~ /REPORT/i }.should be_true
  end
end

describe Rouge::Lexers::ActionScript do
  it "is registered as actionscript and as3" do
    Rouge::RegexLexer.find("actionscript").should be_a(Rouge::Lexers::ActionScript)
    Rouge::RegexLexer.find("as3").should be_a(Rouge::Lexers::ActionScript)
  end

  it "tokenizes keywords, strings and comments" do
    lexer = Rouge::Lexers::ActionScript.new
    tokens = lexer.lex("// comment\nvar x:int = 42;\nfunction foo():void { return; }")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "var" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true
  end
end

describe Rouge::Lexers::Ada do
  it "is registered as ada" do
    Rouge::RegexLexer.find("ada").should be_a(Rouge::Lexers::Ada)
  end

  it "tokenizes keywords, comments and strings" do
    lexer = Rouge::Lexers::Ada.new
    tokens = lexer.lex("-- comment\nprocedure Hello is\nbegin\n  null;\nend Hello;")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val =~ /procedure/i }.should be_true
  end
end

describe Rouge::Lexers::Apache do
  it "is registered as apache and apacheconf" do
    Rouge::RegexLexer.find("apache").should be_a(Rouge::Lexers::Apache)
    Rouge::RegexLexer.find("apacheconf").should be_a(Rouge::Lexers::Apache)
  end

  it "tokenizes directives and comments" do
    lexer = Rouge::Lexers::Apache.new
    tokens = lexer.lex("# comment\nServerName example.com\nListen 80")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "ServerName" }.should be_true
  end
end

describe Rouge::Lexers::Awk do
  it "is registered as awk" do
    Rouge::RegexLexer.find("awk").should be_a(Rouge::Lexers::Awk)
  end

  it "tokenizes keywords, variables and comments" do
    lexer = Rouge::Lexers::Awk.new
    tokens = lexer.lex("# comment\nBEGIN { print \"hello\" }\n{ print $1, NR }")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "BEGIN" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameVariable && val == "$1" }.should be_true
  end
end

describe Rouge::Lexers::Batchfile do
  it "is registered as batchfile, bat, and cmd" do
    Rouge::RegexLexer.find("batchfile").should be_a(Rouge::Lexers::Batchfile)
    Rouge::RegexLexer.find("bat").should be_a(Rouge::Lexers::Batchfile)
    Rouge::RegexLexer.find("cmd").should be_a(Rouge::Lexers::Batchfile)
  end

  it "tokenizes commands and variables" do
    lexer = Rouge::Lexers::Batchfile.new
    tokens = lexer.lex("REM comment\nset VAR=hello\necho %VAR%")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameVariable && val == "%VAR%" }.should be_true
  end
end

describe Rouge::Lexers::BibTeX do
  it "is registered as bibtex and bib" do
    Rouge::RegexLexer.find("bibtex").should be_a(Rouge::Lexers::BibTeX)
    Rouge::RegexLexer.find("bib").should be_a(Rouge::Lexers::BibTeX)
  end

  it "tokenizes entry types and fields" do
    lexer = Rouge::Lexers::BibTeX.new
    tokens = lexer.lex("@article{key,\n  author = {Doe},\n  year = 2024\n}")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val =~ /@article/i }.should be_true
  end
end

describe Rouge::Lexers::Brainfuck do
  it "is registered as brainfuck and bf" do
    Rouge::RegexLexer.find("brainfuck").should be_a(Rouge::Lexers::Brainfuck)
    Rouge::RegexLexer.find("bf").should be_a(Rouge::Lexers::Brainfuck)
  end

  it "tokenizes commands and comments" do
    lexer = Rouge::Lexers::Brainfuck.new
    tokens = lexer.lex("++[>+<-]>. hello")
    tokens.any? { |tok, _| tok == Rouge::Tokens::Operator }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::Punctuation }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end
end

describe Rouge::Lexers::Clojure do
  it "is registered as clojure and clj" do
    Rouge::RegexLexer.find("clojure").should be_a(Rouge::Lexers::Clojure)
    Rouge::RegexLexer.find("clj").should be_a(Rouge::Lexers::Clojure)
  end

  it "tokenizes keywords, symbols and comments" do
    lexer = Rouge::Lexers::Clojure.new
    tokens = lexer.lex("; comment\n(defn hello [name]\n  (println :greeting name))")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "defn" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::StrSymbol && val == ":greeting" }.should be_true
  end
end

describe Rouge::Lexers::CMake do
  it "is registered as cmake" do
    Rouge::RegexLexer.find("cmake").should be_a(Rouge::Lexers::CMake)
  end

  it "tokenizes commands, variables and comments" do
    lexer = Rouge::Lexers::CMake.new
    tokens = lexer.lex("# comment\ncmake_minimum_required(VERSION 3.10)\nproject(MyApp)\nset(SRC ${CMAKE_SOURCE_DIR}/main.cpp)")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val =~ /project/i }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameVariable }.should be_true
  end
end

describe Rouge::Lexers::CoffeeScript do
  it "is registered as coffeescript and coffee" do
    Rouge::RegexLexer.find("coffeescript").should be_a(Rouge::Lexers::CoffeeScript)
    Rouge::RegexLexer.find("coffee").should be_a(Rouge::Lexers::CoffeeScript)
  end

  it "tokenizes keywords, arrows and comments" do
    lexer = Rouge::Lexers::CoffeeScript.new
    tokens = lexer.lex("# comment\nsquare = (x) -> x * x\nif true then console.log 42")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Operator && val == "->" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "if" }.should be_true
  end
end

describe Rouge::Lexers::Coq do
  it "is registered as coq" do
    Rouge::RegexLexer.find("coq").should be_a(Rouge::Lexers::Coq)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::Coq.new
    tokens = lexer.lex("(* comment *)\nDefinition x := 42.\nTheorem foo : True.\nProof. trivial. Qed.")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentMultiline }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "Definition" }.should be_true
  end
end

describe Rouge::Lexers::Cpp do
  it "is registered as cpp and c++" do
    Rouge::RegexLexer.find("cpp").should be_a(Rouge::Lexers::Cpp)
    Rouge::RegexLexer.find("c++").should be_a(Rouge::Lexers::Cpp)
  end

  it "tokenizes keywords, types, strings and comments" do
    lexer = Rouge::Lexers::Cpp.new
    tokens = lexer.lex("// comment\n#include <iostream>\nclass Foo {\npublic:\n  virtual void bar() const;\n};")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "class" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "virtual" }.should be_true
  end
end

describe Rouge::Lexers::CSharp do
  it "is registered as csharp, cs, and c#" do
    Rouge::RegexLexer.find("csharp").should be_a(Rouge::Lexers::CSharp)
    Rouge::RegexLexer.find("cs").should be_a(Rouge::Lexers::CSharp)
    Rouge::RegexLexer.find("c#").should be_a(Rouge::Lexers::CSharp)
  end

  it "tokenizes keywords, types and comments" do
    lexer = Rouge::Lexers::CSharp.new
    tokens = lexer.lex("// comment\nusing System;\nnamespace App {\n  class Program {\n    static void Main() {\n      Console.WriteLine(42);\n    }\n  }\n}")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "namespace" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "void" }.should be_true
  end
end

describe Rouge::Lexers::CUDA do
  it "is registered as cuda and cu" do
    Rouge::RegexLexer.find("cuda").should be_a(Rouge::Lexers::CUDA)
    Rouge::RegexLexer.find("cu").should be_a(Rouge::Lexers::CUDA)
  end

  it "tokenizes CUDA keywords and builtins" do
    lexer = Rouge::Lexers::CUDA.new
    tokens = lexer.lex("__global__ void kernel() {\n  int idx = threadIdx.x;\n  cudaDeviceSynchronize();\n}")
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordReserved && val == "__global__" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameBuiltin && val == "cudaDeviceSynchronize" }.should be_true
  end
end

describe Rouge::Lexers::DLang do
  it "is registered as d and dlang" do
    Rouge::RegexLexer.find("d").should be_a(Rouge::Lexers::DLang)
    Rouge::RegexLexer.find("dlang").should be_a(Rouge::Lexers::DLang)
  end

  it "tokenizes keywords, types and comments" do
    lexer = Rouge::Lexers::DLang.new
    tokens = lexer.lex("// comment\nimport std.stdio;\nvoid main() {\n  int x = 42;\n  writeln(x);\n}")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "import" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "void" }.should be_true
  end
end

describe Rouge::Lexers::Erlang do
  it "is registered as erlang and erl" do
    Rouge::RegexLexer.find("erlang").should be_a(Rouge::Lexers::Erlang)
    Rouge::RegexLexer.find("erl").should be_a(Rouge::Lexers::Erlang)
  end

  it "tokenizes keywords, variables and comments" do
    lexer = Rouge::Lexers::Erlang.new
    tokens = lexer.lex("% comment\nhello(Name) ->\n  case Name of\n    \"world\" -> ok\n  end.")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "case" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameVariable && val == "Name" }.should be_true
  end
end

describe Rouge::Lexers::Fortran do
  it "is registered as fortran, f90, and f95" do
    Rouge::RegexLexer.find("fortran").should be_a(Rouge::Lexers::Fortran)
    Rouge::RegexLexer.find("f90").should be_a(Rouge::Lexers::Fortran)
    Rouge::RegexLexer.find("f95").should be_a(Rouge::Lexers::Fortran)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::Fortran.new
    tokens = lexer.lex("! comment\nprogram hello\n  implicit none\n  integer :: x\n  x = 42\n  print *, x\nend program hello")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val =~ /program/i }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true
  end
end

describe Rouge::Lexers::FSharp do
  it "is registered as fsharp and fs" do
    Rouge::RegexLexer.find("fsharp").should be_a(Rouge::Lexers::FSharp)
    Rouge::RegexLexer.find("fs").should be_a(Rouge::Lexers::FSharp)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::FSharp.new
    tokens = lexer.lex("// comment\nlet x = 42\nlet add a b = a + b\nmodule MyModule =\n  let y = \"hello\"")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "let" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true
  end
end

describe Rouge::Lexers::GDScript do
  it "is registered as gdscript and gd" do
    Rouge::RegexLexer.find("gdscript").should be_a(Rouge::Lexers::GDScript)
    Rouge::RegexLexer.find("gd").should be_a(Rouge::Lexers::GDScript)
  end

  it "tokenizes keywords, annotations and comments" do
    lexer = Rouge::Lexers::GDScript.new
    tokens = lexer.lex("# comment\nextends Node\n@export var speed = 10.0\nfunc _ready():\n  pass")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "extends" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameDecorator && val == "@export" }.should be_true
  end
end

describe Rouge::Lexers::GLSL do
  it "is registered as glsl" do
    Rouge::RegexLexer.find("glsl").should be_a(Rouge::Lexers::GLSL)
  end

  it "tokenizes keywords, types and comments" do
    lexer = Rouge::Lexers::GLSL.new
    tokens = lexer.lex("// comment\nuniform mat4 mvp;\nvoid main() {\n  vec4 pos = vec4(1.0);\n}")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "uniform" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "mat4" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "vec4" }.should be_true
  end
end

describe Rouge::Lexers::Groovy do
  it "is registered as groovy" do
    Rouge::RegexLexer.find("groovy").should be_a(Rouge::Lexers::Groovy)
  end

  it "tokenizes keywords, strings and comments" do
    lexer = Rouge::Lexers::Groovy.new
    tokens = lexer.lex("// comment\ndef greet(name) {\n  println \"Hello\"\n}\nclass Foo extends Bar {}")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "def" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "class" }.should be_true
  end
end

describe Rouge::Lexers::Handlebars do
  it "is registered as handlebars and hbs" do
    Rouge::RegexLexer.find("handlebars").should be_a(Rouge::Lexers::Handlebars)
    Rouge::RegexLexer.find("hbs").should be_a(Rouge::Lexers::Handlebars)
  end

  it "tokenizes expressions and comments" do
    lexer = Rouge::Lexers::Handlebars.new
    tokens = lexer.lex("{{! comment }}\n<div>{{name}}</div>\n{{#if active}}<p>yes</p>{{/if}}")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::Punctuation }.should be_true
  end
end

describe Rouge::Lexers::Haxe do
  it "is registered as haxe and hx" do
    Rouge::RegexLexer.find("haxe").should be_a(Rouge::Lexers::Haxe)
    Rouge::RegexLexer.find("hx").should be_a(Rouge::Lexers::Haxe)
  end

  it "tokenizes keywords, types and comments" do
    lexer = Rouge::Lexers::Haxe.new
    tokens = lexer.lex("// comment\nclass Main {\n  static function main():Void {\n    var x:Int = 42;\n  }\n}")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "class" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true
  end
end

describe Rouge::Lexers::HTTP do
  it "is registered as http" do
    Rouge::RegexLexer.find("http").should be_a(Rouge::Lexers::HTTP)
  end

  it "tokenizes request lines and headers" do
    lexer = Rouge::Lexers::HTTP.new
    tokens = lexer.lex("GET /api/users HTTP/1.1\nHost: example.com\nContent-Type: application/json")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "GET" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameAttribute && val == "Host" }.should be_true
  end
end

describe Rouge::Lexers::Jinja do
  it "is registered as jinja and jinja2" do
    Rouge::RegexLexer.find("jinja").should be_a(Rouge::Lexers::Jinja)
    Rouge::RegexLexer.find("jinja2").should be_a(Rouge::Lexers::Jinja)
  end

  it "tokenizes tags and comments" do
    lexer = Rouge::Lexers::Jinja.new
    tokens = lexer.lex("{# comment #}\n{{ name }}\n{% if active %}yes{% endif %}")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentMultiline }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::Punctuation }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "if" }.should be_true
  end
end

describe Rouge::Lexers::Jsonnet do
  it "is registered as jsonnet" do
    Rouge::RegexLexer.find("jsonnet").should be_a(Rouge::Lexers::Jsonnet)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::Jsonnet.new
    tokens = lexer.lex("// comment\nlocal x = 42;\n{\n  name: \"hello\",\n  active: true,\n}")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "local" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordConstant && val == "true" }.should be_true
  end
end

describe Rouge::Lexers::Julia do
  it "is registered as julia and jl" do
    Rouge::RegexLexer.find("julia").should be_a(Rouge::Lexers::Julia)
    Rouge::RegexLexer.find("jl").should be_a(Rouge::Lexers::Julia)
  end

  it "tokenizes keywords, types, macros and comments" do
    lexer = Rouge::Lexers::Julia.new
    tokens = lexer.lex("# comment\nfunction hello(x::Int)\n  @show x\n  return x + 1\nend")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "function" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "return" }.should be_true
  end
end

describe Rouge::Lexers::Lasso do
  it "is registered as lasso" do
    Rouge::RegexLexer.find("lasso").should be_a(Rouge::Lexers::Lasso)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::Lasso.new
    tokens = lexer.lex("// comment\ndefine mytype => type {\n  local x = 42\n  if(true)\n    return x\n}")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "define" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordConstant && val == "true" }.should be_true
  end
end

describe Rouge::Lexers::Liquid do
  it "is registered as liquid" do
    Rouge::RegexLexer.find("liquid").should be_a(Rouge::Lexers::Liquid)
  end

  it "tokenizes tags and output" do
    lexer = Rouge::Lexers::Liquid.new
    tokens = lexer.lex("{{ product.title }}\n{% if product.available %}In stock{% endif %}")
    tokens.any? { |tok, _| tok == Rouge::Tokens::Punctuation }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "if" }.should be_true
  end
end

describe Rouge::Lexers::Nim do
  it "is registered as nim and nimrod" do
    Rouge::RegexLexer.find("nim").should be_a(Rouge::Lexers::Nim)
    Rouge::RegexLexer.find("nimrod").should be_a(Rouge::Lexers::Nim)
  end

  it "tokenizes keywords, types and comments" do
    lexer = Rouge::Lexers::Nim.new
    tokens = lexer.lex("# comment\nproc hello(name: string): int =\n  var x = 42\n  return x")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "proc" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "string" }.should be_true
  end
end

describe Rouge::Lexers::Nix do
  it "is registered as nix" do
    Rouge::RegexLexer.find("nix").should be_a(Rouge::Lexers::Nix)
  end

  it "tokenizes keywords, strings and comments" do
    lexer = Rouge::Lexers::Nix.new
    tokens = lexer.lex("# comment\nlet x = 42;\nin { inherit x; }")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "let" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "inherit" }.should be_true
  end
end

describe Rouge::Lexers::OCaml do
  it "is registered as ocaml and ml" do
    Rouge::RegexLexer.find("ocaml").should be_a(Rouge::Lexers::OCaml)
    Rouge::RegexLexer.find("ml").should be_a(Rouge::Lexers::OCaml)
  end

  it "tokenizes keywords, types and comments" do
    lexer = Rouge::Lexers::OCaml.new
    tokens = lexer.lex("(* comment *)\nlet x : int = 42\nlet add a b = a + b\nmodule M = struct end")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentMultiline }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "let" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "int" }.should be_true
  end
end

describe Rouge::Lexers::Pascal do
  it "is registered as pascal, delphi, and objectpascal" do
    Rouge::RegexLexer.find("pascal").should be_a(Rouge::Lexers::Pascal)
    Rouge::RegexLexer.find("delphi").should be_a(Rouge::Lexers::Pascal)
    Rouge::RegexLexer.find("objectpascal").should be_a(Rouge::Lexers::Pascal)
  end

  it "tokenizes keywords, strings and comments" do
    lexer = Rouge::Lexers::Pascal.new
    tokens = lexer.lex("// comment\nprogram Hello;\nvar x: Integer;\nbegin\n  x := 42;\n  WriteLn('Hello');\nend.")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val =~ /program/i }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true
  end
end
