module Rouge
  module Lexers
    class Magik < RegexLexer
      def self.tag_name : String
        "magik"
      end

      def self.title_text : String
        "Magik"
      end

      def self.desc_text : String
        "Smallworld Magik language"
      end

      def self.file_exts : Array(String)
        ["*.magik"]
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

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/#[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)

        root.add_rule Rule.new(/\b(?:_true|_false|_unset|_maybe)\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\b(?:_method|_endmethod|_proc|_endproc|_block|_endblock|_if|_then|_else|_elif|_endif|_for|_over|_loop|_endloop|_while|_try|_when|_endtry|_catch|_endcatch|_throw|_handling|_protect|_protection|_endprotect|_lock|_endlock|_return|_self|_super|_clone|_global|_local|_constant|_dynamic|_import|_package|_private|_iter|_abstract|_pragma|_gather|_scatter|_optional|_allresults|_class|_mixin|_is|_isnt|_and|_or|_not|_xor|_mod|_div|_cf)\b/, Tokens::Keyword)

        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        root.add_rule Rule.new(/[+\-*\/<>=!^~]+/, Tokens::Operator)
        root.add_rule Rule.new(/[(){};\[\],.:@]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_!?]\w*/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("magik", Magik)
  end
end
