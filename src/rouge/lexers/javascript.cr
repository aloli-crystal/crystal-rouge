module Rouge
  module Lexers
    class Javascript < RegexLexer
      def self.tag_name : String
        "javascript"
      end

      def self.title_text : String
        "JavaScript"
      end

      def self.desc_text : String
        "JavaScript programming language (ECMAScript)"
      end

      def self.file_exts : Array(String)
        ["*.js", "*.mjs", "*.cjs", "*.jsx"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(var let const function return if else for while do switch case break continue new this class extends import export default from try catch finally throw typeof instanceof in of async await yield delete void with debugger super static get set)
        constants = %w(true false null undefined NaN Infinity)
        builtins = %w(console document window Array Object String Number Boolean Date Math JSON Promise Map Set Symbol RegExp Error parseInt parseFloat isNaN isFinite encodeURI decodeURI encodeURIComponent decodeURIComponent)

        # :comment_single
        comment_single = State.new(:comment_single)
        comment_single.add_rule Rule.new(/[^\n]*/, Tokens::CommentSingle, pop: true)
        states[:comment_single] = comment_single

        # :comment_multi
        comment_multi = State.new(:comment_multi)
        comment_multi.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        comment_multi.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        comment_multi.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment_multi] = comment_multi

        # :string_double
        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        # :string_single
        string_single = State.new(:string_single)
        string_single.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_single.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        string_single.add_rule Rule.new(/[^'\\]+/, Tokens::StrSingle)
        states[:string_single] = string_single

        # :template_string
        template_string = State.new(:template_string)
        template_string.add_rule Rule.new(/\\./, Tokens::StrEscape)
        template_string.add_rule Rule.new(/\$\{/, Tokens::StrInterpol, next_state: :template_interp)
        template_string.add_rule Rule.new(/`/, Tokens::StrBacktick, pop: true)
        template_string.add_rule Rule.new(/[^`\\$]+/, Tokens::StrBacktick)
        template_string.add_rule Rule.new(/\$/, Tokens::StrBacktick)
        states[:template_string] = template_string

        # :template_interp — reuse root-like rules, closed by }
        template_interp = State.new(:template_interp)
        template_interp.add_rule Rule.new(/\}/, Tokens::StrInterpol, pop: true)
        states[:template_interp] = template_interp

        # :regex
        regex = State.new(:regex)
        regex.add_rule Rule.new(/\\./, Tokens::StrRegex)
        regex.add_rule Rule.new(/\/[gimsuy]*/, Tokens::StrRegex, pop: true)
        regex.add_rule Rule.new(/[^\/\\]+/, Tokens::StrRegex)
        states[:regex] = regex

        # :root
        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/\//, Tokens::CommentSingle, next_state: :comment_single)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multi)

        # Keywords
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/, Tokens::Keyword)

        # Constants
        root.add_rule Rule.new(/(?:#{constants.join("|")})\b/, Tokens::KeywordConstant)

        # Builtins
        root.add_rule Rule.new(/(?:#{builtins.join("|")})\b/, Tokens::NameBuiltin)

        # Function/method names
        root.add_rule Rule.new(/[a-zA-Z_$][\w$]*(?=\s*\()/, Tokens::NameFunction)

        # Identifiers
        root.add_rule Rule.new(/[a-zA-Z_$][\w$]*/, Tokens::Name)

        # Numbers
        root.add_rule Rule.new(/0[bB][01]+(?:_[01]+)*n?\b/, Tokens::NumBin)
        root.add_rule Rule.new(/0[oO][0-7]+(?:_[0-7]+)*n?\b/, Tokens::NumOct)
        root.add_rule Rule.new(/0[xX][0-9a-fA-F]+(?:_[0-9a-fA-F]+)*n?\b/, Tokens::NumHex)
        root.add_rule Rule.new(/(?:\d+(?:_\d+)*\.\d*(?:_\d+)*|\.\d+(?:_\d+)*)(?:[eE][+-]?\d+(?:_\d+)*)?n?\b/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+(?:_\d+)*[eE][+-]?\d+(?:_\d+)*n?\b/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+(?:_\d+)*n?\b/, Tokens::NumInteger)

        # Strings
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)
        root.add_rule Rule.new(/`/, Tokens::StrBacktick, next_state: :template_string)

        # Regex — simple heuristic: after operator or at start
        root.add_rule Rule.new(/\/(?![\/\*])/, Tokens::StrRegex, next_state: :regex)

        # Arrow function
        root.add_rule Rule.new(/=>/, Tokens::Operator)

        # Operators
        root.add_rule Rule.new(/(?:===|!==|==|!=|<=|>=|&&|\|\||<<|>>>|>>|\*\*|\?\?|\?\.|\.\.\.|\+\+|--|[+\-*\/%&|^~!<>]=?|=)/, Tokens::Operator)

        # Punctuation
        root.add_rule Rule.new(/[{}()\[\];,.:?]/, Tokens::Punctuation)

        states[:root] = root

        states
      end
    end

    # Register
    RegexLexer.register("javascript", Javascript)
    RegexLexer.register("js", Javascript)
  end
end
