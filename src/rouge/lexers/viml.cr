module Rouge
  module Lexers
    class VimL < RegexLexer
      def self.tag_name : String
        "viml"
      end

      def self.title_text : String
        "VimL"
      end

      def self.desc_text : String
        "Vim script language"
      end

      def self.file_exts : Array(String)
        ["*.vim", ".vimrc"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        keywords = %w(
          if else elseif endif while endwhile for endfor in do try catch endtry
          finally throw function endfunction return call let set unlet execute
          echo echom echoerr normal source runtime autocmd augroup command map
          nmap vmap imap nnoremap vnoremap inoremap silent abort finish redraw
          syntax highlight hi match region keyword
        )

        kw_pattern = keywords.join("|")

        root = State.new(:root)
        root.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        root.add_rule Rule.new(Regex.new("\\b(?:#{kw_pattern})\\b"), Tokens::Keyword)
        root.add_rule Rule.new(/'[^']*'/, Tokens::StrSingle)
        root.add_rule Rule.new(/"[^"]*"/, Tokens::StrDouble)
        root.add_rule Rule.new(/\d+\.\d+/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+/, Tokens::NumInteger)
        root.add_rule Rule.new(/[=!<>]+|\+|-|\*|\/|\./, Tokens::Operator)
        root.add_rule Rule.new(/[{}()\[\];,:]/, Tokens::Punctuation)
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)
        root.add_rule Rule.new(/".*/, Tokens::CommentSingle)
        states[:root] = root

        states
      end
    end

    RegexLexer.register("viml", VimL)
    RegexLexer.register("vim", VimL)
    RegexLexer.register("vimscript", VimL)
  end
end
