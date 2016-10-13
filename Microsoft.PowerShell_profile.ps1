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

function activateGit {
	Remove-Item alias:\git
	. (Resolve-Path "$env:LOCALAPPDATA\GitHub\shell.ps1")
	Import-Module $env:github_posh_git\posh-git.psm1
	$GLOBAL:gitActive = $true
	Write-Host "Git Command Prompt variables set" -ForegroundColor Yellow
	if ($args.count 2> $null) {
		git $args
	}
}

function ee {
	ii .
}

function octg {
  pushd "$env:LOCALAPPDATA/scoop/apps/octave/4.0.3/bin"
  ./octave.exe -i --no-gui
  popd
}

function cpwd {
#  pwd | head -4 | tail -1 | clip
  $pwd.path.ToLower() | clip
}

function BackOneDir {
	$GLOBAL:addToStack = $false
	if ($GLOBAL:dirStack.Count) {
		$lastDir = $GLOBAL:dirStack.Pop()
		cd $lastDir
	}
}

function def($word) {
	$word = "http://google-dictionary.so8848.com/meaning?word=" + $word
	$result = Invoke-WebRequest $word
	$out = $result.AllElements | Where Class -EQ "std" | Select -ExpandProperty innerText
	Write-Host $out -ForegroundColor Green
}

<#
function prompt {
	$separator = ""
	Write-Host -NoNewline " π " -BackgroundColor "Black"
	Write-Host -NoNewline $separator -ForegroundColor "Black" -BackgroundColor "DarkBlue"
	$location = " " + $(Get-Location).ToString() + " "
	Write-Host $location.Replace("C:\Users\mflim_000", "~") -NoNewLine -ForegroundColor "Black" -BackgroundColor "DarkBlue"

	if ($GLOBAL:gitActive) {
		$status = Get-GitStatus

		if ($status) {
		  if ($status.HasWorking) {
			$backColor = "DarkYellow"
			if ($status.HasUntracked) {
			  $gitLine = "  " + $status.Branch + " ±" + $status.Working.Length + "! "
			} else {
			  $gitLine = "  " + $status.Branch + " ±" + $status.Working.Length + " "
			}
		  } else {
			$backColor = "DarkGreen"
			$gitLine = "  " + $status.Branch + " "
		  }
		  Write-Host -NoNewline $separator -ForegroundColor "DarkBlue" -BackgroundColor $backColor
		  Write-Host -NoNewline $gitLine -ForegroundColor "Black" -BackgroundColor $backColor
		  Write-Host -NoNewline $separator -ForegroundColor $backColor
		} else {
		  Write-Host -NoNewline $separator -ForegroundColor "DarkBlue"
		}
	} else {
		Write-Host -NoNewline $separator -ForegroundColor "DarkBlue"
	}
	
	$GLOBAL:nowPath = (Get-Location).Path
    if (($nowPath -ne $oldDir) -AND $GLOBAL:addToStack) {
        $GLOBAL:dirStack.Push($oldDir)
        $GLOBAL:oldDir = $nowPath
    }
    $GLOBAL:AddToStack = $true
	
	return " "
}
#>

function prompt {
	$separator = ""
	Write-Host -NoNewline " π "
  if ($env:HOME -eq $(Get-Location).Path) {
	  Write-Host "~" -NoNewLine
  } else {
    Write-Host $(Split-Path $PWD -Leaf) -NoNewLine
  }

	if ($GLOBAL:gitActive) {
		$status = Get-GitStatus

		if ($status) {
      if ($status.HasWorking) {
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
	} else {
		Write-Host -NoNewline $separator -BackgroundColor "DarkBlue" -ForegroundColor "Black"
		Write-Host -NoNewline $separator -ForegroundColor "DarkBlue"
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
Import-Module PowerTab

#Alias
set-alias gvim "${env:ProgramFiles(x86)}\Vim\vim80\gvim.exe"
set-alias nano "${env:USERPROFILE}\Bin\Nano\nano-2.4.2-win32\nano.exe"
set-alias npd "${env:ProgramFiles(x86)}\Notepad++\notepad++.exe"

set-alias whr "where.exe"
set-alias bd BackOneDir
set-alias ss c:\cygwin64\bin\ssh.exe
#set-alias ss C:\Users\mflim_000\AppData\Local\scoop\shims\ssh.exe
set-alias fd "${env:USERPROFILE}\AppData\Local\GitHub\Portab~1\usr\bin\find.exe"
set-alias vi "${env:ProgramFiles(x86)}\Vim\vim80\vim.exe"
#set-alias vi "${env:USERPROFILE}\AppData\Local\GitHub\Portab~1\usr\bin\vim.exe"

set-alias git activateGit
set-alias cl activateVS

set-alias gurl C:\Users\mflim_000\AppData\Local\scoop\shims\curl.exe

set-alias oct octave-cli

