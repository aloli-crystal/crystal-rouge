module Rouge
  module Lexers
    class CUDA < RegexLexer
      def self.tag_name : String
        "cuda"
      end

      def self.title_text : String
        "CUDA"
      end

      def self.desc_text : String
        "CUDA C/C++ programming language"
      end

      def self.file_exts : Array(String)
        ["*.cu", "*.cuh"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(auto break case catch class const const_cast constexpr continue decltype default delete do dynamic_cast else enum explicit extern false for friend goto if inline namespace new noexcept nullptr operator override private protected public register reinterpret_cast return sizeof static static_assert static_cast struct switch template this throw true try typedef typeid typename union using virtual volatile while)
        cuda_keywords = %w(__global__ __device__ __host__ __shared__ __constant__ __managed__ __restrict__ __noinline__ __forceinline__)
        cuda_builtins = %w(threadIdx blockIdx blockDim gridDim warpSize cudaMalloc cudaFree cudaMemcpy cudaDeviceSynchronize cudaGetLastError cudaMemcpyHostToDevice cudaMemcpyDeviceToHost cudaMemcpyDeviceToDevice cudaSetDevice cudaGetDeviceCount)
        types = %w(bool char double float int long short signed unsigned void dim3 int8_t int16_t int32_t int64_t uint8_t uint16_t uint32_t uint64_t size_t float2 float3 float4 int2 int3 int4 uint2 uint3 uint4 char2 char3 char4)

        comment = State.new(:comment)
        comment.add_rule Rule.new(/[^\n]*/, Tokens::CommentSingle, pop: true)
        states[:comment] = comment

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
        root.add_rule Rule.new(/\/\//, Tokens::CommentSingle, next_state: :comment)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multi)
        root.add_rule Rule.new(/#\s*(?:include|define|undef|if|ifdef|ifndef|else|elif|endif|pragma)\b[^\n]*/, Tokens::CommentPreproc)
        root.add_rule Rule.new(/'(?:\\.|[^'\\])'/, Tokens::StrChar)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/<<<|>>>/, Tokens::Punctuation)
        root.add_rule Rule.new(/(?:#{cuda_builtins.join("|")})\b/, Tokens::NameBuiltin)
        root.add_rule Rule.new(/(?:#{cuda_keywords.join("|")})\b/, Tokens::KeywordReserved)
        root.add_rule Rule.new(/(?:#{types.join("|")})\b/, Tokens::KeywordType)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/, Tokens::Keyword)
        root.add_rule Rule.new(/0[xX][0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/\d+\.\d*(?:[eE][+-]?\d+)?[fF]?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/%&|^~<>=!?:]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("cuda", CUDA)
    RegexLexer.register("cu", CUDA)
  end
end
