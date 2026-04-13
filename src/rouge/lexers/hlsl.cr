module Rouge
  module Lexers
    class HLSL < RegexLexer
      def self.tag_name : String
        "hlsl"
      end

      def self.title_text : String
        "HLSL"
      end

      def self.desc_text : String
        "High-Level Shading Language"
      end

      def self.file_exts : Array(String)
        ["*.hlsl", "*.fx", "*.fxh"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(if else for while do return break continue switch case default struct typedef extern static const volatile inline discard)
        types = %w(void bool int uint float half double float2 float3 float4 int2 int3 int4 half2 half3 half4 matrix float2x2 float3x3 float4x4 cbuffer tbuffer RWTexture2D StructuredBuffer SamplerState Texture2D)
        semantics = %w(SV_Position SV_Target SV_DispatchThreadID register packoffset numthreads)

        comment_multi = State.new(:comment_multi)
        comment_multi.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        comment_multi.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        comment_multi.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment_multi] = comment_multi

        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multi)
        root.add_rule Rule.new(/#[^\n]*/, Tokens::CommentPreproc)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/(?:true|false)\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/(?:#{semantics.join("|")})\b/, Tokens::NameBuiltin)
        root.add_rule Rule.new(/(?:#{types.join("|")})\b/, Tokens::KeywordType)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/, Tokens::Keyword)
        root.add_rule Rule.new(/0[xX][0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/\d+\.\d*(?:[eE][+-]?\d+)?[fFhH]?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+[uU]?/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/%&|^~<>=!?:]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("hlsl", HLSL)
  end
end
