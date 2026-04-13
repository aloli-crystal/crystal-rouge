module Rouge
  module Lexers
    class ObjectiveCpp < RegexLexer
      def self.tag_name : String
        "objective_cpp"
      end

      def self.title_text : String
        "Objective-C++"
      end

      def self.desc_text : String
        "Objective-C++ programming language"
      end

      def self.file_exts : Array(String)
        ["*.mm"]
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

        cm = State.new(:comment_multi)
        cm.add_rule Rule.new(/\*\//, Tokens::CommentMultiline, pop: true)
        cm.add_rule Rule.new(/[^*]+/, Tokens::CommentMultiline)
        cm.add_rule Rule.new(/\*/, Tokens::CommentMultiline)
        states[:comment_multi] = cm

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/\/[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :comment_multi)

        # ObjC NSString
        root.add_rule Rule.new(/@"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)

        # Preprocessor
        root.add_rule Rule.new(/#\s*(?:include|import|define|ifdef|ifndef|endif|if|else|elif|pragma|undef)[^\n]*/, Tokens::CommentPreproc)

        root.add_rule Rule.new(/\b(?:YES|NO|nil)\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\b(?:true|false|nullptr|NULL)\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/\b(?:int|float|double|char|void|bool|long|short|unsigned|signed|id|BOOL|NSInteger|NSUInteger|CGFloat|NSString|NSArray|NSDictionary)\b/, Tokens::KeywordType)

        # ObjC keywords
        root.add_rule Rule.new(/@(?:interface|implementation|end|protocol|property|synthesize|dynamic|selector|class|public|private|protected|optional|required|autoreleasepool|try|catch|finally|throw)\b/, Tokens::Keyword)

        # C++ keywords
        root.add_rule Rule.new(/\b(?:if|else|for|while|do|switch|case|default|break|continue|return|goto|try|catch|throw|new|delete|class|struct|union|enum|namespace|using|template|typename|typedef|virtual|override|static|const|constexpr|volatile|inline|extern|register|explicit|operator|public|private|protected|friend|this|self|super|auto|decltype|sizeof|alignof|static_cast|dynamic_cast|const_cast|reinterpret_cast)\b/, Tokens::Keyword)

        root.add_rule Rule.new(/0[xX][0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/\d+\.\d+(?:f|F)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)

        root.add_rule Rule.new(/[+\-*\/<>=!&|^~%]+/, Tokens::Operator)
        root.add_rule Rule.new(/[(){};\[\],:.]/, Tokens::Punctuation)
        root.add_rule Rule.new(/'[^'\\]'|'\\.'/, Tokens::StrChar)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)

        states[:root] = root
        states
      end
    end

    RegexLexer.register("objective_cpp", ObjectiveCpp)
    RegexLexer.register("objcpp", ObjectiveCpp)
    RegexLexer.register("objective_c++", ObjectiveCpp)
    RegexLexer.register("objc++", ObjectiveCpp)
  end
end
