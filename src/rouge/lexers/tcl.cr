module Rouge
  module Lexers
    class Tcl < RegexLexer
      def self.tag_name : String
        "tcl"
      end

      def self.title_text : String
        "Tcl"
      end

      def self.desc_text : String
        "Tcl (Tool Command Language)"
      end

      def self.file_exts : Array(String)
        ["*.tcl"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(
          after append apply array binary break catch cd chan clock close concat
          continue coroutine dict encoding eof error eval exec exit expr fblocked
          fconfigure fcopy file fileevent filename flush for foreach format gets
          glob global history http if incr info interp join lappend lassign lindex
          linsert list llength lmap load lrange lrepeat lreplace lreverse lsearch
          lset lsort namespace open package pid proc puts pwd read regexp regsub
          rename return scan seek set socket source split string subst switch
          tailcall tell throw time trace try unload unset update uplevel upvar
          variable vwait while
        )

        kw_pattern = keywords.join("|")

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/#.*/, Tokens::CommentSingle)
        root.add_rule Rule.new(Regex.new("\\b(?:#{kw_pattern})\\b"), Tokens::Keyword)
        root.add_rule Rule.new(/\$[a-zA-Z_]\w*(?:::[\w]+)*/, Tokens::NameVariable)
        root.add_rule Rule.new(/\$\{[^}]+\}/, Tokens::NameVariable)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :double_string)
        root.add_rule Rule.new(/\{/, Tokens::Punctuation, next_state: :brace_string)
        root.add_rule Rule.new(/\[/, Tokens::Punctuation, next_state: :command_sub)
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/0x[0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/[=!<>+\-*\/]+/, Tokens::Operator)
        root.add_rule Rule.new(/[}\]);,]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        states[:root] = root

        ds = State.new(:double_string)
        ds.add_rule Rule.new(/\\./, Tokens::StrEscape)
        ds.add_rule Rule.new(/\$[a-zA-Z_]\w*/, Tokens::NameVariable)
        ds.add_rule Rule.new(/\[/, Tokens::StrInterpol, next_state: :command_sub)
        ds.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        ds.add_rule Rule.new(/[^"\\$\[]+/, Tokens::StrDouble)
        states[:double_string] = ds

        bs = State.new(:brace_string)
        bs.add_rule Rule.new(/\{/, Tokens::Punctuation, next_state: :brace_string)
        bs.add_rule Rule.new(/\}/, Tokens::Punctuation, pop: true)
        bs.add_rule Rule.new(/[^{}]+/, Tokens::Str)
        states[:brace_string] = bs

        cs = State.new(:command_sub)
        cs.add_rule Rule.new(/\]/, Tokens::Punctuation, pop: true)
        cs.add_rule Rule.new(/[^\]]+/, Tokens::StrInterpol)
        states[:command_sub] = cs

        states
      end
    end

    RegexLexer.register("tcl", Tcl)
  end
end
