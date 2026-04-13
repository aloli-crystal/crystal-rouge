module Rouge
  module Lexers
    class JSX < RegexLexer
      def self.tag_name : String
        "jsx"
      end

      def self.title_text : String
        "JSX"
      end

      def self.desc_text : String
        "JavaScript with JSX (React)"
      end

      def self.file_exts : Array(String)
        ["*.jsx"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(
          var let const function return if else for while do switch case break
          continue new this class extends import export default from try catch
          finally throw typeof instanceof in of async await yield delete void
          with debugger super static get set
        )

        constants = %w(true false null undefined NaN Infinity)

        kw_pattern = keywords.join("|")
        const_pattern = constants.join("|")

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/\/.*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :multiline_comment)
        root.add_rule Rule.new(Regex.new("\\b(?:#{kw_pattern})\\b"), Tokens::Keyword)
        root.add_rule Rule.new(Regex.new("\\b(?:#{const_pattern})\\b"), Tokens::KeywordConstant)
        # JSX tags
        root.add_rule Rule.new(/<\/[a-zA-Z][\w.]*>/, Tokens::NameTag)
        root.add_rule Rule.new(/<[a-zA-Z][\w.]*/, Tokens::NameTag)
        root.add_rule Rule.new(/\/>/, Tokens::NameTag)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :double_string)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :single_string)
        root.add_rule Rule.new(/`/, Tokens::StrBacktick, next_state: :template_string)
        root.add_rule Rule.new(/\d+\.\d*/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/0x[0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/=>/, Tokens::Operator)
        root.add_rule Rule.new(/[=!<>+\-*\/%&|^~]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.:?]/, Tokens::Punctuation)
        root.add_rule Rule.new(/>/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_$][\w$]*/, Tokens::Name)
        states[:root] = root

        mc = State.new(:multiline_comment)
        mc.add_rule Rule.new(/[^*\/]+/, Tokens::CommentMultiline)
        mc.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        mc.add_rule Rule.new(/[*\/]/, Tokens::CommentMultiline)
        states[:multiline_comment] = mc

        ds = State.new(:double_string)
        ds.add_rule Rule.new(/\\./, Tokens::StrEscape)
        ds.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        ds.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:double_string] = ds

        ss = State.new(:single_string)
        ss.add_rule Rule.new(/\\./, Tokens::StrEscape)
        ss.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        ss.add_rule Rule.new(/[^'\\]+/, Tokens::StrSingle)
        states[:single_string] = ss

        ts = State.new(:template_string)
        ts.add_rule Rule.new(/\\./, Tokens::StrEscape)
        ts.add_rule Rule.new(/\$\{/, Tokens::StrInterpol, next_state: :template_interp)
        ts.add_rule Rule.new(/`/, Tokens::StrBacktick, pop: true)
        ts.add_rule Rule.new(/[^`\\$]+/, Tokens::StrBacktick)
        ts.add_rule Rule.new(/\$/, Tokens::StrBacktick)
        states[:template_string] = ts

        ti = State.new(:template_interp)
        ti.add_rule Rule.new(/\}/, Tokens::StrInterpol, pop: true)
        ti.add_rule Rule.new(/[^}]+/, Tokens::StrInterpol)
        states[:template_interp] = ti

        states
      end
    end

    RegexLexer.register("jsx", JSX)
  end
end
