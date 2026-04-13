module Rouge
  module Lexers
    class SQF < RegexLexer
      def self.tag_name : String
        "sqf"
      end

      def self.title_text : String
        "SQF"
      end

      def self.desc_text : String
        "SQF (Arma scripting language)"
      end

      def self.file_exts : Array(String)
        ["*.sqf"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)

        # Comments
        root.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :multiline_comment)

        # Strings
        root.add_rule Rule.new(/"(?:[^"\\]|\\.)*"/, Tokens::StrDouble)
        root.add_rule Rule.new(/'(?:[^'\\]|\\.)*'/, Tokens::StrSingle)

        # Keywords (case insensitive)
        root.add_rule Rule.new(/\b(?:if|then|else|exitWith|while|do|for|forEach|from|to|step|switch|case|default|private|params|call|spawn|scriptDone|sleep|waitUntil|isNil|isNull|count|select|set|resize|pushBack|pushBackUnique|deleteAt|deleteRange|find|in|apply|reverse|sort)\b/i, Tokens::Keyword)

        # Constants
        root.add_rule Rule.new(/\b(?:true|false|nil|objNull|grpNull|controlNull|displayNull|locationNull|teamMemberNull|configNull|taskNull|diaryRecordNull|scriptNull)\b/i, Tokens::KeywordConstant)

        # Side constants
        root.add_rule Rule.new(/\b(?:east|west|resistance|civilian|sideEmpty|sideLogic|sideUnknown)\b/i, Tokens::NameConstant)

        # Built-in commands
        root.add_rule Rule.new(/\b(?:player|vehicle|position|getPos|setPos|createVehicle|deleteVehicle|hint|systemChat|diag_log|format|str|parseNumber|parseText|typeOf|className|isKindOf|side)\b/i, Tokens::NameBuiltin)

        # Numbers
        root.add_rule Rule.new(/0x[0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        # Operators
        root.add_rule Rule.new(/[+\-*\/%=!<>&|^~]+/, Tokens::Operator)

        # Punctuation
        root.add_rule Rule.new(/[{}\[\]();,:#.]/, Tokens::Punctuation)

        # Identifiers
        root.add_rule Rule.new(/[a-zA-Z_][a-zA-Z0-9_]*/, Tokens::Name)

        root.add_rule Rule.new(/./, Tokens::Text)

        states[:root] = root

        mc = State.new(:multiline_comment)
        mc.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        mc.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        mc.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:multiline_comment] = mc

        states
      end
    end

    RegexLexer.register("sqf", SQF)
  end
end
