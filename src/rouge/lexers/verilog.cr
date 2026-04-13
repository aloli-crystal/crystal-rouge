module Rouge
  module Lexers
    class Verilog < RegexLexer
      def self.tag_name : String
        "verilog"
      end

      def self.title_text : String
        "Verilog"
      end

      def self.desc_text : String
        "Verilog hardware description language"
      end

      def self.file_exts : Array(String)
        ["*.v", "*.sv"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(
          always and assign automatic begin buf bufif0 bufif1 case casex casez
          cmos deassign default defparam disable edge else end endcase endfunction
          endgenerate endmodule endprimitive endspecify endtable endtask event for
          force forever fork function generate genvar highz0 highz1 if ifnone
          initial inout input join large localparam macromodule medium module nand
          negedge nmos nor not notif0 notif1 or output parameter pmos posedge
          primitive pull0 pull1 pulldown pullup rcmos real realtime release repeat
          rnmos rpmos rtran rtranif0 rtranif1 scalared small specify specparam
          strong0 strong1 supply0 supply1 table task tran tranif0 tranif1 tri tri0
          tri1 triand trior trireg vectored wait wand weak0 weak1 while wor xnor xor
        )

        types = %w(integer real time realtime reg wire)

        kw_pattern = keywords.join("|")
        type_pattern = types.join("|")

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/\/.*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :multiline_comment)
        root.add_rule Rule.new(/`(?:define|include|ifdef|ifndef|else|endif|timescale)\b.*/, Tokens::CommentPreproc)
        root.add_rule Rule.new(Regex.new("\\b(?:#{type_pattern})\\b"), Tokens::KeywordType)
        root.add_rule Rule.new(Regex.new("\\b(?:#{kw_pattern})\\b"), Tokens::Keyword)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string)
        root.add_rule Rule.new(/\d+'[bB][01_xXzZ]+/, Tokens::NumBin)
        root.add_rule Rule.new(/\d+'[hH][0-9a-fA-F_xXzZ]+/, Tokens::NumHex)
        root.add_rule Rule.new(/\d+'[oO][0-7_xXzZ]+/, Tokens::NumOct)
        root.add_rule Rule.new(/\d+'[dD][0-9_]+/, Tokens::NumInteger)
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[=!<>]+|&&|\|\||[&|^~]/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.:@#]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        states[:root] = root

        mc = State.new(:multiline_comment)
        mc.add_rule Rule.new(/[^*\/]+/, Tokens::CommentMultiline)
        mc.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        mc.add_rule Rule.new(/[*\/]/, Tokens::CommentMultiline)
        states[:multiline_comment] = mc

        str = State.new(:string)
        str.add_rule Rule.new(/\\./, Tokens::StrEscape)
        str.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        str.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string] = str

        states
      end
    end

    RegexLexer.register("verilog", Verilog)
    RegexLexer.register("v", Verilog)
  end
end
