################################################################################
# Functions                                                                    #
################################################################################

################################################################################
# Shows a prompt to confirm continuation. Aborts the script if cancelled

function checkContinue {
    if ($args.count 2> $null) {
        Write-Host -ForegroundColor "Red" $args
    }

    $continue = Read-Host "Continue? [y/N]"
    if (-not $continue.ToLower().Equals("y")) {
        exit
    }
}

################################################################################
# Checks and installs a package
#
# name: Name of the package
# check: Command to check installation
# install: Command to install package
# return: False is name is not giver
#         Abort if cancelled
#         Success otherwise

function checkInstall {
    param(
        [Parameter(Mandatory=$true)][string]$name,
        [Parameter(Mandatory=$true)][string]$check,
        [Parameter(Mandatory=$true)][string]$install
    )

    $out = Invoke-Expression $check 2>$1
    Write-Host -NoNewline -ForegroundColor "Blue" "Checking $name.. ["
    if ($out) {
        Write-Host -NoNewline -ForegroundColor "Green" "OK"
        Write-Host -ForegroundColor "Blue" "]"        
    } else {
        Write-Host -NoNewline -ForegroundColor "Red" "FAIL"
        Write-Host -ForegroundColor "Blue" "]"

        $input = Read-Host "Install $name? [Y/n]"
        switch ($input) {
            n {
                checkContinue
            }
            default {
                $out = Invoke-Expression $install 2>$1
                if ($out) {
                    Write-Host -ForegroundColor "Green" "Done!"
                } else {
                    checkContinue "Failed installing $name"
                }
            }
        }
    }
}

################################################################################
# Helper function. Since most of the calls to checkInstall are similar
# this function autogenerates the arguments
#
# name: Name of the package
# return: False is name is not giver
#         Abort if cancelled
#         Success otherwise

function checkInstallDefault {
    param([Parameter(Mandatory=$true)][string]$name)
    checkInstall "$name" "Get-Command $name -errorAction SilentlyContinue" "scoop install $name"
}

################################################################################
# Installs a file. The installation might be a copy or a symlink
# The target file is checked for existence and a prompt will ask if it should
# be overwritten
#
# copy: Force a copy instead of a symlink
# name: File name
# source: The source folder
# target: The target folder
# return: Failure if cancelled, or status code of install operation

function installFile {
    param(
        [Parameter(Mandatory=$true)][string]$name,
        [Parameter(Mandatory=$true)][string]$target,
        [Parameter(Mandatory=$true)][string]$source,
        [switch]$copy
    )

    Write-Host -ForegroundColor "Blue" "Installing $name.."
    if (Test-Path "$target\$name") {
        $input = Read-Host "File exists. Override? [y/N]"
        if ($input.ToLower().Equals("y")) {
            rm "$target\$name"
        } else {
            if($copy) {
                return $false
            } else {
                return
            }
        }
    }

    if ($copy) {
        cp "$source/$name" "$target/$name"
        return $true
    } else {
        cmd /c mklink "$target\$name" "$source\$name"
    }
}

################################################################################
# Script start                                                                 #
################################################################################

################################################################################
# Install scoop

checkInstall scoop "Get-Command scoop -errorAction SilentlyContinue" "iex (new-object net.webclient).downloadstring('https://get.scoop.sh')"

################################################################################
# Install misc
checkInstallDefault git
checkInstallDefault curl
checkInstallDefault ssh
checkInstallDefault vim

################################################################################
# Install vundle
checkInstall Vundle "Test-Path $HOME\.vim\bundle\Vundle.vim" "git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim"

################################################################################
# Link files
installFile .vimrc "$HOME" "$PSScriptRoot\vim"
installFile .vimrc.base "$HOME" "$PSScriptRoot\vim"
installFile .gvimrc "$HOME" "$PSScriptRoot\vim"
installFile .vsvimrc "$HOME" "$PSScriptRoot\vim"
installFile Microsoft.PowerShell_profile.ps1 "[Environment]::GetFolderPath("MyDocuments")\WindowsPowerShell" "$PSScriptRoot\posh"

################################################################################
# Copy files
if (installFile -copy ComputerSymbol.ps1 [Environment]::GetFolderPath("MyDocuments")\WindowsPowerShell" "$PSScriptRoot\posh") {
    notepad "$HOME\Documents\WindowsPowerShell\ComputerSymbol.ps1"
}

