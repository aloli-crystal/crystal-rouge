module Rouge
  module Lexers
    class ObjectiveC < RegexLexer
      def self.tag_name : String
        "objective_c"
      end

      def self.title_text : String
        "Objective-C"
      end

      def self.desc_text : String
        "Objective-C programming language"
      end

      def self.file_exts : Array(String)
        ["*.m", "*.h"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        c_keywords = %w(
          auto break case const continue default do else enum extern for goto if
          inline register restrict return sizeof static struct switch typedef
          union volatile while
        )

        objc_keywords = %w(
          self super nil Nil YES NO id Class SEL IMP BOOL instancetype
        )

        objc_directives = %w(
          @interface @implementation @end @protocol @optional @required @property
          @synthesize @dynamic @class @selector @encode @synchronized @try @catch
          @finally @throw @autoreleasepool
        )

        types = %w(
          int long short char float double void unsigned signed size_t
          NSInteger NSUInteger CGFloat NSString NSArray NSDictionary NSNumber
          NSObject NSMutableArray NSMutableDictionary NSMutableString
        )

        kw_pattern = (c_keywords + objc_keywords).join("|")
        dir_pattern = objc_directives.map { |d| Regex.escape(d) }.join("|")
        type_pattern = types.join("|")

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/\/\/.*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/\/\*/, Tokens::CommentMultiline, next_state: :multiline_comment)
        root.add_rule Rule.new(/#\s*(?:import|include|define|ifdef|ifndef|if|else|elif|endif|pragma|undef|error|warning)\b.*/, Tokens::CommentPreproc)
        root.add_rule Rule.new(Regex.new("(?:#{dir_pattern})\\b"), Tokens::KeywordDeclaration)
        root.add_rule Rule.new(Regex.new("\\b(?:#{type_pattern})\\b"), Tokens::KeywordType)
        root.add_rule Rule.new(Regex.new("\\b(?:#{kw_pattern})\\b"), Tokens::Keyword)
        root.add_rule Rule.new(/@"/, Tokens::StrDouble, next_state: :nsstring)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string)
        root.add_rule Rule.new(/'[^'\\]'|'\\.'/, Tokens::StrChar)
        root.add_rule Rule.new(/0[xX][0-9a-fA-F]+/, Tokens::NumHex)
        root.add_rule Rule.new(/\d+\.\d+[fF]?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+[lLuU]*/, Tokens::NumInteger)
        root.add_rule Rule.new(/[+\-*\/%=!<>&|^~?]+/, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,.:@]/, Tokens::Punctuation)
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

        nsstr = State.new(:nsstring)
        nsstr.add_rule Rule.new(/\\./, Tokens::StrEscape)
        nsstr.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        nsstr.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:nsstring] = nsstr

        states
      end
    end

    RegexLexer.register("objective_c", ObjectiveC)
    RegexLexer.register("objc", ObjectiveC)
    RegexLexer.register("objectivec", ObjectiveC)
  end
end
