module Rouge
  module Lexers
    class GLSL < RegexLexer
      def self.tag_name : String
        "glsl"
      end

      def self.title_text : String
        "GLSL"
      end

      def self.desc_text : String
        "OpenGL Shading Language"
      end

      def self.file_exts : Array(String)
        ["*.glsl", "*.vert", "*.frag", "*.geom", "*.comp"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(attribute const uniform varying break continue do for while if else in out inout discard return struct switch case default subroutine flat smooth layout centroid sample patch precision)
        types = %w(void float int bool vec2 vec3 vec4 mat2 mat3 mat4 ivec2 ivec3 ivec4 bvec2 bvec3 bvec4 uvec2 uvec3 uvec4 dvec2 dvec3 dvec4 dmat2 dmat3 dmat4 sampler1D sampler2D sampler3D samplerCube sampler2DArray sampler1DShadow sampler2DShadow samplerCubeShadow sampler2DMS image1D image2D image3D uint double lowp mediump highp)
        constants = %w(true false)

        comment = State.new(:comment)
        comment.add_rule Rule.new(/[^\n]*/, Tokens::CommentSingle, pop: true)
        states[:comment] = comment

        comment_multi = State.new(:comment_multi)
        comment_multi.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        comment_multi.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        comment_multi.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment_multi] = comment_multi

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/\//, Tokens::CommentSingle, next_state: :comment)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multi)
        root.add_rule Rule.new(/#\s*(?:define|undef|if|ifdef|ifndef|else|elif|endif|error|pragma|extension|version|line)\b[^\n]*/, Tokens::CommentPreproc)
        root.add_rule Rule.new(/(?:#{constants.join("|")})\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/(?:#{types.join("|")})\b/, Tokens::KeywordType)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/, Tokens::Keyword)
        root.add_rule Rule.new(/0[xX][0-9a-fA-F]+[uU]?/, Tokens::NumHex)
        root.add_rule Rule.new(/\d+\.\d*(?:[eE][+-]?\d+)?[fF]?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\.\d+(?:[eE][+-]?\d+)?[fF]?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+[uU]?/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/[+\-*\/%&|^~<>=!?:]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.]/, Tokens::Punctuation)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("glsl", GLSL)
  end
end
