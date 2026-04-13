require "./spec_helper"

describe Rouge::Lexers::GraphQL do
  it "is registered as graphql" do
    lexer = Rouge::RegexLexer.find("graphql")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::GraphQL)
  end

  it "tokenizes keywords" do
    lexer = Rouge::Lexers::GraphQL.new
    tokens = lexer.lex("query mutation type interface")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "query" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "mutation" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "type" }.should be_true
  end

  it "tokenizes built-in types" do
    lexer = Rouge::Lexers::GraphQL.new
    tokens = lexer.lex("Int Float String Boolean ID")
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "Int" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "Boolean" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "ID" }.should be_true
  end

  it "tokenizes constants" do
    lexer = Rouge::Lexers::GraphQL.new
    tokens = lexer.lex("true false null")
    consts = tokens.select { |tok, _| tok == Rouge::Tokens::KeywordConstant }
    consts.size.should eq(3)
  end

  it "tokenizes variables" do
    lexer = Rouge::Lexers::GraphQL.new
    tokens = lexer.lex("$userId $name")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameVariable && val == "$userId" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameVariable && val == "$name" }.should be_true
  end

  it "tokenizes directives" do
    lexer = Rouge::Lexers::GraphQL.new
    tokens = lexer.lex("@deprecated @skip")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameDecorator && val == "@deprecated" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameDecorator && val == "@skip" }.should be_true
  end

  it "tokenizes strings" do
    lexer = Rouge::Lexers::GraphQL.new
    tokens = lexer.lex(%("hello world"))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
  end

  it "tokenizes block strings" do
    lexer = Rouge::Lexers::GraphQL.new
    tokens = lexer.lex(%("""block string"""))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDoc }.should be_true
  end

  it "tokenizes comments" do
    lexer = Rouge::Lexers::GraphQL.new
    tokens = lexer.lex("# a comment")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end

  it "tokenizes numbers" do
    lexer = Rouge::Lexers::GraphQL.new
    tokens = lexer.lex("42 3.14")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumFloat && val == "3.14" }.should be_true
  end

  it "tokenizes a complete GraphQL snippet" do
    gql_code = <<-GQL
    query GetUser($id: ID!) {
      user(id: $id) @deprecated {
        name
        email
        age
      }
    }
    GQL

    lexer = Rouge::Lexers::GraphQL.new
    tokens = lexer.lex(gql_code)
    tokens.size.should be > 10
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameVariable }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::KeywordType }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameDecorator }.should be_true
  end
end

describe Rouge::Lexers::Protobuf do
  it "is registered as protobuf and proto" do
    lexer = Rouge::RegexLexer.find("protobuf")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::Protobuf)

    lexer2 = Rouge::RegexLexer.find("proto")
    lexer2.should_not be_nil
    lexer2.should be_a(Rouge::Lexers::Protobuf)
  end

  it "tokenizes keywords" do
    lexer = Rouge::Lexers::Protobuf.new
    tokens = lexer.lex("message enum service rpc")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "message" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "enum" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "service" }.should be_true
  end

  it "tokenizes types" do
    lexer = Rouge::Lexers::Protobuf.new
    tokens = lexer.lex("int32 string bool double bytes")
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "int32" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "string" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "bool" }.should be_true
  end

  it "tokenizes constants" do
    lexer = Rouge::Lexers::Protobuf.new
    tokens = lexer.lex("true false")
    consts = tokens.select { |tok, _| tok == Rouge::Tokens::KeywordConstant }
    consts.size.should eq(2)
  end

  it "tokenizes strings" do
    lexer = Rouge::Lexers::Protobuf.new
    tokens = lexer.lex(%("proto3"))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
  end

  it "tokenizes comments" do
    lexer = Rouge::Lexers::Protobuf.new
    tokens = lexer.lex("// a comment")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true

    tokens = lexer.lex("/* multi\nline */")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentMultiline }.should be_true
  end

  it "tokenizes numbers" do
    lexer = Rouge::Lexers::Protobuf.new
    tokens = lexer.lex("42 3.14 0xFF")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumFloat && val == "3.14" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumHex && val == "0xFF" }.should be_true
  end

  it "tokenizes message names as NameClass" do
    lexer = Rouge::Lexers::Protobuf.new
    tokens = lexer.lex("message Person {")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameClass && val == "Person" }.should be_true
  end

  it "tokenizes a complete protobuf snippet" do
    proto_code = <<-PROTO
    syntax = "proto3";

    package example;

    message Person {
      string name = 1;
      int32 age = 2;
      bool active = true;
    }

    service Greeter {
      rpc SayHello (HelloRequest) returns (HelloReply);
    }
    PROTO

    lexer = Rouge::Lexers::Protobuf.new
    tokens = lexer.lex(proto_code)
    tokens.size.should be > 10
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::KeywordType }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameClass }.should be_true
  end
end

describe Rouge::Lexers::SCSS do
  it "is registered as scss and sass" do
    lexer = Rouge::RegexLexer.find("scss")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::SCSS)

    lexer2 = Rouge::RegexLexer.find("sass")
    lexer2.should_not be_nil
    lexer2.should be_a(Rouge::Lexers::SassLexer)
  end

  it "tokenizes variables" do
    lexer = Rouge::Lexers::SCSS.new
    tokens = lexer.lex("$primary-color: #333;")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameVariable && val == "$primary-color" }.should be_true
  end

  it "tokenizes SCSS directives" do
    lexer = Rouge::Lexers::SCSS.new
    tokens = lexer.lex("@mixin @include @extend @import @if @else @for @each @while")
    keywords = tokens.select { |tok, _| tok == Rouge::Tokens::Keyword }
    keywords.size.should be >= 5
  end

  it "tokenizes single-line comments" do
    lexer = Rouge::Lexers::SCSS.new
    tokens = lexer.lex("// a comment")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end

  it "tokenizes multi-line comments" do
    lexer = Rouge::Lexers::SCSS.new
    tokens = lexer.lex("/* multi line */")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentMultiline }.should be_true
  end

  it "tokenizes selectors" do
    lexer = Rouge::Lexers::SCSS.new
    tokens = lexer.lex(".container { }")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameClass && val == ".container" }.should be_true
  end

  it "tokenizes parent selector" do
    lexer = Rouge::Lexers::SCSS.new
    tokens = lexer.lex("& .child { }")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Operator && val == "&" }.should be_true
  end

  it "tokenizes properties and values" do
    lexer = Rouge::Lexers::SCSS.new
    tokens = lexer.lex(".a { color: red; }")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameProperty && val == "color" }.should be_true
  end

  it "tokenizes colors" do
    lexer = Rouge::Lexers::SCSS.new
    tokens = lexer.lex(".a { color: #ff0000; }")
    tokens.any? { |tok, _| tok == Rouge::Tokens::NumHex }.should be_true
  end

  it "tokenizes a complete SCSS snippet" do
    scss_code = <<-SCSS
    $primary: #333;
    $font-size: 16px;

    @mixin flex-center {
      display: flex;
      align-items: center;
    }

    .container {
      @include flex-center;
      color: $primary;
      font-size: $font-size;

      &:hover {
        color: #fff;
      }
    }
    SCSS

    lexer = Rouge::Lexers::SCSS.new
    tokens = lexer.lex(scss_code)
    tokens.size.should be > 10
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameVariable }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameProperty }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameClass }.should be_true
  end
end

describe Rouge::Lexers::Zig do
  it "is registered as zig" do
    lexer = Rouge::RegexLexer.find("zig")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::Zig)
  end

  it "tokenizes keywords" do
    lexer = Rouge::Lexers::Zig.new
    tokens = lexer.lex("const fn pub return if else while for")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "const" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "fn" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "pub" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "return" }.should be_true
  end

  it "tokenizes types" do
    lexer = Rouge::Lexers::Zig.new
    tokens = lexer.lex("u8 i32 f64 bool usize void")
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "u8" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "i32" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "f64" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "bool" }.should be_true
  end

  it "tokenizes constants" do
    lexer = Rouge::Lexers::Zig.new
    tokens = lexer.lex("true false null undefined")
    consts = tokens.select { |tok, _| tok == Rouge::Tokens::KeywordConstant }
    consts.size.should eq(4)
  end

  it "tokenizes builtins" do
    lexer = Rouge::Lexers::Zig.new
    tokens = lexer.lex("@import @intCast @ptrCast")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameBuiltin && val == "@import" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameBuiltin && val == "@intCast" }.should be_true
  end

  it "tokenizes strings" do
    lexer = Rouge::Lexers::Zig.new
    tokens = lexer.lex(%("hello world"))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
  end

  it "tokenizes string escapes" do
    lexer = Rouge::Lexers::Zig.new
    tokens = lexer.lex(%("hello\\n"))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrEscape }.should be_true
  end

  it "tokenizes character literals" do
    lexer = Rouge::Lexers::Zig.new
    tokens = lexer.lex("'a'")
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrChar }.should be_true
  end

  it "tokenizes comments" do
    lexer = Rouge::Lexers::Zig.new
    tokens = lexer.lex("// a comment")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end

  it "tokenizes numbers" do
    lexer = Rouge::Lexers::Zig.new
    tokens = lexer.lex("42 3.14 0xFF 0b1010")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumFloat && val == "3.14" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumHex && val == "0xFF" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumBin && val == "0b1010" }.should be_true
  end

  it "tokenizes numbers with underscores" do
    lexer = Rouge::Lexers::Zig.new
    tokens = lexer.lex("1_000_000")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "1_000_000" }.should be_true
  end

  it "tokenizes a complete Zig snippet" do
    zig_code = <<-ZIG
    const std = @import("std");

    pub fn main() !void {
        const x: u32 = 42;
        const y: f64 = 3.14;
        if (x > 0) {
            std.debug.print("hello\\n", .{});
        }
    }
    ZIG

    lexer = Rouge::Lexers::Zig.new
    tokens = lexer.lex(zig_code)
    tokens.size.should be > 10
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::KeywordType }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameBuiltin }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NumInteger }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
  end
end

describe Rouge::Lexers::Terraform do
  it "is registered as terraform, tf, and hcl" do
    lexer = Rouge::RegexLexer.find("terraform")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::Terraform)

    lexer2 = Rouge::RegexLexer.find("tf")
    lexer2.should_not be_nil
    lexer2.should be_a(Rouge::Lexers::Terraform)

    lexer3 = Rouge::RegexLexer.find("hcl")
    lexer3.should_not be_nil
    lexer3.should be_a(Rouge::Lexers::Terraform)
  end

  it "tokenizes keywords" do
    lexer = Rouge::Lexers::Terraform.new
    tokens = lexer.lex("resource data variable output module provider")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "resource" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "variable" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "module" }.should be_true
  end

  it "tokenizes constants" do
    lexer = Rouge::Lexers::Terraform.new
    tokens = lexer.lex("true false null")
    consts = tokens.select { |tok, _| tok == Rouge::Tokens::KeywordConstant }
    consts.size.should eq(3)
  end

  it "tokenizes strings" do
    lexer = Rouge::Lexers::Terraform.new
    tokens = lexer.lex(%("hello world"))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
  end

  it "tokenizes string interpolation" do
    lexer = Rouge::Lexers::Terraform.new
    tokens = lexer.lex(%("prefix-\${var.name}"))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrInterpol }.should be_true
  end

  it "tokenizes comments" do
    lexer = Rouge::Lexers::Terraform.new
    tokens = lexer.lex("# a comment")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true

    tokens = lexer.lex("// another comment")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true

    tokens = lexer.lex("/* multi\nline */")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentMultiline }.should be_true
  end

  it "tokenizes numbers" do
    lexer = Rouge::Lexers::Terraform.new
    tokens = lexer.lex("42 3.14")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumFloat && val == "3.14" }.should be_true
  end

  it "tokenizes functions" do
    lexer = Rouge::Lexers::Terraform.new
    tokens = lexer.lex("length(var.list)")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameBuiltin && val == "length" }.should be_true
  end

  it "tokenizes a complete Terraform snippet" do
    tf_code = <<-TF
    # Configure AWS provider
    provider "aws" {
      region = "us-east-1"
    }

    variable "name" {
      default = "example"
    }

    resource "aws_instance" "web" {
      ami           = "ami-12345"
      instance_type = "t2.micro"
      count         = 3

      tags = {
        Name = "web-\${var.name}"
      }
    }

    output "public_ip" {
      value = length(aws_instance.web)
    }
    TF

    lexer = Rouge::Lexers::Terraform.new
    tokens = lexer.lex(tf_code)
    tokens.size.should be > 10
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NumInteger }.should be_true
  end
end
