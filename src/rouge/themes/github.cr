module Rouge
  module Themes
    # GitHub-style syntax highlighting theme.
    # Compatible with Rouge CSS class names.
    module Github
      def self.render(scope : String = ".highlight") : String
        <<-CSS
        #{scope} { background: #fff; color: #1f2328; }
        #{scope} .c  { color: #57606a; } /* Comment */
        #{scope} .c1 { color: #57606a; } /* Comment.Single */
        #{scope} .cd { color: #57606a; } /* Comment.Doc */
        #{scope} .cm { color: #57606a; } /* Comment.Multiline */
        #{scope} .cp { color: #cf222e; font-weight: bold; } /* Comment.Preproc */
        #{scope} .cs { color: #57606a; font-weight: bold; font-style: italic; } /* Comment.Special */
        #{scope} .err { color: #cf222e; } /* Error */
        #{scope} .k  { color: #cf222e; } /* Keyword */
        #{scope} .kc { color: #0550ae; } /* Keyword.Constant */
        #{scope} .kd { color: #cf222e; } /* Keyword.Declaration */
        #{scope} .kn { color: #cf222e; } /* Keyword.Namespace */
        #{scope} .kp { color: #cf222e; } /* Keyword.Pseudo */
        #{scope} .kr { color: #cf222e; } /* Keyword.Reserved */
        #{scope} .kt { color: #953800; } /* Keyword.Type */
        #{scope} .n  { color: #1f2328; } /* Name */
        #{scope} .na { color: #116329; } /* Name.Attribute */
        #{scope} .nb { color: #953800; } /* Name.Builtin */
        #{scope} .nc { color: #953800; font-weight: bold; } /* Name.Class */
        #{scope} .nd { color: #8250df; } /* Name.Decorator */
        #{scope} .ne { color: #953800; } /* Name.Exception */
        #{scope} .nf { color: #8250df; } /* Name.Function */
        #{scope} .nl { color: #0550ae; } /* Name.Label */
        #{scope} .nn { color: #953800; } /* Name.Namespace */
        #{scope} .no { color: #0550ae; } /* Name.Constant */
        #{scope} .nt { color: #116329; } /* Name.Tag */
        #{scope} .nv { color: #0550ae; } /* Name.Variable */
        #{scope} .o  { color: #0550ae; } /* Operator */
        #{scope} .ow { color: #cf222e; font-weight: bold; } /* Operator.Word */
        #{scope} .p  { color: #1f2328; } /* Punctuation */
        #{scope} .s  { color: #0a3069; } /* String */
        #{scope} .s1 { color: #0a3069; } /* String.Single */
        #{scope} .s2 { color: #0a3069; } /* String.Double */
        #{scope} .sa { color: #0a3069; } /* String.Affix */
        #{scope} .sb { color: #0a3069; } /* String.Backtick */
        #{scope} .sc { color: #0a3069; } /* String.Char */
        #{scope} .sd { color: #0a3069; } /* String.Doc */
        #{scope} .se { color: #cf222e; } /* String.Escape */
        #{scope} .sh { color: #0a3069; } /* String.Heredoc */
        #{scope} .si { color: #0a3069; } /* String.Interpol */
        #{scope} .sr { color: #116329; } /* String.Regex */
        #{scope} .ss { color: #0550ae; } /* String.Symbol */
        #{scope} .sx { color: #0a3069; } /* String.Other */
        #{scope} .m  { color: #0550ae; } /* Number */
        #{scope} .mb { color: #0550ae; } /* Number.Bin */
        #{scope} .mf { color: #0550ae; } /* Number.Float */
        #{scope} .mh { color: #0550ae; } /* Number.Hex */
        #{scope} .mi { color: #0550ae; } /* Number.Integer */
        #{scope} .mo { color: #0550ae; } /* Number.Oct */
        #{scope} .l  { color: #0550ae; } /* Literal */
        #{scope} .ld { color: #0550ae; } /* Literal.Date */
        #{scope} .gd { color: #cf222e; background: #ffebe9; } /* Generic.Deleted */
        #{scope} .ge { font-style: italic; } /* Generic.Emph */
        #{scope} .gh { color: #0550ae; font-weight: bold; } /* Generic.Heading */
        #{scope} .gi { color: #116329; background: #dafbe1; } /* Generic.Inserted */
        #{scope} .go { color: #57606a; } /* Generic.Output */
        #{scope} .gp { color: #57606a; } /* Generic.Prompt */
        #{scope} .gs { font-weight: bold; } /* Generic.Strong */
        #{scope} .gu { color: #0550ae; } /* Generic.Subheading */
        #{scope} .gt { color: #cf222e; } /* Generic.Traceback */
        #{scope} .w  { color: #57606a; } /* Text.Whitespace */
        CSS
      end
    end
  end
end
