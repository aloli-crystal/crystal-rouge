# Port of Rouge::Token
# Tokens are identified by their qualname (e.g. "Keyword.Type" → shortname "kt")
# Compatible with Pygments token types and Rouge CSS classes.

module Rouge
  class Token
    getter name : String
    getter shortname : String
    getter qualname : String
    getter parent : Token?

    def initialize(@name : String, @shortname : String, @qualname : String, @parent : Token? = nil)
    end

    def matches?(other : Token) : Bool
      other.qualname == qualname || other.qualname.starts_with?("#{qualname}.")
    end

    def ==(other : Token) : Bool
      qualname == other.qualname
    end

    def hash(hasher)
      qualname.hash(hasher)
    end

    def to_s(io : IO)
      io << "<Token #{qualname}>"
    end
  end

  # Registry of all token types, compatible with Rouge/Pygments naming.
  module Tokens
    @@registry = {} of String => Token

    def self.[](qualname : String) : Token
      @@registry[qualname]
    end

    def self.[]?(qualname : String) : Token?
      @@registry[qualname]?
    end

    private def self.token(name : String, shortname : String, parent : Token? = nil) : Token
      qualname = parent ? "#{parent.qualname}.#{name}" : name
      t = Token.new(name: name, shortname: shortname, qualname: qualname, parent: parent)
      @@registry[qualname] = t
      t
    end

    # ── Top-level tokens ───────────────────────────────────────────
    Text       = token("Text", "")
    Escape     = token("Escape", "esc")
    Error      = token("Error", "err")
    Other      = token("Other", "x")

    # Text subtokens
    TextWhitespace = token("Whitespace", "w", Text)

    # ── Keyword ────────────────────────────────────────────────────
    Keyword            = token("Keyword", "k")
    KeywordConstant    = token("Constant", "kc", Keyword)
    KeywordDeclaration = token("Declaration", "kd", Keyword)
    KeywordNamespace   = token("Namespace", "kn", Keyword)
    KeywordPseudo      = token("Pseudo", "kp", Keyword)
    KeywordReserved    = token("Reserved", "kr", Keyword)
    KeywordType        = token("Type", "kt", Keyword)
    KeywordVariable    = token("Variable", "kv", Keyword)

    # ── Name ───────────────────────────────────────────────────────
    Name              = token("Name", "n")
    NameAttribute     = token("Attribute", "na", Name)
    NameBuiltin       = token("Builtin", "nb", Name)
    NameBuiltinPseudo = token("Pseudo", "bp", NameBuiltin)
    NameClass         = token("Class", "nc", Name)
    NameConstant      = token("Constant", "no", Name)
    NameDecorator     = token("Decorator", "nd", Name)
    NameEntity        = token("Entity", "ni", Name)
    NameException     = token("Exception", "ne", Name)
    NameFunction      = token("Function", "nf", Name)
    NameFunctionMagic = token("Magic", "fm", NameFunction)
    NameProperty      = token("Property", "py", Name)
    NameLabel         = token("Label", "nl", Name)
    NameNamespace     = token("Namespace", "nn", Name)
    NameOther         = token("Other", "nx", Name)
    NameTag           = token("Tag", "nt", Name)
    NameVariable      = token("Variable", "nv", Name)
    NameVariableClass    = token("Class", "vc", NameVariable)
    NameVariableGlobal   = token("Global", "vg", NameVariable)
    NameVariableInstance = token("Instance", "vi", NameVariable)
    NameVariableMagic    = token("Magic", "vm", NameVariable)

    # ── Literal ────────────────────────────────────────────────────
    Literal     = token("Literal", "l")
    LiteralDate = token("Date", "ld", Literal)

    # Literal.String
    Str          = token("String", "s", Literal)
    StrAffix     = token("Affix", "sa", Str)
    StrBacktick  = token("Backtick", "sb", Str)
    StrChar      = token("Char", "sc", Str)
    StrDelimiter = token("Delimiter", "dl", Str)
    StrDoc       = token("Doc", "sd", Str)
    StrDouble    = token("Double", "s2", Str)
    StrEscape    = token("Escape", "se", Str)
    StrHeredoc   = token("Heredoc", "sh", Str)
    StrInterpol  = token("Interpol", "si", Str)
    StrOther     = token("Other", "sx", Str)
    StrRegex     = token("Regex", "sr", Str)
    StrSingle    = token("Single", "s1", Str)
    StrSymbol    = token("Symbol", "ss", Str)

    # Literal.Number
    Num        = token("Number", "m", Literal)
    NumBin     = token("Bin", "mb", Num)
    NumFloat   = token("Float", "mf", Num)
    NumHex     = token("Hex", "mh", Num)
    NumInteger = token("Integer", "mi", Num)
    NumIntegerLong = token("Long", "il", NumInteger)
    NumOct     = token("Oct", "mo", Num)
    NumOther   = token("Other", "mx", Num)

    # ── Operator ───────────────────────────────────────────────────
    Operator     = token("Operator", "o")
    OperatorWord = token("Word", "ow", Operator)

    # ── Punctuation ────────────────────────────────────────────────
    Punctuation          = token("Punctuation", "p")
    PunctuationIndicator = token("Indicator", "pi", Punctuation)

    # ── Comment ────────────────────────────────────────────────────
    Comment            = token("Comment", "c")
    CommentHashbang    = token("Hashbang", "ch", Comment)
    CommentDoc         = token("Doc", "cd", Comment)
    CommentMultiline   = token("Multiline", "cm", Comment)
    CommentPreproc     = token("Preproc", "cp", Comment)
    CommentPreprocFile = token("PreprocFile", "cpf", Comment)
    CommentSingle      = token("Single", "c1", Comment)
    CommentSpecial     = token("Special", "cs", Comment)

    # ── Generic ────────────────────────────────────────────────────
    Generic           = token("Generic", "g")
    GenericDeleted    = token("Deleted", "gd", Generic)
    GenericEmph       = token("Emph", "ge", Generic)
    GenericEmphStrong = token("EmphStrong", "ges", Generic)
    GenericError      = token("Error", "gr", Generic)
    GenericHeading    = token("Heading", "gh", Generic)
    GenericInserted   = token("Inserted", "gi", Generic)
    GenericLineno     = token("Lineno", "gl", Generic)
    GenericOutput     = token("Output", "go", Generic)
    GenericPrompt     = token("Prompt", "gp", Generic)
    GenericStrong     = token("Strong", "gs", Generic)
    GenericSubheading = token("Subheading", "gu", Generic)
    GenericTraceback  = token("Traceback", "gt", Generic)
  end
end
