require "./spec_helper"

describe Rouge::Lexers::PlainText do
  it "is registered as plaintext, text, and plain" do
    Rouge::RegexLexer.find("plaintext").should be_a(Rouge::Lexers::PlainText)
    Rouge::RegexLexer.find("text").should be_a(Rouge::Lexers::PlainText)
    Rouge::RegexLexer.find("plain").should be_a(Rouge::Lexers::PlainText)
  end

  it "emits everything as Text" do
    lexer = Rouge::Lexers::PlainText.new
    tokens = lexer.lex("Hello world 123")
    tokens.all? { |tok, _| tok == Rouge::Tokens::Text }.should be_true
  end
end

describe Rouge::Lexers::Console do
  it "is registered as console and terminal" do
    Rouge::RegexLexer.find("console").should be_a(Rouge::Lexers::Console)
    Rouge::RegexLexer.find("terminal").should be_a(Rouge::Lexers::Console)
  end

  it "tokenizes prompt lines and output" do
    lexer = Rouge::Lexers::Console.new
    tokens = lexer.lex("$ ls -la\noutput here")
    tokens.any? { |tok, _| tok == Rouge::Tokens::GenericPrompt }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::GenericOutput }.should be_true
  end
end

describe Rouge::Lexers::Properties do
  it "is registered as java-properties" do
    Rouge::RegexLexer.find("java-properties").should be_a(Rouge::Lexers::Properties)
  end

  it "tokenizes key=value pairs and comments" do
    lexer = Rouge::Lexers::Properties.new
    tokens = lexer.lex("# comment\nkey=value")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameProperty }.should be_true
  end
end

describe Rouge::Lexers::Puppet do
  it "is registered as puppet and pp" do
    Rouge::RegexLexer.find("puppet").should be_a(Rouge::Lexers::Puppet)
    Rouge::RegexLexer.find("pp").should be_a(Rouge::Lexers::Puppet)
  end

  it "tokenizes keywords, variables, and strings" do
    lexer = Rouge::Lexers::Puppet.new
    tokens = lexer.lex("class myclass { $var = 'hello' }")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "class" }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameVariable }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrSingle }.should be_true
  end
end

describe Rouge::Lexers::Sed do
  it "is registered as sed" do
    Rouge::RegexLexer.find("sed").should be_a(Rouge::Lexers::Sed)
  end

  it "tokenizes comments and commands" do
    lexer = Rouge::Lexers::Sed.new
    tokens = lexer.lex("# comment\nd")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "d" }.should be_true
  end
end

describe Rouge::Lexers::Slim do
  it "is registered as slim" do
    Rouge::RegexLexer.find("slim").should be_a(Rouge::Lexers::Slim)
  end

  it "tokenizes tags and strings" do
    lexer = Rouge::Lexers::Slim.new
    tokens = lexer.lex("div\n  p \"hello\"")
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
    tokens.size.should be > 0
  end
end

describe Rouge::Lexers::Smarty do
  it "is registered as smarty" do
    Rouge::RegexLexer.find("smarty").should be_a(Rouge::Lexers::Smarty)
  end

  it "tokenizes smarty tags and variables" do
    lexer = Rouge::Lexers::Smarty.new
    tokens = lexer.lex("{if $name}hello{/if}")
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameVariable }.should be_true
  end
end

describe Rouge::Lexers::SPARQL do
  it "is registered as sparql" do
    Rouge::RegexLexer.find("sparql").should be_a(Rouge::Lexers::SPARQL)
  end

  it "tokenizes keywords and variables" do
    lexer = Rouge::Lexers::SPARQL.new
    tokens = lexer.lex("SELECT ?name WHERE { ?s ?p ?o }")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "SELECT" }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameVariable }.should be_true
  end
end

describe Rouge::Lexers::Stata do
  it "is registered as stata" do
    Rouge::RegexLexer.find("stata").should be_a(Rouge::Lexers::Stata)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::Stata.new
    tokens = lexer.lex("// comment\nregress y x")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "regress" }.should be_true
  end
end

describe Rouge::Lexers::Tcl do
  it "is registered as tcl" do
    Rouge::RegexLexer.find("tcl").should be_a(Rouge::Lexers::Tcl)
  end

  it "tokenizes keywords and variables" do
    lexer = Rouge::Lexers::Tcl.new
    tokens = lexer.lex("set x 10\nputs $x")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "set" }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameVariable }.should be_true
  end
end

describe Rouge::Lexers::TeX do
  it "is registered as tex and latex" do
    Rouge::RegexLexer.find("tex").should be_a(Rouge::Lexers::TeX)
    Rouge::RegexLexer.find("latex").should be_a(Rouge::Lexers::TeX)
  end

  it "tokenizes commands and comments" do
    lexer = Rouge::Lexers::TeX.new
    tokens = lexer.lex("% comment\n\\textbf{hello}")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
  end
end

describe Rouge::Lexers::VB do
  it "is registered as vb, vbnet, and visualbasic" do
    Rouge::RegexLexer.find("vb").should be_a(Rouge::Lexers::VB)
    Rouge::RegexLexer.find("vbnet").should be_a(Rouge::Lexers::VB)
    Rouge::RegexLexer.find("visualbasic").should be_a(Rouge::Lexers::VB)
  end

  it "tokenizes keywords and strings (case insensitive)" do
    lexer = Rouge::Lexers::VB.new
    tokens = lexer.lex("Dim x As Integer = 5\n' comment")
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end
end

describe Rouge::Lexers::Verilog do
  it "is registered as verilog and v" do
    Rouge::RegexLexer.find("verilog").should be_a(Rouge::Lexers::Verilog)
    Rouge::RegexLexer.find("v").should be_a(Rouge::Lexers::Verilog)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::Verilog.new
    tokens = lexer.lex("module test; // comment\nendmodule")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "module" }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end
end

describe Rouge::Lexers::VHDL do
  it "is registered as vhdl" do
    Rouge::RegexLexer.find("vhdl").should be_a(Rouge::Lexers::VHDL)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::VHDL.new
    tokens = lexer.lex("-- comment\nentity test is\nend entity;")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
  end
end

describe Rouge::Lexers::VimL do
  it "is registered as viml, vim, and vimscript" do
    Rouge::RegexLexer.find("viml").should be_a(Rouge::Lexers::VimL)
    Rouge::RegexLexer.find("vim").should be_a(Rouge::Lexers::VimL)
    Rouge::RegexLexer.find("vimscript").should be_a(Rouge::Lexers::VimL)
  end

  it "tokenizes keywords and strings" do
    lexer = Rouge::Lexers::VimL.new
    tokens = lexer.lex("let x = 'hello'\nif x\nendif")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "let" }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrSingle }.should be_true
  end
end

describe Rouge::Lexers::Vue do
  it "is registered as vue" do
    Rouge::RegexLexer.find("vue").should be_a(Rouge::Lexers::Vue)
  end

  it "tokenizes template tags" do
    lexer = Rouge::Lexers::Vue.new
    tokens = lexer.lex("<template>\n  <div>hello</div>\n</template>")
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameTag }.should be_true
  end
end

describe Rouge::Lexers::ObjectiveC do
  it "is registered as objective_c, objc, and objectivec" do
    Rouge::RegexLexer.find("objective_c").should be_a(Rouge::Lexers::ObjectiveC)
    Rouge::RegexLexer.find("objc").should be_a(Rouge::Lexers::ObjectiveC)
    Rouge::RegexLexer.find("objectivec").should be_a(Rouge::Lexers::ObjectiveC)
  end

  it "tokenizes keywords and ObjC strings" do
    lexer = Rouge::Lexers::ObjectiveC.new
    tokens = lexer.lex("@interface Foo\n@end")
    tokens.any? { |tok, _| tok == Rouge::Tokens::KeywordDeclaration }.should be_true
  end
end

describe Rouge::Lexers::Elm do
  it "is registered as elm" do
    Rouge::RegexLexer.find("elm").should be_a(Rouge::Lexers::Elm)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::Elm.new
    tokens = lexer.lex("-- comment\nmodule Main exposing (..)")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "module" }.should be_true
  end
end

describe Rouge::Lexers::ERB do
  it "is registered as erb and rhtml" do
    Rouge::RegexLexer.find("erb").should be_a(Rouge::Lexers::ERB)
    Rouge::RegexLexer.find("rhtml").should be_a(Rouge::Lexers::ERB)
  end

  it "tokenizes ERB tags" do
    lexer = Rouge::Lexers::ERB.new
    tokens = lexer.lex("<%= expr %>")
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrInterpol }.should be_true
  end
end

describe Rouge::Lexers::Scheme do
  it "is registered as scheme and scm" do
    Rouge::RegexLexer.find("scheme").should be_a(Rouge::Lexers::Scheme)
    Rouge::RegexLexer.find("scm").should be_a(Rouge::Lexers::Scheme)
  end

  it "tokenizes keywords and constants" do
    lexer = Rouge::Lexers::Scheme.new
    tokens = lexer.lex("(define x #t)")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "define" }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::KeywordConstant }.should be_true
  end
end

describe Rouge::Lexers::Svelte do
  it "is registered as svelte" do
    Rouge::RegexLexer.find("svelte").should be_a(Rouge::Lexers::Svelte)
  end

  it "tokenizes svelte blocks and tags" do
    lexer = Rouge::Lexers::Svelte.new
    tokens = lexer.lex("{#if condition}<div>hello</div>{/if}")
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameTag }.should be_true
  end
end

describe Rouge::Lexers::JSON5 do
  it "is registered as json5" do
    Rouge::RegexLexer.find("json5").should be_a(Rouge::Lexers::JSON5)
  end

  it "tokenizes comments and unquoted keys" do
    lexer = Rouge::Lexers::JSON5.new
    tokens = lexer.lex("// comment\n{key: 'value'}")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrSingle }.should be_true
  end
end

describe Rouge::Lexers::Wollok do
  it "is registered as wollok" do
    Rouge::RegexLexer.find("wollok").should be_a(Rouge::Lexers::Wollok)
  end

  it "tokenizes keywords and strings" do
    lexer = Rouge::Lexers::Wollok.new
    tokens = lexer.lex("class Bird {\n  method fly() { return \"high\" }\n}")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "class" }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
  end
end

describe Rouge::Lexers::Dot do
  it "is registered as dot and graphviz" do
    Rouge::RegexLexer.find("dot").should be_a(Rouge::Lexers::Dot)
    Rouge::RegexLexer.find("graphviz").should be_a(Rouge::Lexers::Dot)
  end

  it "tokenizes keywords and arrows" do
    lexer = Rouge::Lexers::Dot.new
    tokens = lexer.lex("digraph G { a -> b }")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "digraph" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Operator && val == "->" }.should be_true
  end
end

describe Rouge::Lexers::Eiffel do
  it "is registered as eiffel and e" do
    Rouge::RegexLexer.find("eiffel").should be_a(Rouge::Lexers::Eiffel)
    Rouge::RegexLexer.find("e").should be_a(Rouge::Lexers::Eiffel)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::Eiffel.new
    tokens = lexer.lex("-- comment\nclass FOO\nend")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
  end
end

describe Rouge::Lexers::Prolog do
  it "is registered as prolog" do
    Rouge::RegexLexer.find("prolog").should be_a(Rouge::Lexers::Prolog)
  end

  it "tokenizes variables and comments" do
    lexer = Rouge::Lexers::Prolog.new
    tokens = lexer.lex("% comment\nparent(X, Y) :- father(X, Y).")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameVariable }.should be_true
  end
end

describe Rouge::Lexers::SML do
  it "is registered as sml and standard-ml" do
    Rouge::RegexLexer.find("sml").should be_a(Rouge::Lexers::SML)
    Rouge::RegexLexer.find("standard-ml").should be_a(Rouge::Lexers::SML)
  end

  it "tokenizes keywords and strings" do
    lexer = Rouge::Lexers::SML.new
    tokens = lexer.lex("val x = \"hello\"")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "val" }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
  end
end

describe Rouge::Lexers::Racket do
  it "is registered as racket and rkt" do
    Rouge::RegexLexer.find("racket").should be_a(Rouge::Lexers::Racket)
    Rouge::RegexLexer.find("rkt").should be_a(Rouge::Lexers::Racket)
  end

  it "tokenizes keywords and constants" do
    lexer = Rouge::Lexers::Racket.new
    tokens = lexer.lex("(define x #true)")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "define" }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::KeywordConstant }.should be_true
  end
end

describe Rouge::Lexers::Matlab do
  it "is registered as matlab and octave" do
    Rouge::RegexLexer.find("matlab").should be_a(Rouge::Lexers::Matlab)
    Rouge::RegexLexer.find("octave").should be_a(Rouge::Lexers::Matlab)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::Matlab.new
    tokens = lexer.lex("% comment\nfor i = 1:10\nend")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "for" }.should be_true
  end
end

describe Rouge::Lexers::JSX do
  it "is registered as jsx" do
    Rouge::RegexLexer.find("jsx").should be_a(Rouge::Lexers::JSX)
  end

  it "tokenizes JSX tags and keywords" do
    lexer = Rouge::Lexers::JSX.new
    tokens = lexer.lex("const x = <div>hello</div>")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "const" }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameTag }.should be_true
  end
end

describe Rouge::Lexers::TSX do
  it "is registered as tsx" do
    Rouge::RegexLexer.find("tsx").should be_a(Rouge::Lexers::TSX)
  end

  it "tokenizes TSX tags and type keywords" do
    lexer = Rouge::Lexers::TSX.new
    tokens = lexer.lex("const x: string = <div>hello</div>")
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameTag }.should be_true
  end
end

describe Rouge::Lexers::AppleScript do
  it "is registered as applescript" do
    Rouge::RegexLexer.find("applescript").should be_a(Rouge::Lexers::AppleScript)
  end

  it "tokenizes keywords and comments" do
    lexer = Rouge::Lexers::AppleScript.new
    tokens = lexer.lex("-- comment\ntell application \"Finder\"\nend tell")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
  end
end

describe Rouge::Lexers::Mojo do
  it "is registered as mojo" do
    Rouge::RegexLexer.find("mojo").should be_a(Rouge::Lexers::Mojo)
  end

  it "tokenizes keywords and strings" do
    lexer = Rouge::Lexers::Mojo.new
    tokens = lexer.lex("fn main():\n  var x = \"hello\"")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "fn" }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
  end
end
