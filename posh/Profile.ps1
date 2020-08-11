Set-PSReadLineOption -EditMode Emacs
CommandColor                           : "$([char]0x1b)[0;93m"
CommentColor                           : "$([char]0x1b)[32m"
ContinuationPromptColor                : "$([char]0x1b)[37m"
DefaultTokenColor                      : "$([char]0x1b)[93;0m"
EmphasisColor                          : "$([char]0x1b)[96m"
ErrorColor                             : "$([char]0x1b)[91m"
KeywordColor                           : "$([char]0x1b)[92m"
MemberColor                            : "$([char]0x1b)[97m"
NumberColor                            : "$([char]0x1b)[97m"
OperatorColor                          : "$([char]0x1b)[90m"
ParameterColor                         : "$([char]0x1b)[90m"
SelectionColor                         : "$([char]0x1b)[30;47m"
StringColor                            : "$([char]0x1b)[36m"
TypeColor                              : "$([char]0x1b)[37m"
VariableColor                          : "$([char]0x1b)[92m"

function prompt {
    $symbol = "$([char]0x03C0)"
    $delimiter = "$([char]0xe0b0)"
    $escape = "$([char]0x1b)"

    if ( $PWD.ToString() -eq $HOME) {
        $location = "~"
    } else {
        $location = Split-Path $PWD -Leaf
    }

    "$escape[40m $symbol $location $escape[30;44m$delimiter$escape[m$escape[34m$delimiter$escape[m "
}