module Rouge
  module Lexers
    class CommonLisp < RegexLexer
      def self.tag_name : String
        "common_lisp"
      end

      def self.title_text : String
        "Common Lisp"
      end

      def self.desc_text : String
        "Common Lisp programming language"
      end

      def self.file_exts : Array(String)
        ["*.lisp", "*.lsp", "*.cl", "*.asd"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(defun defmacro defvar defparameter defconstant defclass defgeneric defmethod defpackage defstruct deftype lambda let let\\* flet labels block catch throw tagbody go progn prog1 prog2 if cond case typecase when unless loop do do\\* dolist dotimes return return-from format funcall apply mapcar mapc setf setq quote eval declare declaim proclaim the multiple-value-bind values handler-case handler-bind restart-case with-slots with-accessors make-instance)

        comment_block = State.new(:comment_block)
        comment_block.add_rule Rule.new(/\|#/, Tokens::CommentMultiline, pop: true)
        comment_block.add_rule Rule.new(/[^|]+/, Tokens::CommentMultiline)
        comment_block.add_rule Rule.new(/\|/, Tokens::CommentMultiline)
        states[:comment_block] = comment_block

        string_double = State.new(:string_double)
        string_double.add_rule Rule.new(/\\./, Tokens::StrEscape)
        string_double.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        string_double.add_rule Rule.new(/[^"\\]+/, Tokens::StrDouble)
        states[:string_double] = string_double

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(/;[^\n]*/, Tokens::CommentSingle)
        root.add_rule Rule.new(/#\|/, Tokens::CommentMultiline, next_state: :comment_block)
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/#\\[^\s]+/, Tokens::StrChar)
        root.add_rule Rule.new(/#'[a-zA-Z_+\-*\/<>=!&|^~%?\w]+/, Tokens::NameFunction)
        root.add_rule Rule.new(/(?:#{keywords.join("|")})\b/i, Tokens::Keyword)
        root.add_rule Rule.new(/(?:t|nil)\b/, Tokens::KeywordConstant)
        root.add_rule Rule.new(/:[a-zA-Z_+\-*\/<>=!&|^~%?\w]+/, Tokens::StrSymbol)
        root.add_rule Rule.new(/-?\d+\.\d*/, Tokens::NumFloat)
        root.add_rule Rule.new(/-?\d+\/\d+/, Tokens::Num)
        root.add_rule Rule.new(/-?\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[a-zA-Z_+\-*\/<>=!&|^~%?\w]+/, Tokens::Name)
        root.add_rule Rule.new(/[()']/, Tokens::Punctuation)
        root.add_rule Rule.new(/`|,@?/, Tokens::Operator)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("common_lisp", CommonLisp)
    RegexLexer.register("lisp", CommonLisp)
    RegexLexer.register("cl", CommonLisp)
  end
end
