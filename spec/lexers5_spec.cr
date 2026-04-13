require "./spec_helper"

describe Rouge::Lexers::Swift do
  it "is registered as swift" do
    lexer = Rouge::RegexLexer.find("swift")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::Swift)
  end

  it "tokenizes keywords" do
    lexer = Rouge::Lexers::Swift.new
    tokens = lexer.lex("let x = 1; var y = 2")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "let" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "var" }.should be_true
  end

  it "tokenizes types" do
    lexer = Rouge::Lexers::Swift.new
    tokens = lexer.lex("Int String Bool Double")
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "Int" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "String" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "Bool" }.should be_true
  end

  it "tokenizes constants" do
    lexer = Rouge::Lexers::Swift.new
    tokens = lexer.lex("true false nil")
    consts = tokens.select { |tok, _| tok == Rouge::Tokens::KeywordConstant }
    consts.size.should eq(3)
  end

  it "tokenizes strings with interpolation" do
    lexer = Rouge::Lexers::Swift.new
    tokens = lexer.lex(%("hello \\(name)"))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrInterpol }.should be_true
  end

  it "tokenizes numbers" do
    lexer = Rouge::Lexers::Swift.new
    tokens = lexer.lex("42 3.14 0xFF 0b1010")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumFloat && val == "3.14" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumHex && val == "0xFF" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumBin && val == "0b1010" }.should be_true
  end

  it "tokenizes comments" do
    lexer = Rouge::Lexers::Swift.new
    tokens = lexer.lex("// single line")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true

    tokens = lexer.lex("/* multi line */")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentMultiline }.should be_true
  end

  it "tokenizes a complete Swift snippet" do
    swift_code = <<-SWIFT
    import Foundation

    struct Person {
        let name: String
        var age: Int

        func greet() -> String {
            return "Hello, \\(name)!"
        }
    }

    let p = Person(name: "Alice", age: 30)
    print(p.greet())
    SWIFT

    lexer = Rouge::Lexers::Swift.new
    tokens = lexer.lex(swift_code)
    tokens.size.should be > 10
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::KeywordType }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NumInteger }.should be_true
  end
end

describe Rouge::Lexers::Elixir do
  it "is registered as elixir and ex" do
    lexer = Rouge::RegexLexer.find("elixir")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::Elixir)

    lexer2 = Rouge::RegexLexer.find("ex")
    lexer2.should_not be_nil
    lexer2.should be_a(Rouge::Lexers::Elixir)
  end

  it "tokenizes keywords" do
    lexer = Rouge::Lexers::Elixir.new
    tokens = lexer.lex("defmodule Foo do end")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "defmodule" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "do" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "end" }.should be_true
  end

  it "tokenizes constants" do
    lexer = Rouge::Lexers::Elixir.new
    tokens = lexer.lex("true false nil")
    consts = tokens.select { |tok, _| tok == Rouge::Tokens::KeywordConstant }
    consts.size.should eq(3)
  end

  it "tokenizes atoms" do
    lexer = Rouge::Lexers::Elixir.new
    tokens = lexer.lex(":hello :world")
    atoms = tokens.select { |tok, _| tok == Rouge::Tokens::StrSymbol }
    atoms.size.should eq(2)
  end

  it "tokenizes strings with interpolation" do
    lexer = Rouge::Lexers::Elixir.new
    tokens = lexer.lex(%("hello \#{name}"))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrInterpol }.should be_true
  end

  it "tokenizes pipe operator" do
    lexer = Rouge::Lexers::Elixir.new
    tokens = lexer.lex("list |> Enum.map()")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Operator && val == "|>" }.should be_true
  end

  it "tokenizes numbers" do
    lexer = Rouge::Lexers::Elixir.new
    tokens = lexer.lex("42 3.14 0xFF")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumFloat && val == "3.14" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumHex && val == "0xFF" }.should be_true
  end

  it "tokenizes comments" do
    lexer = Rouge::Lexers::Elixir.new
    tokens = lexer.lex("# a comment")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end

  it "tokenizes a complete Elixir snippet" do
    ex_code = <<-EX
    defmodule Math do
      def factorial(0), do: 1
      def factorial(n) when n > 0 do
        n * factorial(n - 1)
      end
    end

    IO.puts(Math.factorial(10))
    EX

    lexer = Rouge::Lexers::Elixir.new
    tokens = lexer.lex(ex_code)
    tokens.size.should be > 10
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NumInteger }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameClass }.should be_true
  end
end

describe Rouge::Lexers::Scala do
  it "is registered as scala" do
    lexer = Rouge::RegexLexer.find("scala")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::Scala)
  end

  it "tokenizes keywords" do
    lexer = Rouge::Lexers::Scala.new
    tokens = lexer.lex("val x = 1; var y = 2")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "val" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "var" }.should be_true
  end

  it "tokenizes types" do
    lexer = Rouge::Lexers::Scala.new
    tokens = lexer.lex("Int String Boolean Option")
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "Int" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "String" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "Boolean" }.should be_true
  end

  it "tokenizes constants" do
    lexer = Rouge::Lexers::Scala.new
    tokens = lexer.lex("true false null")
    consts = tokens.select { |tok, _| tok == Rouge::Tokens::KeywordConstant }
    consts.size.should eq(3)
  end

  it "tokenizes annotations" do
    lexer = Rouge::Lexers::Scala.new
    tokens = lexer.lex("@deprecated")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameDecorator && val == "@deprecated" }.should be_true
  end

  it "tokenizes strings" do
    lexer = Rouge::Lexers::Scala.new
    tokens = lexer.lex(%("hello world"))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
  end

  it "tokenizes interpolated strings" do
    lexer = Rouge::Lexers::Scala.new
    tokens = lexer.lex(%(s"hello $name"))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrInterpol }.should be_true
  end

  it "tokenizes numbers" do
    lexer = Rouge::Lexers::Scala.new
    tokens = lexer.lex("42 3.14 0xFF 100L")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumFloat && val == "3.14" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumHex && val == "0xFF" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumIntegerLong && val == "100L" }.should be_true
  end

  it "tokenizes comments" do
    lexer = Rouge::Lexers::Scala.new
    tokens = lexer.lex("// single line")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true

    tokens = lexer.lex("/* multi line */")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentMultiline }.should be_true
  end

  it "tokenizes a complete Scala snippet" do
    scala_code = <<-SCALA
    package com.example

    import scala.collection.mutable

    @deprecated
    object Main {
      def main(args: Array[String]): Unit = {
        val x: Int = 42
        val msg = s"Hello, ${args(0)}!"
        println(msg)
      }
    }
    SCALA

    lexer = Rouge::Lexers::Scala.new
    tokens = lexer.lex(scala_code)
    tokens.size.should be > 10
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::KeywordType }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameDecorator }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NumInteger }.should be_true
  end
end

describe Rouge::Lexers::R do
  it "is registered as r, R, and rlang" do
    lexer = Rouge::RegexLexer.find("r")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::R)

    lexer2 = Rouge::RegexLexer.find("R")
    lexer2.should_not be_nil
    lexer2.should be_a(Rouge::Lexers::R)

    lexer3 = Rouge::RegexLexer.find("rlang")
    lexer3.should_not be_nil
    lexer3.should be_a(Rouge::Lexers::R)
  end

  it "tokenizes keywords" do
    lexer = Rouge::Lexers::R.new
    tokens = lexer.lex("if (x) { return(1) } else { 2 }")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "if" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "else" }.should be_true
  end

  it "tokenizes constants" do
    lexer = Rouge::Lexers::R.new
    tokens = lexer.lex("TRUE FALSE NULL NA Inf NaN")
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordConstant && val == "TRUE" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordConstant && val == "FALSE" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordConstant && val == "NULL" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordConstant && val == "NA" }.should be_true
  end

  it "tokenizes builtins" do
    lexer = Rouge::Lexers::R.new
    tokens = lexer.lex("print(length(x))")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameBuiltin && val == "print" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameBuiltin && val == "length" }.should be_true
  end

  it "tokenizes assignment operators" do
    lexer = Rouge::Lexers::R.new
    tokens = lexer.lex("x <- 1")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Operator && val == "<-" }.should be_true
  end

  it "tokenizes strings" do
    lexer = Rouge::Lexers::R.new
    tokens = lexer.lex(%("hello" 'world'))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrSingle }.should be_true
  end

  it "tokenizes numbers" do
    lexer = Rouge::Lexers::R.new
    tokens = lexer.lex("42 3.14 0xFF")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumFloat && val == "3.14" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumHex && val == "0xFF" }.should be_true
  end

  it "tokenizes comments" do
    lexer = Rouge::Lexers::R.new
    tokens = lexer.lex("# a comment")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end

  it "tokenizes a complete R snippet" do
    r_code = <<-RCODE
    # Calculate mean
    x <- c(1, 2, 3, 4, 5)
    result <- mean(x)
    print(result)

    if (result > 2) {
      cat("Above threshold")
    }
    RCODE

    lexer = Rouge::Lexers::R.new
    tokens = lexer.lex(r_code)
    tokens.size.should be > 10
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::Operator }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NumInteger }.should be_true
  end
end

describe Rouge::Lexers::Perl do
  it "is registered as perl and pl" do
    lexer = Rouge::RegexLexer.find("perl")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::Perl)

    lexer2 = Rouge::RegexLexer.find("pl")
    lexer2.should_not be_nil
    lexer2.should be_a(Rouge::Lexers::Perl)
  end

  it "tokenizes keywords" do
    lexer = Rouge::Lexers::Perl.new
    tokens = lexer.lex("my $x = 1; use strict;")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "my" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "use" }.should be_true
  end

  it "tokenizes builtins" do
    lexer = Rouge::Lexers::Perl.new
    tokens = lexer.lex("chomp($line); push(@arr, 1);")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameBuiltin && val == "chomp" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameBuiltin && val == "push" }.should be_true
  end

  it "tokenizes variables" do
    lexer = Rouge::Lexers::Perl.new
    tokens = lexer.lex("$scalar @array %hash")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameVariable && val == "$scalar" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameVariable && val == "@array" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameVariable && val == "%hash" }.should be_true
  end

  it "tokenizes special variables" do
    lexer = Rouge::Lexers::Perl.new
    tokens = lexer.lex("$_ $! $@")
    specials = tokens.select { |tok, _| tok == Rouge::Tokens::NameVariableGlobal }
    specials.size.should eq(3)
  end

  it "tokenizes strings" do
    lexer = Rouge::Lexers::Perl.new
    tokens = lexer.lex(%("hello" 'world'))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrSingle }.should be_true
  end

  it "tokenizes regex" do
    lexer = Rouge::Lexers::Perl.new
    tokens = lexer.lex("/pattern/gi")
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrRegex }.should be_true
  end

  it "tokenizes numbers" do
    lexer = Rouge::Lexers::Perl.new
    tokens = lexer.lex("42 3.14 0xFF")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumFloat && val == "3.14" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumHex && val == "0xFF" }.should be_true
  end

  it "tokenizes comments" do
    lexer = Rouge::Lexers::Perl.new
    tokens = lexer.lex("# a comment")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end

  it "tokenizes a complete Perl snippet" do
    perl_code = <<-PERL
    use strict;
    use warnings;

    my $name = "World";
    my @nums = (1, 2, 3);
    my %hash = (key => "value");

    sub greet {
        my ($who) = @_;
        print "Hello, $who!\\n";
    }

    greet($name);
    PERL

    lexer = Rouge::Lexers::Perl.new
    tokens = lexer.lex(perl_code)
    tokens.size.should be > 10
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameVariable }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NumInteger }.should be_true
  end
end
