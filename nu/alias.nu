# Directories
alias l = ls -a
alias md = mkdir
alias rd = rmdir

# Git
alias gb = git branch
alias gc = git commit
alias gcam = git commit -a -m
alias gcm = git commit -m
alias gco = git checkout
alias gd = git diff
alias gds = git diff --staged
alias gl = git pull
alias gp = git push
alias gpp = git push --set-upstream origin (git symbolic-ref HEAD | split words | last)
alias gs = git status -sb

def gbs [] {
  git branch --format "%(refname:short):%(upstream)"
  | lines
  | split column ':' branch upstream
  | each { |$it|
      if ($it.upstream | is-empty) {
        {
          branch: ((ansi blue) + $it.branch)
          upstream: 'Local'
        }
      } else {
        do -i { git rev-parse $it.upstream }
        | complete
        | if $in.exit_code == 0 {
            {
              branch: ((ansi green) + $it.branch)
              upstream: 'Remote'
            }
          } else {
            {
              branch: ((ansi red) + $it.branch)
              upstream: 'Gone'
            }
          }
      }
    }
}
