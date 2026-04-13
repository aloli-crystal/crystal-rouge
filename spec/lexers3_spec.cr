require "./spec_helper"

describe Rouge::Lexers::Java do
  it "is registered as java" do
    lexer = Rouge::RegexLexer.find("java")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::Java)
  end

  it "tokenizes keywords" do
    lexer = Rouge::Lexers::Java.new
    tokens = lexer.lex("public class Main { return; }")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "public" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "class" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "return" }.should be_true
  end

  it "tokenizes types" do
    lexer = Rouge::Lexers::Java.new
    tokens = lexer.lex("int x; String s; boolean b;")
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "int" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "String" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::KeywordType && val == "boolean" }.should be_true
  end

  it "tokenizes constants" do
    lexer = Rouge::Lexers::Java.new
    tokens = lexer.lex("true false null")
    consts = tokens.select { |tok, _| tok == Rouge::Tokens::KeywordConstant }
    consts.size.should eq(3)
  end

  it "tokenizes annotations" do
    lexer = Rouge::Lexers::Java.new
    tokens = lexer.lex("@Override public void foo() {}")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameDecorator && val == "@Override" }.should be_true
  end

  it "tokenizes strings" do
    lexer = Rouge::Lexers::Java.new
    tokens = lexer.lex(%("hello world"))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
  end

  it "tokenizes characters" do
    lexer = Rouge::Lexers::Java.new
    tokens = lexer.lex("'a'")
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrChar }.should be_true
  end

  it "tokenizes numbers" do
    lexer = Rouge::Lexers::Java.new
    tokens = lexer.lex("42 3.14 0xFF 0b1010 100L 1.5f")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumFloat && val == "3.14" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumHex && val == "0xFF" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumBin && val == "0b1010" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumIntegerLong && val == "100L" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumFloat && val == "1.5f" }.should be_true
  end

  it "tokenizes comments" do
    lexer = Rouge::Lexers::Java.new
    tokens = lexer.lex("// single line")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true

    tokens = lexer.lex("/* multi line */")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentMultiline }.should be_true

    tokens = lexer.lex("/** doc comment */")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentDoc }.should be_true
  end

  it "tokenizes a complete Java snippet" do
    java_code = <<-JAVA
    import java.util.List;

    @Override
    public class Main {
        public static void main(String[] args) {
            int x = 42;
            System.out.println("Hello");
        }
    }
    JAVA

    lexer = Rouge::Lexers::Java.new
    tokens = lexer.lex(java_code)
    tokens.size.should be > 10
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::KeywordType }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameDecorator }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NumInteger }.should be_true
  end
end

describe Rouge::Lexers::PHP do
  it "is registered as php" do
    lexer = Rouge::RegexLexer.find("php")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::PHP)
  end

  it "tokenizes keywords" do
    lexer = Rouge::Lexers::PHP.new
    tokens = lexer.lex("function foo() { return; }")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "function" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "return" }.should be_true
  end

  it "tokenizes constants" do
    lexer = Rouge::Lexers::PHP.new
    tokens = lexer.lex("true false null")
    consts = tokens.select { |tok, _| tok == Rouge::Tokens::KeywordConstant }
    consts.size.should eq(3)
  end

  it "tokenizes types" do
    lexer = Rouge::Lexers::PHP.new
    tokens = lexer.lex("int float string bool")
    type_tokens = tokens.select { |tok, _| tok == Rouge::Tokens::KeywordType }
    type_tokens.size.should eq(4)
  end

  it "tokenizes variables" do
    lexer = Rouge::Lexers::PHP.new
    tokens = lexer.lex("$name = 42;")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameVariable && val == "$name" }.should be_true
  end

  it "tokenizes strings with interpolation" do
    lexer = Rouge::Lexers::PHP.new
    tokens = lexer.lex(%("hello $name"))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameVariable && val == "$name" }.should be_true
  end

  it "tokenizes single-quoted strings" do
    lexer = Rouge::Lexers::PHP.new
    tokens = lexer.lex("'hello'")
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrSingle }.should be_true
  end

  it "tokenizes comments" do
    lexer = Rouge::Lexers::PHP.new
    tokens = lexer.lex("// single line")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true

    tokens = lexer.lex("/* multi line */")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentMultiline }.should be_true

    tokens = lexer.lex("# hash comment")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end

  it "tokenizes numbers" do
    lexer = Rouge::Lexers::PHP.new
    tokens = lexer.lex("42 3.14 0xFF 0b1010")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumInteger && val == "42" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumFloat && val == "3.14" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumHex && val == "0xFF" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::NumBin && val == "0b1010" }.should be_true
  end

  it "tokenizes a complete PHP snippet" do
    php_code = <<-PHP
    <?php
    function greet($name) {
        echo "Hello, $name!";
        return true;
    }
    $x = 42;
    ?>
    PHP

    lexer = Rouge::Lexers::PHP.new
    tokens = lexer.lex(php_code)
    tokens.size.should be > 10
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameVariable }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
  end
end

describe Rouge::Lexers::Dockerfile do
  it "is registered as dockerfile and docker" do
    lexer = Rouge::RegexLexer.find("dockerfile")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::Dockerfile)

    lexer2 = Rouge::RegexLexer.find("docker")
    lexer2.should_not be_nil
    lexer2.should be_a(Rouge::Lexers::Dockerfile)
  end

  it "tokenizes instructions" do
    lexer = Rouge::Lexers::Dockerfile.new
    tokens = lexer.lex("FROM ubuntu:20.04")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "FROM" }.should be_true

    tokens = lexer.lex("RUN apt-get update")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "RUN" }.should be_true
  end

  it "tokenizes comments" do
    lexer = Rouge::Lexers::Dockerfile.new
    tokens = lexer.lex("# this is a comment")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end

  it "tokenizes strings" do
    lexer = Rouge::Lexers::Dockerfile.new
    tokens = lexer.lex(%(CMD ["python", "app.py"]))
    tokens.any? { |tok, _| tok == Rouge::Tokens::StrDouble }.should be_true
  end

  it "tokenizes variables" do
    lexer = Rouge::Lexers::Dockerfile.new
    tokens = lexer.lex("ENV PATH=$PATH:/app")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameVariable && val == "$PATH" }.should be_true

    tokens = lexer.lex("RUN echo ${VERSION}")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameVariable && val == "${VERSION}" }.should be_true
  end

  it "tokenizes key=value pairs" do
    lexer = Rouge::Lexers::Dockerfile.new
    tokens = lexer.lex("ENV APP_HOME=/app")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameAttribute && val == "APP_HOME" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Operator && val == "=" }.should be_true
  end

  it "tokenizes a complete Dockerfile snippet" do
    dockerfile = <<-DOCKER
    FROM python:3.9-slim
    WORKDIR /app
    COPY requirements.txt .
    RUN pip install -r requirements.txt
    ENV PORT=8080
    EXPOSE 8080
    CMD ["python", "main.py"]
    DOCKER

    lexer = Rouge::Lexers::Dockerfile.new
    tokens = lexer.lex(dockerfile)
    tokens.size.should be > 10
    tokens.any? { |tok, _| tok == Rouge::Tokens::Keyword }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NumInteger }.should be_true
  end
end

describe Rouge::Lexers::Makefile do
  it "is registered as makefile and make" do
    lexer = Rouge::RegexLexer.find("makefile")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::Makefile)

    lexer2 = Rouge::RegexLexer.find("make")
    lexer2.should_not be_nil
    lexer2.should be_a(Rouge::Lexers::Makefile)
  end

  it "tokenizes comments" do
    lexer = Rouge::Lexers::Makefile.new
    tokens = lexer.lex("# a comment")
    tokens.any? { |tok, _| tok == Rouge::Tokens::CommentSingle }.should be_true
  end

  it "tokenizes targets" do
    lexer = Rouge::Lexers::Makefile.new
    tokens = lexer.lex("build:")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameFunction && val == "build" }.should be_true
  end

  it "tokenizes variable assignments" do
    lexer = Rouge::Lexers::Makefile.new
    tokens = lexer.lex("CC = gcc")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameVariable && val == "CC" }.should be_true
    tokens.any? { |tok, val| tok == Rouge::Tokens::Operator && val == "=" }.should be_true
  end

  it "tokenizes variable references" do
    lexer = Rouge::Lexers::Makefile.new
    tokens = lexer.lex("$(CC)")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameVariable && val == "$(CC)" }.should be_true

    tokens = lexer.lex("${CFLAGS}")
    tokens.any? { |tok, val| tok == Rouge::Tokens::NameVariable && val == "${CFLAGS}" }.should be_true
  end

  it "tokenizes automatic variables" do
    lexer = Rouge::Lexers::Makefile.new
    tokens = lexer.lex("\t$@ $< $^")
    auto_vars = tokens.select { |tok, _| tok == Rouge::Tokens::NameVariable }
    auto_vars.size.should eq(3)
  end

  it "tokenizes directives" do
    lexer = Rouge::Lexers::Makefile.new
    tokens = lexer.lex("ifdef DEBUG")
    tokens.any? { |tok, val| tok == Rouge::Tokens::Keyword && val == "ifdef" }.should be_true
  end

  it "tokenizes a complete Makefile snippet" do
    makefile = <<-MAKE
    CC = gcc
    CFLAGS = -Wall -O2

    build: main.o utils.o
    \t$(CC) $(CFLAGS) -o app $^

    clean:
    \trm -f *.o app
    MAKE

    lexer = Rouge::Lexers::Makefile.new
    tokens = lexer.lex(makefile)
    tokens.size.should be > 10
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameVariable }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::NameFunction }.should be_true
  end
end

describe Rouge::Lexers::Diff do
  it "is registered as diff and patch" do
    lexer = Rouge::RegexLexer.find("diff")
    lexer.should_not be_nil
    lexer.should be_a(Rouge::Lexers::Diff)

    lexer2 = Rouge::RegexLexer.find("patch")
    lexer2.should_not be_nil
    lexer2.should be_a(Rouge::Lexers::Diff)
  end

  it "tokenizes added lines" do
    lexer = Rouge::Lexers::Diff.new
    tokens = lexer.lex("+added line")
    tokens.any? { |tok, _| tok == Rouge::Tokens::GenericInserted }.should be_true
  end

  it "tokenizes removed lines" do
    lexer = Rouge::Lexers::Diff.new
    tokens = lexer.lex("-removed line")
    tokens.any? { |tok, _| tok == Rouge::Tokens::GenericDeleted }.should be_true
  end

  it "tokenizes hunk headers" do
    lexer = Rouge::Lexers::Diff.new
    tokens = lexer.lex("@@ -1,3 +1,4 @@")
    tokens.any? { |tok, _| tok == Rouge::Tokens::GenericSubheading }.should be_true
  end

  it "tokenizes file headers" do
    lexer = Rouge::Lexers::Diff.new
    tokens = lexer.lex("--- a/file.txt\n+++ b/file.txt")
    deleted = tokens.select { |tok, _| tok == Rouge::Tokens::GenericDeleted }
    inserted = tokens.select { |tok, _| tok == Rouge::Tokens::GenericInserted }
    deleted.size.should be > 0
    inserted.size.should be > 0
  end

  it "tokenizes git diff headers" do
    lexer = Rouge::Lexers::Diff.new
    tokens = lexer.lex("diff --git a/file.txt b/file.txt")
    tokens.any? { |tok, _| tok == Rouge::Tokens::GenericHeading }.should be_true
  end

  it "tokenizes index lines" do
    lexer = Rouge::Lexers::Diff.new
    tokens = lexer.lex("index abc1234..def5678 100644")
    tokens.any? { |tok, _| tok == Rouge::Tokens::GenericHeading }.should be_true
  end

  it "tokenizes a complete diff snippet" do
    diff_text = <<-DIFF
    diff --git a/hello.txt b/hello.txt
    index abc1234..def5678 100644
    --- a/hello.txt
    +++ b/hello.txt
    @@ -1,3 +1,4 @@
     unchanged line
    -removed line
    +added line
    +another added line
     context line
    DIFF

    lexer = Rouge::Lexers::Diff.new
    tokens = lexer.lex(diff_text)
    tokens.size.should be > 5
    tokens.any? { |tok, _| tok == Rouge::Tokens::GenericHeading }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::GenericSubheading }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::GenericInserted }.should be_true
    tokens.any? { |tok, _| tok == Rouge::Tokens::GenericDeleted }.should be_true
  end
end
