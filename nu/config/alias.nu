# Directories
alias l = ls -a
alias ll = ls -la
alias md = mkdir
alias rd = rmdir

# Neovim
alias vi = nvim

# Git
alias gb = git branch
alias gc = git commit -m
alias gca = git commit -a -m
alias gd = git diff
alias gds = git diff --staged
alias gf = git fetch --all --prune --jobs=10
alias gfm = (git fetch --all --prune --jobs=10; git merge origin/master)
alias gfr = (git fetch --all --prune --jobs=10; git rebase origin/maaster)
alias gl = git pull
alias gp = git push
alias gpf = git push --force-with-lease
alias gpp = git push --set-upstream origin (git symbolic-ref HEAD | split words | last)
alias gs = git stash
alias gsb = git status -sb
alias gsu = git submodule update --init --recursive
alias gt = git checkout
alias gtb = git checkout -b

# Show the tracking state of the current repository
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

def gfr [branch?: string] {
  let branch = if ($branch | is-empty) {
    'origin/master'
  } else {
    'origin/' + $branch
  }
  git fetch --all --prune --jobs=10
  git rebase $branch
}

def gfm [branch?: string] {
  let branch = if ($branch | is-empty) {
    'origin/master'
  } else {
    'origin/' + $branch
  }
  git fetch --all --prune --jobs=10
  git merge $branch
}
