module Rouge
  module Lexers
    class PowerShell < RegexLexer
      def self.tag_name : String
        "powershell"
      end

      def self.title_text : String
        "PowerShell"
      end

      def self.desc_text : String
        "Windows PowerShell scripting language"
      end

      def self.file_exts : Array(String)
        ["*.ps1", "*.psm1", "*.psd1"]
      end

      def self.states : Hash(Symbol, State)
        @@my_states
      end

      @@my_states = build_states

      private def self.build_states : Hash(Symbol, State)
        states = {} of Symbol => State

        # :whitespace
        ws = State.new(:whitespace)
        ws.add_rule Rule.new(/\s+/, Tokens::TextWhitespace)
        states[:whitespace] = ws

        # :comment_block
        cb = State.new(:comment_block)
        cb.add_rule Rule.new(/#>/, Tokens::CommentMultiline, pop: true)
        cb.add_rule Rule.new(/[^#]+/, Tokens::CommentMultiline)
        cb.add_rule Rule.new(/#/, Tokens::CommentMultiline)
        states[:comment_block] = cb

        # :string_double
        sd = State.new(:string_double)
        sd.add_rule Rule.new(/\$[a-zA-Z_]\w*(?::[a-zA-Z_]\w*)?/, Tokens::StrInterpol)
        sd.add_rule Rule.new(/\$\{[^}]+\}/, Tokens::StrInterpol)
        sd.add_rule Rule.new(/`[0abefnrtv"$`]/, Tokens::StrEscape)
        sd.add_rule Rule.new(/[^"$`]+/, Tokens::StrDouble)
        sd.add_rule Rule.new(/"/, Tokens::StrDouble, pop: true)
        sd.add_rule Rule.new(/[$`]/, Tokens::StrDouble)
        states[:string_double] = sd

        # :string_single
        ss = State.new(:string_single)
        ss.add_rule Rule.new(/''/, Tokens::StrEscape)
        ss.add_rule Rule.new(/[^']+/, Tokens::StrSingle)
        ss.add_rule Rule.new(/'/, Tokens::StrSingle, pop: true)
        states[:string_single] = ss

        # :root
        root = State.new(:root)
        root.add_mixin :whitespace

        # Comments
        root.add_rule Rule.new(/<#/, Tokens::CommentMultiline, next_state: :comment_block)
        root.add_rule Rule.new(/#[^\n]*/, Tokens::CommentSingle)

        # Here-strings (simplified - treat as single token)
        root.add_rule Rule.new(/@"[\s\S]*?"@/, Tokens::StrHeredoc)
        root.add_rule Rule.new(/@'[\s\S]*?'@/, Tokens::StrHeredoc)

        # Strings
        root.add_rule Rule.new(/"/, Tokens::StrDouble, next_state: :string_double)
        root.add_rule Rule.new(/'/, Tokens::StrSingle, next_state: :string_single)

        # Variables
        root.add_rule Rule.new(/\$\{[^}]+\}/, Tokens::NameVariable)
        root.add_rule Rule.new(/\$(?:env:[a-zA-Z_]\w*|_|PSVersionTable|true|false|null)/, Tokens::NameVariable)
        root.add_rule Rule.new(/\$[a-zA-Z_]\w*/, Tokens::NameVariable)

        # Keywords (case-insensitive)
        root.add_rule Rule.new(/\b(?:Begin|Break|Catch|Class|Continue|Data|Define|Do|DynamicParam|Else|ElseIf|End|Exit|Filter|Finally|For|ForEach|From|Function|If|In|InlineScript|Parallel|Param|Process|Return|Sequence|Switch|Throw|Trap|Try|Until|Using|Var|While|Workflow)\b/i, Tokens::Keyword)

        # Cmdlets (Verb-Noun pattern)
        root.add_rule Rule.new(/\b(?:Get|Set|New|Remove|Write|Select|Where|ForEach|Sort|Group|Measure|Import|Export|Invoke|Test|ConvertTo|ConvertFrom|Out|Add|Clear|Copy|Move|Rename|Start|Stop|Wait|Enter|Exit|Push|Pop|Split|Join|Compare|Format|Update|Register|Unregister|Enable|Disable|Show|Hide|Find|Save|Publish|Install|Uninstall|Use|Debug|Trace|Assert|Confirm|Deny|Approve|Suspend|Resume|Reset|Restart|Checkpoint|Protect|Unprotect|Revoke|Grant|Block|Unblock|Limit|Expand|Compress|Merge|Undo|Redo|Repair|Resolve|Search|Send|Receive|Read|Open|Close|Lock|Unlock|Watch|Backup|Restore|Sync|Mount|Dismount|Edit|Optimize|Initialize)-[A-Za-z]\w*\b/, Tokens::NameBuiltin)

        # Specific well-known cmdlets
        root.add_rule Rule.new(/\b(?:Write-Host|Write-Output|Write-Error|Select-Object|Where-Object|ForEach-Object|Sort-Object|Group-Object|Measure-Object|Import-Module|Export-ModuleMember|Invoke-Expression|Invoke-Command|Test-Path|Get-Content|Set-Content|Out-File|ConvertTo-Json|ConvertFrom-Json)\b/, Tokens::NameBuiltin)

        # Word operators
        root.add_rule Rule.new(/-(?:eq|ne|gt|lt|ge|le|and|or|not|match|like|contains|in|replace|split|join|is|isnot|as|band|bor|bnot|bxor|shl|shr)\b/i, Tokens::OperatorWord)

        # Numbers
        root.add_rule Rule.new(/0[xX][0-9a-fA-F]+(?:L|l)?/, Tokens::NumHex)
        root.add_rule Rule.new(/\d+\.\d+(?:[eE][+-]?\d+)?/, Tokens::NumFloat)
        root.add_rule Rule.new(/\d+(?:L|l)?/, Tokens::NumInteger)

        # Operators
        root.add_rule Rule.new(/[+\-*\/%=!<>&|^~]+/, Tokens::Operator)
        root.add_rule Rule.new(/\|/, Tokens::Punctuation)

        # Identifiers
        root.add_rule Rule.new(/[a-zA-Z_]\w*/, Tokens::Name)

        # Punctuation
        root.add_rule Rule.new(/[(){}\[\],.;:@]/, Tokens::Punctuation)

        states[:root] = root

        states
      end
    end

    RegexLexer.register("powershell", PowerShell)
    RegexLexer.register("posh", PowerShell)
    RegexLexer.register("ps1", PowerShell)
  end
end
