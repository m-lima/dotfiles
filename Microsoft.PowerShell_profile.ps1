# Load computer identifying symbol
. $ENV:HOME\Documents\WindowsPowerShell\ComputerSymbol.ps1

###########################
# Function Aliases
###########################

## Navigation

function fd {
  cd "${env:USERPROFILE}"
}

function vd {
  param(
    [int]$amount = 1
  )

  while ($amount -gt 0) {
    $back = "../" + $back
    $amount--
  }

  cd $back
}

function cpwd {
#  pwd | head -4 | tail -1 | clip
  $pwd.path.ToLower() | clip
}

function ppwd {
  $clipPath = $(Get-Clipboard -Raw -Format Text -TextFormatType Text)
  cd $clipPath.Substring(1, $clipPath.Length - 3)
}

function BackOneDir {
  $GLOBAL:addToStack = $false
  if ($GLOBAL:dirStack.Count) {
    $lastDir = $GLOBAL:dirStack.Pop()
    cd $lastDir
  }
}

## Short-hands
function touch {
  ni -type file $args
}

function ee {
  ii .
}

function oct {
  pushd "$env:LOCALAPPDATA/scoop/apps/octave/4.0.3/bin"
  ./octave.exe -i --no-gui
  popd
}

function def($word) {
  if ($word -ne $null -and $word -ne '') {
    $word = "dict://dict.org/d:" + $word
    $previousColor = $Host.UI.RawUI.ForegroundColor
    $Host.UI.RawUI.ForegroundColor = "Green"
    gurl $word 2> $null | sls -pattern '^[0-9][0-9][0-9] ' -notmatch
    $Host.UI.RawUI.ForegroundColor = $previousColor
  }
}

function corn {
  param(
    [Parameter(Mandatory=$true)][string]$action,
    [string]$params = "",
    [string]$url = "localhost",
    [int]$port = 8008,
    [string]$user = "popcorn",
    [string]$pass = "popcorn",
    [switch]$trace
  )

  gurl $(if($trace) {'--trace-ascii'}) $(if($trace) {'-'}) -u ${user}:${pass} -d $('{ \"jsonrpc\": \"2.0\", \"method\": \"' + ${action} + '\", \"params\": { ' + ${params} + ' }, \"id\": 3 }') http://${url}:${port}
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

## Git
function gsb {
  git status -sb
}

function gp {
  if ($args.count 2> $null) {
    git push $args
  } else {
    git push
  }
}

function gl {
  if ($args.count 2> $null) {
    git pull $args
  } else {
    git pull
  }
}

function gc {
  git commit -m $args
}

function gca {
  git commit -a -m $args
}

function gco {
  git checkout $args
}

function gsu {
  git submodule update --init --recursive
}

function pw {
  $GLOBAL:fullPrompt = $true
}

###########################
# Aliases
###########################
# Editors
set-alias gvi "${env:ProgramFiles(x86)}\Vim\vim80\gvim.exe"
set-alias vi "${env:ProgramFiles(x86)}\Vim\vim80\vim.exe"
set-alias npd "${env:ProgramFiles(x86)}\Notepad++\notepad++.exe"
set-alias em "${env:USERPROFILE}\Bin\Emacs\bin\emacs.exe"

# Commands
set-alias gurl "${env:LOCALAPPDATA}/scoop/shims/curl.exe"
set-alias whr where.exe
set-alias tlt "${env:LOCALAPPDATA}/scoop/shims/telnet.exe"
set-alias l ls

# Functions
set-alias bd BackOneDir
set-alias cl activateVS

###########################
# Prompt
###########################
function prompt {
  $separator = ""
  $initial = " $([char]$symbol) "
  if ($GLOBAL:fullPrompt) {
    Write-HOst -NoNewline $initial -BackgroundColor "Black"
    Write-Host -NoNewline $separator -ForegroundColor "Black" -BackgroundColor "DarkBlue"
    $location = " " + $(Get-Location).ToString() + " "
    Write-Host $location.Replace($HOME, "~") -NoNewLine -ForegroundColor "Black" -BackgroundColor "DarkBlue"

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
        $backColor = "DarkRed"
      } else {
        if ($ref -ne "refs/heads/master") {
          Write-Host -NoNewline " " -BackgroundColor "Black"
        }

        # Git status
        ($status = git status --porcelain) | out-null
        if ($status.length -gt 0) {
          $backColor = "DarkYellow"
        } else {
          $backColor = "DarkGreen"
        }
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

###########
# Examples
#
## Count source lines in CXX Git project
# $total = 0
# gci = src\* -R -Include "*.cpp","*.hpp" -Exclude "WlopSimplifyVerbose.hpp" | `
# foreach {
#   echo $_.FullName
#   $total = $(cat $_.FullName | wc -l)
# }
# echo $total
