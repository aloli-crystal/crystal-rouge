module Rouge
  module Lexers
    class OpenTypeFeatureFile < RegexLexer
      def self.tag_name : String
        "opentype_feature_file"
      end

      def self.title_text : String
        "OpenType Feature File"
      end

      def self.desc_text : String
        "OpenType feature file format"
      end

      def self.file_exts : Array(String)
        ["*.fea"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/#[^\n]*/, Tokens::CommentSingle)

        root.add_rule Rule.new(/\b(?:feature|lookup|table|script|language|languagesystem|anchorDef|valueRecordDef|markClass|include|sub|by|from|pos|enumerate|ignore|except|subtable|reverse|parameters|FeatureParametersSize|FeatureParametersCharacterVariants)\b/, Tokens::Keyword)
        root.add_rule Rule.new(/\b(?:HorizAxis\.MinMax|VertAxis\.MinMax)\b/, Tokens::Keyword)

        root.add_rule Rule.new(/@[a-zA-Z_]\w*/, Tokens::NameVariable)
        root.add_rule Rule.new(/\\[a-zA-Z_]\w*/, Tokens::NameConstant)

        root.add_rule Rule.new(/0[xX][0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        root.add_rule Rule.new(/[+\-*\/=<>]+/, Tokens::Operator)
        root.add_rule Rule.new(/[(){};\[\],']/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_][\w.]*/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("opentype_feature_file", OpenTypeFeatureFile)
    RegexLexer.register("fea", OpenTypeFeatureFile)
  end
end
