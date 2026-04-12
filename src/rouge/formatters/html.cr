require "html"

module Rouge
  module Formatters
    # Formats tokens as HTML <span> elements with CSS class names.
    # Uses the same CSS classes as Rouge/Pygments (e.g. <span class="k">def</span>).
    class HTML
      # Format tokens to an HTML string
      def format(tokens : Array(TokenPair)) : String
        String.build { |io| format(tokens, io) }
      end

      # Format tokens to an IO
      def format(tokens : Array(TokenPair), io : IO) : Nil
        tokens.each do |tok, val|
          safe_val = ::HTML.escape(val)

          if tok == Tokens::Text || tok.shortname.empty?
            io << safe_val
          else
            io << %(<span class="#{tok.shortname}">)
            io << safe_val
            io << %(</span>)
          end
        end
      end

      # Format with wrapping <pre><code> tags
      def format_wrapped(tokens : Array(TokenPair), css_class : String = "highlight") : String
        String.build do |io|
          io << %(<pre class="#{css_class}"><code>)
          format(tokens, io)
          io << %(</code></pre>)
        end
      end
    end
  end
end
