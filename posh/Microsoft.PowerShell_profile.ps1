Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -Colors @{Parameter = "Cyan"; Operator = "Cyan"}
# Set-PSReadLineOption -Colors @{Command = "$([char]0x1b)[0;93m"; Comment = "$([char]0x1b)[0;32m"; ContinuationPrompt = "$([char]0x1b)[0;37m"; Default = "$([char]0x1b)[0;93m"; Emphasis = "$([char]0x1b)[0;96m"; Error = "$([char]0x1b)[0;91m"; Keyword = "$([char]0x1b)[0;92m"; Member = "$([char]0x1b)[0;97m"; Number = "$([char]0x1b)[0;97m"; Operator = "$([char]0x1b)[0;90m"; Parameter = "$([char]0x1b)[0;90m"; Selection = "$([char]0x1b)[30;47m"; String = "$([char]0x1b)[0;36m"; Type = "$([char]0x1b)[0;37m"; Variable = "$([char]0x1b)[0;92m" }

###########################
# Aliases
###########################
Set-Alias vi nvim
Set-Alias whr where.exe
Set-Alias l ls

###########################
# Commands
###########################
Function cpwd {
  $PWD.path.ToLower() | clip
}

Function ppwd {
  $clipPath = $(Get-Clipboard -Raw -Format Text -TextFormatType Text)
  cd $clipPath.Substring(1, $clipPath.Length - 3)
}

Function ee {
  ii .
}

Function bd {
  param(
    [int]$amount = 1
  )

  $GLOBAL:addToStack = $false
  while ($amount -gt 0 -and $GLOBAL:dirStack.Count) {
    $lastDir = $GLOBAL:dirStack.Pop()
    cd $lastDir
    $amount--
  }
}

Function vd {
  param(
    [int]$amount = 1
  )

  while ($amount -gt 0) {
    $back = "../" + $back
    $amount--
  }

  cd $back
}

###########################
# Git
###########################
# Replaced by git pull
Remove-Item alias:gl -force

# Replaced by git push
Remove-Item alias:gp -force

Function gsb {
  git status -sb
}

Function gp {
  git push $args
}

Function gl {
  git pull $args
}

Function gcmsg {
  git commit -m $args
}

Function gcam {
  git commit -a -m $args
}

Function gd {
  git diff
}

Function gco {
  git checkout $args
}

Function gsu {
  git submodule update --init --recursive
}

###########################
# Prompt
###########################
Function pw {
  $GLOBAL:fullPrompt = !$GLOBAL:fullPrompt
}

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
      $ColorCode = "38;5;${Foreground}"
    } else {
      $ColorCode = "0"
    }

    if ($Background -ne $Null) {
      $PreviousBackground = ${Background}
      $ColorCode += ";48;5;${Background}"
    }

    "$([char]0x1b)[${ColorCode}m"
  }

  # Mark failures
  if (! $ResultCode) {
    $ErrorTag = " $(Set-Color -Foreground 1)✘$(Set-Color -Background 233)"
  }

  $Symbol = "π"
  $Separator = ""
  $Location = $PWD.ToString()

  if ($Location -eq $HOME) {
    $Location = "~"
  } elseif ($Location -ne "/") {
    if (!$GLOBAL:fullPrompt) {
      $Location = Split-Path $PWD -Leaf
    }
  }

  if ($GLOBAL:fullPrompt) {
    "$(Set-Color -Foreground 7 -Background 233)$ErrorTag $Symbol $(Set-Color -Foreground 233 -Background 4)$Separator $Location $(Set-Color)$(Set-Color -Foreground 4)$Separator$(Set-Color) "
  } else {
    "$(Set-Color -Foreground 7 -Background 233)$ErrorTag $Symbol $Location $(Set-Color -Foreground 233 -Background 4)$Separator$(Set-Color)$(Set-Color -Foreground 4)$Separator$(Set-Color) "
  }

  $GLOBAL:nowPath = (Get-Location).Path
  if (($nowPath -ne $oldDir) -AND $GLOBAL:addToStack) {
    $GLOBAL:dirStack.Push($oldDir)
    $GLOBAL:oldDir = $nowPath
  }
  $GLOBAL:AddToStack = $true
}

[System.Collections.Stack]$GLOBAL:dirStack = @()
$GLOBAL:oldDir = ''
$GLOBAL:addToStack = $true