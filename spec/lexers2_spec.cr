require "./spec_helper"

describe Rouge::Lexers::Go do
  it "is registered as go and golang" do
    lexer = Rouge::RegexLexer.find("go")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::Go)

    lexer2 = Rouge::RegexLexer.find("golang")
    lexer2.should_not be_nil
    lexer2.should be_a(Rouge::Lexers::Go)
  end

  it "tokenizes keywords" do
    lexer = Rouge::Lexers::Go.new
    tokens = lexer.lex("func main() { return }")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "func" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "return" }.should be_true
  end

  it "tokenizes types" do
    lexer = Rouge::Lexers::Go.new
    tokens = lexer.lex("int string bool float64")
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "int" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "string" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "bool" }.should be_true
  end

  it "tokenizes constants" do
    lexer = Rouge::Lexers::Go.new
    tokens = lexer.lex("true false nil iota")
    consts = tokens.select { |tok, _| tok == Rouge::Tokens::KeywordConstant }
    consts.size.should eq(4)
  end

  it "tokenizes builtins" do
    lexer = Rouge::Lexers::Go.new
    tokens = lexer.lex("make([]int, 10)")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameBuiltin && val == "make" }.should be_true
  end

  it "tokenizes strings" do
    lexer = Rouge::Lexers::Go.new
    tokens = lexer.lex(%("hello world"))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true

    tokens = lexer.lex("`raw string`")
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrBacktick }.should be_true
  end

  it "tokenizes numbers" do
    lexer = Rouge::Lexers::Go.new
    tokens = lexer.lex("42 3.14 0xFF 0b1010")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumFloat && val == "3.14" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumHex && val == "0xFF" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumBin && val == "0b1010" }.should be_true
  end

  it "tokenizes comments" do
    lexer = Rouge::Lexers::Go.new
    tokens = lexer.lex("// single line")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true

    tokens = lexer.lex("/* multi\nline */")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentMultiline }.should be_true
  end

  it "tokenizes a complete Go snippet" do
    go_code = <<-GO
    package main

    import "fmt"

    func main() {
        x := 42
        if x > 0 {
            fmt.Println("positive")
        }
    }
    GO

    lexer = Rouge::Lexers::Go.new
    tokens = lexer.lex(go_code)
    tokens.size.should be > 10
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NumInteger }.should be_true
  end
end

describe Rouge::Lexers::Ruby do
  it "is registered as ruby and rb" do
    lexer = Rouge::RegexLexer.find("ruby")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::Ruby)

    lexer2 = Rouge::RegexLexer.find("rb")
    lexer2.should_not be_nil
    lexer2.should be_a(Rouge::Lexers::Ruby)
  end

  it "tokenizes keywords" do
    lexer = Rouge::Lexers::Ruby.new
    tokens = lexer.lex("def foo; end")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "def" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "end" }.should be_true
  end

  it "tokenizes constants" do
    lexer = Rouge::Lexers::Ruby.new
    tokens = lexer.lex("true false nil")
    consts = tokens.select { |tok, _| tok == Rouge::Tokens::KeywordConstant }
    consts.size.should eq(3)
  end

  it "tokenizes builtins" do
    lexer = Rouge::Lexers::Ruby.new
    tokens = lexer.lex("puts 'hello'")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameBuiltin && val == "puts" }.should be_true
  end

  it "tokenizes strings with interpolation" do
    lexer = Rouge::Lexers::Ruby.new
    tokens = lexer.lex(%("hello \#{name}"))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrInterpol }.should be_true
  end

  it "tokenizes single-quoted strings" do
    lexer = Rouge::Lexers::Ruby.new
    tokens = lexer.lex("'hello'")
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrSingle }.should be_true
  end

  it "tokenizes symbols" do
    lexer = Rouge::Lexers::Ruby.new
    tokens = lexer.lex(":hello")
    tokens.any? { |tok, val| tok == Rouge::Tokens::StrSymbol && val == ":hello" }.should be_true
  end

  it "tokenizes numbers" do
    lexer = Rouge::Lexers::Ruby.new
    tokens = lexer.lex("42 3.14 0xFF 0b1010")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumFloat && val == "3.14" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumHex && val == "0xFF" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumBin && val == "0b1010" }.should be_true
  end

  it "tokenizes comments" do
    lexer = Rouge::Lexers::Ruby.new
    tokens = lexer.lex("# a comment")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end

  it "tokenizes instance variables" do
    lexer = Rouge::Lexers::Ruby.new
    tokens = lexer.lex("@name @@count")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameVariableInstance && val == "@name" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameVariableClass && val == "@@count" }.should be_true
  end

  it "tokenizes global variables" do
    lexer = Rouge::Lexers::Ruby.new
    tokens = lexer.lex("$stdout")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameVariableGlobal && val == "$stdout" }.should be_true
  end

  it "tokenizes a complete Ruby snippet" do
    ruby_code = <<-RUBY
    class Greeter
      def initialize(name)
        @name = name
      end

      def greet
        puts "Hello, \#{@name}!"
      end
    end
    RUBY

    lexer = Rouge::Lexers::Ruby.new
    tokens = lexer.lex(ruby_code)
    tokens.size.should be > 10
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameVariableInstance }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
  end
end

describe Rouge::Lexers::YAML do
  it "is registered as yaml and yml" do
    lexer = Rouge::RegexLexer.find("yaml")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::YAML)

    lexer2 = Rouge::RegexLexer.find("yml")
    lexer2.should_not be_nil
    lexer2.should be_a(Rouge::Lexers::YAML)
  end

  it "tokenizes keys" do
    lexer = Rouge::Lexers::YAML.new
    tokens = lexer.lex("name: John")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameLabel && val == "name" }.should be_true
  end

  it "tokenizes strings" do
    lexer = Rouge::Lexers::YAML.new
    tokens = lexer.lex(%("hello world"))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true

    tokens = lexer.lex("'hello world'")
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrSingle }.should be_true
  end

  it "tokenizes numbers" do
    lexer = Rouge::Lexers::YAML.new
    tokens = lexer.lex("42")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true

    tokens = lexer.lex("3.14")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumFloat && val == "3.14" }.should be_true
  end

  it "tokenizes booleans and null" do
    lexer = Rouge::Lexers::YAML.new
    tokens = lexer.lex("true false null")
    consts = tokens.select { |tok, _| tok == Rouge::Tokens::KeywordConstant }
    consts.size.should eq(3)
  end

  it "tokenizes comments" do
    lexer = Rouge::Lexers::YAML.new
    tokens = lexer.lex("# a comment")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end

  it "tokenizes document markers" do
    lexer = Rouge::Lexers::YAML.new
    tokens = lexer.lex("---\n...")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameNamespace }.should be_true
  end

  it "tokenizes anchors and aliases" do
    lexer = Rouge::Lexers::YAML.new
    tokens = lexer.lex("&anchor_name")
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameLabel }.should be_true

    tokens = lexer.lex("*alias_name")
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameVariable }.should be_true
  end

  it "tokenizes tags" do
    lexer = Rouge::Lexers::YAML.new
    tokens = lexer.lex("!!str")
    tokens.any? { |tok, _| tok == Rouge::Tokens::KeywordType }.should be_true
  end

  it "tokenizes a complete YAML snippet" do
    yaml_code = <<-YAML
    ---
    name: Crystal Rouge
    version: 0.1.0
    authors:
      - John Doe
    dependencies:
      crystal: ">=1.0"
    enabled: true
    count: 42
    YAML

    lexer = Rouge::Lexers::YAML.new
    tokens = lexer.lex(yaml_code)
    tokens.size.should be > 10
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameLabel }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::KeywordConstant }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NumInteger }.should be_true
  end
end

describe Rouge::Lexers::C do
  it "is registered as c" do
    lexer = Rouge::RegexLexer.find("c")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::C)
  end

  it "tokenizes keywords" do
    lexer = Rouge::Lexers::C.new
    tokens = lexer.lex("if (x) return 0;")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "if" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "return" }.should be_true
  end

  it "tokenizes types" do
    lexer = Rouge::Lexers::C.new
    tokens = lexer.lex("int x; char c; float f;")
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "int" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "char" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "float" }.should be_true
  end

  it "tokenizes preprocessor directives" do
    lexer = Rouge::Lexers::C.new
    tokens = lexer.lex("#include <stdio.h>")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentPreproc }.should be_true

    tokens = lexer.lex("#define MAX 100")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentPreproc }.should be_true
  end

  it "tokenizes strings" do
    lexer = Rouge::Lexers::C.new
    tokens = lexer.lex(%("hello world"))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
  end

  it "tokenizes characters" do
    lexer = Rouge::Lexers::C.new
    tokens = lexer.lex("'a'")
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrChar }.should be_true
  end

  it "tokenizes numbers" do
    lexer = Rouge::Lexers::C.new
    tokens = lexer.lex("42 3.14 0xFF")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumFloat && val == "3.14" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumHex && val == "0xFF" }.should be_true
  end

  it "tokenizes comments" do
    lexer = Rouge::Lexers::C.new
    tokens = lexer.lex("// single line")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true

    tokens = lexer.lex("/* multi line */")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentMultiline }.should be_true
  end

  it "tokenizes NULL constant" do
    lexer = Rouge::Lexers::C.new
    tokens = lexer.lex("NULL")
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordConstant && val == "NULL" }.should be_true
  end

  it "tokenizes a complete C snippet" do
    c_code = <<-CCODE
    #include <stdio.h>

    int main() {
        int x = 42;
        if (x > 0) {
            printf("positive: %d\\n", x);
        }
        return 0;
    }
    CCODE

    lexer = Rouge::Lexers::C.new
    tokens = lexer.lex(c_code)
    tokens.size.should be > 10
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentPreproc }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::KeywordType }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NumInteger }.should be_true
  end
end

describe Rouge::Lexers::TypeScript do
  it "is registered as typescript and ts" do
    lexer = Rouge::RegexLexer.find("typescript")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::TypeScript)

    lexer2 = Rouge::RegexLexer.find("ts")
    lexer2.should_not be_nil
    lexer2.should be_a(Rouge::Lexers::TypeScript)
  end

  it "tokenizes JS keywords" do
    lexer = Rouge::Lexers::TypeScript.new
    tokens = lexer.lex("const x = 1;")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "const" }.should be_true
  end

  it "tokenizes TS-specific keywords" do
    lexer = Rouge::Lexers::TypeScript.new
    tokens = lexer.lex("interface Foo { readonly x: number }")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "interface" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "readonly" }.should be_true
  end

  it "tokenizes type keywords" do
    lexer = Rouge::Lexers::TypeScript.new
    tokens = lexer.lex("number string boolean any never unknown")
    type_tokens = tokens.select { |tok, _| tok == Rouge::Tokens::KeywordType }
    type_tokens.size.should eq(6)
  end

  it "tokenizes constants" do
    lexer = Rouge::Lexers::TypeScript.new
    tokens = lexer.lex("true false null undefined")
    consts = tokens.select { |tok, _| tok == Rouge::Tokens::KeywordConstant }
    consts.size.should eq(4)
  end

  it "tokenizes strings" do
    lexer = Rouge::Lexers::TypeScript.new
    tokens = lexer.lex(%("hello"))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true

    tokens = lexer.lex("'world'")
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrSingle }.should be_true

    tokens = lexer.lex("`template`")
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrBacktick }.should be_true
  end

  it "tokenizes numbers" do
    lexer = Rouge::Lexers::TypeScript.new
    tokens = lexer.lex("42 3.14 0xFF")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumFloat && val == "3.14" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumHex && val == "0xFF" }.should be_true
  end

  it "tokenizes comments" do
    lexer = Rouge::Lexers::TypeScript.new
    tokens = lexer.lex("// single line")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true

    tokens = lexer.lex("/* multi line */")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentMultiline }.should be_true
  end

  it "tokenizes a complete TypeScript snippet" do
    ts_code = <<-TS
    interface User {
      name: string;
      age: number;
    }

    function greet(user: User): string {
      const msg: string = `Hello, ${user.name}!`;
      return msg;
    }
    TS

    lexer = Rouge::Lexers::TypeScript.new
    tokens = lexer.lex(ts_code)
    tokens.size.should be > 10
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::KeywordType }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrBacktick }.should be_true
  end
end

describe Rouge::Lexers::Rust do
  it "is registered as rust and rs" do
    lexer = Rouge::RegexLexer.find("rust")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::Rust)

    lexer2 = Rouge::RegexLexer.find("rs")
    lexer2.should_not be_nil
    lexer2.should be_a(Rouge::Lexers::Rust)
  end

  it "tokenizes keywords" do
    lexer = Rouge::Lexers::Rust.new
    tokens = lexer.lex("fn main() { let x = 1; }")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "fn" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "let" }.should be_true
  end

  it "tokenizes types" do
    lexer = Rouge::Lexers::Rust.new
    tokens = lexer.lex("i32 u64 String Vec bool")
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "i32" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "u64" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "String" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "bool" }.should be_true
  end

  it "tokenizes constants" do
    lexer = Rouge::Lexers::Rust.new
    tokens = lexer.lex("true false")
    consts = tokens.select { |tok, _| tok == Rouge::Tokens::KeywordConstant }
    consts.size.should eq(2)
  end

  it "tokenizes macro builtins" do
    lexer = Rouge::Lexers::Rust.new
    tokens = lexer.lex("println!(\"hello\")")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameBuiltin && val == "println!" }.should be_true
  end

  it "tokenizes strings" do
    lexer = Rouge::Lexers::Rust.new
    tokens = lexer.lex(%("hello world"))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
  end

  it "tokenizes characters" do
    lexer = Rouge::Lexers::Rust.new
    tokens = lexer.lex("'a'")
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrChar }.should be_true
  end

  it "tokenizes numbers" do
    lexer = Rouge::Lexers::Rust.new
    tokens = lexer.lex("42 3.14 0xFF 0b1010")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumFloat && val == "3.14" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumHex && val == "0xFF" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumBin && val == "0b1010" }.should be_true
  end

  it "tokenizes comments" do
    lexer = Rouge::Lexers::Rust.new
    tokens = lexer.lex("// single line")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true

    tokens = lexer.lex("/* multi line */")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentMultiline }.should be_true
  end

  it "tokenizes doc comments" do
    lexer = Rouge::Lexers::Rust.new
    tokens = lexer.lex("/// doc comment")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentDoc }.should be_true
  end

  it "tokenizes attributes" do
    lexer = Rouge::Lexers::Rust.new
    tokens = lexer.lex("#[derive(Debug)]")
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameDecorator }.should be_true
  end

  it "tokenizes lifetimes" do
    lexer = Rouge::Lexers::Rust.new
    tokens = lexer.lex("'a 'static")
    labels = tokens.select { |tok, _| tok == Rouge::Tokens::NameLabel }
    labels.size.should eq(2)
  end

  it "tokenizes a complete Rust snippet" do
    rust_code = <<-RUST
    use std::collections::HashMap;

    /// A simple struct
    #[derive(Debug)]
    struct Point {
        x: f64,
        y: f64,
    }

    fn main() {
        let p = Point { x: 1.0, y: 2.0 };
        println!("Point: {:?}", p);
    }
    RUST

    lexer = Rouge::Lexers::Rust.new
    tokens = lexer.lex(rust_code)
    tokens.size.should be > 10
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::KeywordType }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentDoc }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameDecorator }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameBuiltin }.should be_true
  end
end
