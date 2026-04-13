module Rouge
  module Lexers
    class VB < RegexLexer
      def self.tag_name : String
        "vb"
      end

      def self.title_text : String
        "Visual Basic"
      end

      def self.desc_text : String
        "Visual Basic / VB.NET"
      end

      def self.file_exts : Array(String)
        ["*.vb", "*.bas"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(
          AddHandler AddressOf Alias And AndAlso As ByRef ByVal Call Case Catch
          Class Const Continue Declare Default Delegate Dim DirectCast Do Each
          Else ElseIf End EndIf Enum Erase Error Event Exit For Friend Function
          Get GetType GetXMLNamespace Global GoSub GoTo Handles If Implements
          Imports In Inherits Interface Is IsNot Let Lib Like Loop Me Mod Module
          MustInherit MustOverride MyBase MyClass Namespace Narrowing New Next Not
          NotInheritable NotOverridable Of On Operator Option Optional Or OrElse
          Overloads Overridable Overrides ParamArray Partial Private Property
          Protected Public RaiseEvent ReadOnly ReDim RemoveHandler Resume Return
          Select Set Shadows Shared Static Step Stop Structure Sub SyncLock Then
          Throw To Try TryCast TypeOf Using Variant Wend When While Widening With
          WithEvents WriteOnly Xor
        )

        type_keywords = %w(
          Boolean Byte Char Date Decimal Double Integer Long Object SByte Short
          Single String UInteger ULong UShort
        )

        constants = %w(True False Nothing)

        kw_pattern = keywords.join("|")
        type_pattern = type_keywords.join("|")
        const_pattern = constants.join("|")

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/'.*/, Tokens::CommentSingle)
        root.add_rule Rule.new(Regex.new("\\bREM\\b.*", Regex::Options::IGNORE_CASE), Tokens::CommentSingle)
        root.add_rule Rule.new(Regex.new("\\b(?:#{kw_pattern})\\b", Regex::Options::IGNORE_CASE), Tokens::Keyword)
        root.add_rule Rule.new(Regex.new("\\b(?:#{type_pattern})\\b", Regex::Options::IGNORE_CASE), Tokens::KeywordType)
        root.add_rule Rule.new(Regex.new("\\b(?:#{const_pattern})\\b", Regex::Options::IGNORE_CASE), Tokens::KeywordConstant)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string)
        root.add_rule Rule.new(/\d+\.\d*/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/&H[0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/[+\-*\/\\^=<>&]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        states[:root] = root

        str = State.new(:string)
        str.add_rule Rule.new(/""/, Tokens::StrEscape)
        str.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        str.add_rule Rule.new(/[^"]+/, Tokens::StrDouble)
        states[:string] = str

        states
      end
    end

    RegexLexer.register("vb", VB)
    RegexLexer.register("vbnet", VB)
    RegexLexer.register("visualbasic", VB)
  end
end
