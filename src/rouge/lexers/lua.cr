module Rouge
  module Lexers
    class Lua < RegexLexer
      def self.tag_name : String
        "lua"
      end

      def self.title_text : String
        "Lua"
      end

      def self.desc_text : String
        "The Lua programming language (lua.org)"
      end

      def self.file_exts : Array(String)
        ["*.lua"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        # :string_double
        sd = State.new(:string_double)
        sd.add_rule Rule.new(/\\[abfnrtvz\\"'\n\d]/, Tokens::StrEscape)
        sd.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        sd.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        states[:string_double] = sd

        # :string_single
        ss = State.new(:string_single)
        ss.add_rule Rule.new(/\\[abfnrtvz\\"'\n\d]/, Tokens::StrEscape)
        ss.add_rule Rule.new(/[^'\\]+/, Tokens::StrSingle)
        ss.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        states[:string_single] = ss

        # :comment_multi
        cm = State.new(:comment_multi)
        cm.add_rule Rule.new(/\]\]/, Tokens::CommentMultiline, pop: true)
        cm.add_rule Rule.new(/[^\]]+/, Tokens::CommentMultiline)
        cm.add_rule Rule.new(/\]/, Tokens::CommentMultiline)
        states[:comment_multi] = cm

        # :root
        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)

        # Multi-line comments
        root.add_rule Rule.new(/--\[\[/, Tokens::CommentMultiline, next_state: :comment_multi)

        # Single-line comments
        root.add_rule Rule.new(/--[^\n]*/, Tokens::CommentSingle)

        # Long strings
        root.add_rule Rule.new(/\[\[[\s\S]*?\]\]/, Tokens::Str)

        # Strings
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)

        # Constants
        root.add_rule Rule.new(/\b(?:true|false)\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\bnil\b/, Tokens::KeywordConstant)

        # Keywords
        root.add_rule Rule.new(/\b(?:and|break|do|else|elseif|end|for|function|goto|if|in|local|not|or|repeat|return|then|until|while)\b/, Tokens::Keyword)

        # Builtins
        root.add_rule Rule.new(/\b(?:print|type|tostring|tonumber|pairs|ipairs|next|select|unpack|error|pcall|xpcall|assert|require|setmetatable|getmetatable|rawget|rawset|rawequal)\b/, Tokens::NameBuiltin)

        # Builtin modules
        root.add_rule Rule.new(/\b(?:table|string|math|io|os|coroutine)\b/, Tokens::NameBuiltin)

        # Numbers
        root.add_rule Rule.new(/0[xX][0-9a-fA-F]+(?:\.[0-9a-fA-F]+)?(?:[pP][+-]?\d+)?/, Tokens::NumHex)
        root.add_rule Rule.new(/\d+\.\d+(?:[eE][+-]?\d+)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+[eE][+-]?\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        # Operators
        root.add_rule Rule.new(/\.\.\./, Tokens::Operator)
        root.add_rule Rule.new(/\.\./, Tokens::Operator)
        root.add_rule Rule.new(/~=/, Tokens::Operator)
        root.add_rule Rule.new(/[+\-*\/%^#<>=]=?/, Tokens::Operator)

        # Punctuation
        root.add_rule Rule.new(/[{}()\[\];,:]+/, Tokens::Punctuation)
        root.add_rule Rule.new(/\.(?!\.)/, Tokens::Punctuation)

        # Identifiers
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("lua", Lua)
  end
end
