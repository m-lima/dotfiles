function touch {
  ni -type file $args
}

function vd {
  cd "${env:USERPROFILE}"
}

function activateVS {
  Remove-Item alias:\cl
  #Set environment variables for Visual Studio Command Prompt
  pushd 'C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC'
  cmd /c "vcvarsall.bat x64&set" |
  foreach {
    if ($_ -match "=") {
      $v = $_.split("="); set-item -force -path "ENV:\$($v[0])"  -value "$($v[1])"
    }
  }
  popd
  Write-Host "Visual Studio 2015 Command Prompt variables set" -ForegroundColor Yellow
  if ($args.count 2> $null) {
    cl $args
  }
}

function ee {
  ii .
}

function oct {
  pushd "$env:LOCALAPPDATA/scoop/apps/octave/4.0.3/bin"
  ./octave.exe -i --no-gui
  popd
}

function cpwd {
#  pwd | head -4 | tail -1 | clip
  $pwd.path.ToLower() | clip
}

function gsb {
  git status -sb
}

function pw {
  $GLOBAL:fullPrompt = $true
}

function BackOneDir {
  $GLOBAL:addToStack = $false
  if ($GLOBAL:dirStack.Count) {
    $lastDir = $GLOBAL:dirStack.Pop()
    cd $lastDir
  }
}

function def($word) {
  $word = "dict://dict.org/d:" + $word
  $previousColor = $Host.UI.RawUI.ForegroundColor
  $Host.UI.RawUI.ForegroundColor = "Green"
  gurl $word 2> $null | grep -v '^[0-9][0-9][0-9] '
  $Host.UI.RawUI.ForegroundColor = $previousColor
}

function prompt {
  $separator = ""
  $initial = " Њ "
  if ($GLOBAL:fullPrompt) {
    Write-HOst -NoNewline $initial -BackgroundColor "Black"
    Write-Host -NoNewline $separator -ForegroundColor "Black" -BackgroundColor "DarkBlue"
    $location = " " + $(Get-Location).ToString() + " "
    Write-Host $location.Replace("C:\Users\mflim_000", "~") -NoNewLine -ForegroundColor "White" -BackgroundColor "DarkBlue"

    ($isGit = git rev-parse --is-inside-work-tree) | out-null
    if ($isGit -eq "true") {
      ($status = git status --porcelain) | out-null
      ($ref = git symbolic-ref HEAD) | out-null
      if (!$ref) {
        $ref = "➦ "
        ($ref += git show-ref --head -s --abbrev | select -First 1) | out-null
      } else {
        $ref = $ref.Replace("refs/heads/", "")
      }
      if ($status.length -gt 0) {
        $backColor = "DarkYellow"
        $gitLine = "  " + $ref + "± "
      } else {
        $backColor = "DarkGreen"
        $gitLine = "  " + $ref + " "
      }
      Write-Host -NoNewline $separator -ForegroundColor "DarkBlue" -BackgroundColor $backColor
      Write-Host -NoNewline $gitLine -ForegroundColor "Black" -BackgroundColor $backColor
      Write-Host -NoNewline $separator -ForegroundColor $backColor
    } else {
      Write-Host -NoNewline $separator -ForegroundColor "DarkBlue"
    }

    $GLOBAL:fullPrompt = $false
  } else {
    if ($env:USERPROFILE -eq $(Get-Location).Path) {
      $initial += "~"
    } else {
      $initial += $(Split-Path $PWD -Leaf)
    }
    Write-Host $initial -NoNewline -BackgroundColor "Black"

    ($isGit = git rev-parse --is-inside-work-tree) | out-null
    if ($isGit -eq "true") {

      # Not on master
      ($ref = git symbolic-ref HEAD) | out-null
      if (!$ref) {
        Write-Host -NoNewline " " -BackgroundColor "Black"
      }

      # Git status
      ($status = git status --porcelain) | out-null
      if ($status.length -gt 0) {
        $backColor = "DarkYellow"
      } else {
        $backColor = "DarkGreen"
      }

      Write-Host -NoNewline $separator -ForegroundColor "Black" -BackgroundColor $backColor
      Write-Host -NoNewline $separator -ForegroundColor $backColor
    } else {
      Write-Host -NoNewline $separator -BackgroundColor "DarkBlue" -ForegroundColor "Black"
      Write-Host -NoNewline $separator -ForegroundColor "DarkBlue"
    }
  }

  $GLOBAL:nowPath = (Get-Location).Path
  if (($nowPath -ne $oldDir) -AND $GLOBAL:addToStack) {
    $GLOBAL:dirStack.Push($oldDir)
    $GLOBAL:oldDir = $nowPath
  }
  $GLOBAL:AddToStack = $true

  return " "
}

#BackDir variables
[System.Collections.Stack]$GLOBAL:dirStack = @()
$GLOBAL:oldDir = ''
$GLOBAL:addToStack = $true
$GLOBAL:gitActive = $false

#Modules
Import-Module "PowerTab" -ArgumentList "${env:USERPROFILE}\Documents\WindowsPowerShell\PowerTabConfig.xml" 2> $null

### Alias

# Editors
set-alias gvim "${env:ProgramFiles(x86)}\Vim\vim80\gvim.exe"
set-alias vi "${env:ProgramFiles(x86)}\Vim\vim80\vim.exe"
set-alias npd "${env:ProgramFiles(x86)}\Notepad++\notepad++.exe"

# Commands
set-alias gurl "${env:LOCALAPPDATA}/scoop/shims/curl.exe"

# Functions
set-alias bd BackOneDir
set-alias cl activateVS
