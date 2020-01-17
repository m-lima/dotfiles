Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -Colors @{Parameter = "Blue"}
Set-PSReadLineOption -Colors @{Operator = "Cyan"}

Function Prompt {
  # Need to capture result at the top
  # as it will be overwritten
  $ResultCode = $?

  # Color management
  $PreviousForeground = $Null
  $PreviousBackground = $Null
  Function Set-Color([Nullable[int]]$Foreground, [Nullable[int]]$Background) {
    if ($Foreground -ne $Null) {
      $PreviousForeground = ${Foreground}
      $ColorCode = "3${Foreground}"
    } else {
      $ColorCode = "0"
    }

    if ($Background -ne $Null) {
      $PreviousBackground = ${Background}
      $ColorCode += ";4${Background}"
    }

    "$([char]0x1b)[${ColorCode}m"
  }

  # Mark failures
  if (! $ResultCode) {
    $ErrorTag = " $(Set-Color -Foreground 1)✘$(Set-Color -Background 0)"
  }

  # Background processes (not sure if worth it)
  # (Get-Job -State Running).Id


  $Symbol = "π"
  $Separator = ""
  $Location = $PWD.ToString()

  if ($Location -eq $HOME) {
    $Location = "~"
  } elseif ($Location -ne "/") {
    $Location = Split-Path $PWD -Leaf
  }

  "$(Set-Color -Background 0)$ErrorTag $Symbol $Location $(Set-Color -Foreground 0 -Background 4)$Separator$(Set-Color)$(Set-Color -Foreground 4)$Separator$(Set-Color) "
}
