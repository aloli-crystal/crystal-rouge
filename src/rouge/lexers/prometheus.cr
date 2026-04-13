module Rouge
  module Lexers
    class Prometheus < RegexLexer
      def self.tag_name : String
        "prometheus"
      end

      def self.title_text : String
        "PromQL"
      end

      def self.desc_text : String
        "Prometheus Query Language"
      end

      def self.file_exts : Array(String)
        ["*.promql"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        sd = State.new(:string_double)
        sd.add_rule Rule.new(/\\./, Tokens::StrEscape)
        sd.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        sd.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        states[:string_double] = sd

        ss = State.new(:string_single)
        ss.add_rule Rule.new(/\\./, Tokens::StrEscape)
        ss.add_rule Rule.new(/[^'\\]+/, Tokens::StrSingle)
        ss.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        states[:string_single] = ss

        sb = State.new(:string_backtick)
        sb.add_rule Rule.new(/[^`]+/, Tokens::StrBacktick)
        sb.add_rule Rule.new(/`/, Tokens::StrBacktick, pop: true)
        states[:string_backtick] = sb

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/#[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)
        root.add_rule Rule.new(/`/, Tokens::StrBacktick, next_state: :string_backtick)

        root.add_rule Rule.new(/\b(?:bool)\b/, Tokens::KeywordConstant)

        # Aggregation operators
        root.add_rule Rule.new(/\b(?:sum|avg|min|max|count|count_values|group|stddev|stdvar|topk|bottomk|quantile)\b/, Tokens::Keyword)

        # Functions
        root.add_rule Rule.new(/\b(?:rate|irate|increase|delta|idelta|resets|changes|absent|absent_over_time|ceil|floor|round|clamp|clamp_min|clamp_max|exp|ln|log2|log10|sqrt|sgn|sort|sort_desc|time|timestamp|day_of_month|day_of_week|day_of_year|days_in_month|hour|minute|month|year|label_join|label_replace|vector|scalar|histogram_quantile)\b/, Tokens::NameBuiltin)

        # Modifiers
        root.add_rule Rule.new(/\b(?:on|ignoring|group_left|group_right|by|without|offset|and|or|unless)\b/, Tokens::OperatorWord)

        # Duration
        root.add_rule Rule.new(/\d+(?:ms|s|m|h|d|w|y)/, Tokens::LiteralDate)

        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        root.add_rule Rule.new(/[+\-*\/<>=!^%]+/, Tokens::Operator)
        root.add_rule Rule.new(/[(){};\[\],:]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_:]\w*/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("prometheus", Prometheus)
    RegexLexer.register("promql", Prometheus)
  end
end
