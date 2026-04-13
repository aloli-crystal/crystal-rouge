module Rouge
  module Lexers
    class VHDL < RegexLexer
      def self.tag_name : String
        "vhdl"
      end

      def self.title_text : String
        "VHDL"
      end

      def self.desc_text : String
        "VHDL hardware description language"
      end

      def self.file_exts : Array(String)
        ["*.vhd", "*.vhdl"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(
          access after alias all and architecture array assert attribute begin
          block body buffer bus case component configuration constant disconnect
          downto else elsif end entity exit file for function generate generic
          group guarded if impure in inertial inout is label library linkage
          literal loop map mod nand new next nor not null of on open or others
          out package port postponed procedure process pure range record register
          reject rem report return rol ror select severity signal shared sla sll
          sra srl subtype then to transport type unaffected units until use
          variable wait when while with xnor xor
        )

        types = %w(
          bit bit_vector boolean character integer natural positive real
          std_logic std_logic_vector std_ulogic string time
        )

        kw_pattern = keywords.join("|")
        type_pattern = types.join("|")

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/--.*/, Tokens::CommentSingle)
        root.add_rule Rule.new(Regex.new("\\b(?:#{kw_pattern})\\b", Regex::Options::IGNORE_CASE), Tokens::Keyword)
        root.add_rule Rule.new(Regex.new("\\b(?:#{type_pattern})\\b", Regex::Options::IGNORE_CASE), Tokens::KeywordType)
        root.add_rule Rule.new(/'.'/, Tokens::StrChar)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string)
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[+\-*\/=<>&|]|:=|<=|>=|=>|\/=/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.:']/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        states[:root] = root

        str = State.new(:string)
        str.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        str.add_rule Rule.new(/[^"]+/, Tokens::StrDouble)
        states[:string] = str

        states
      end
    end

    RegexLexer.register("vhdl", VHDL)
  end
end
