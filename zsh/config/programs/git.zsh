# Branch
alias gb='git branch'

# Commit
alias gc='git commit -m'
alias gca='git commit -a -m'
alias gcm='git commit --amend --no-edit'

# Clone
alias gcl='git clone --recurse-submodules'

# Diff
alias gd='git diff'
alias gds='git diff --staged'

# Fetch
alias gfa='git fetch --all --prune --jobs=10'

# Push/Pull
alias gl='git pull'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpp='git push --set-upstream origin ${$(git symbolic-ref HEAD)/refs\/heads\//}' # Git push with upstream

# Stash
alias gs='git stash'
alias gsi='git stash push --keep-index'

# Status
alias gsb='git status -sb'
alias glg='git log --stat'
alias glgg='git log --graph --all --oneline'

# Submodules
alias gsu='git submodule update --init --recursive'

# Checkout
alias gt='git checkout'
alias gtb='git checkout -b'

# Switch
alias gw='git switch'
alias gwb='git switch --create'

# Search through all branches
alias ggal="git branch -a | tr -d \* | sed '/->/d' | xargs git grep -HI"

# Reset
alias grh='git reset'
alias grpr='git reset $(git merge-base master HEAD)' # Update HEAD to track divergence point from master

# Show remote status of branches
function gbs {
  local tracked gone local remote terminator
  local show_tracked=1 show_gone=1 show_local=1 show_remote=1
  local trackeds=()
  case "${1}" in
    ''|-f|--full-color)
      tracked='[32m'
      gone='[31m'
      local='[34m'
      remote='[35m'
      terminator='[m'
      ;;
    -fl|--full-color-local)
      tracked='[32m'
      gone='[31m'
      local='[34m'
      terminator='[m'
      unset remote show_remote
      ;;
    -s|--simple-color)
      tracked='[32mT[m '
      gone='[31mG[m '
      local='[34mL[m '
      remote='[35mR[m '
      terminator='[m'
      ;;
    -sl|--simple-color-local)
      tracked='[32mT[m '
      gone='[31mG[m '
      local='[34mL[m '
      terminator='[m'
      unset remote show_remote
      ;;
    -n|--no-color)
      tracked='T '
      gone='G '
      local='L '
      remote='R '
      unset terminator
      ;;
    -nl|--no-color-local)
      tracked='T '
      gone='G '
      local='L '
      unset terminator remote show_remote
      ;;
    -t|--tracked)
      unset tracked gone local remote terminator              show_gone show_local show_remote
      ;;
    -g|--gone)
      unset tracked gone local remote terminator show_tracked           show_local show_remote
      ;;
    -r|--remote)
      unset tracked gone local remote terminator show_tracked show_gone show_local
      ;;
    -l|--local)
      git branch --format "%(refname:short) %(upstream)" | awk '{if (!$2) print $1;}'
      return
      ;;
    *)
      echo 'Unknown parameter: '${@} >&2
      return 1
      ;;
  esac

  for branch in $(git branch --format "%(refname:short):%(upstream)"); do
    lo=$(cut -d':' -f1 <<<"${branch}")
    re=$(cut -d':' -f2 <<<"${branch}")
    if [ "${re}" ]; then
      if git rev-parse "${re}" &>/dev/null; then
        if [ $show_tracked ]; then
          echo "${tracked}${lo}${terminator}"
          trackeds+="${re#refs/remotes/}"
        fi
      else
        [ $show_gone ] && echo "${gone}${lo}${terminator}" || true
      fi
    else
      [ $show_local ] && echo "${local}${lo}${terminator}" || true
    fi
  done

  if [ "${show_remote}" ]; then
    local remotes=($(git remote show))

    for branch in $(git branch -r --format "%(refname:short)"); do
      if [[ "${branch}" != *"/HEAD" ]]; then
        not_tracked=1
        for tracked in ${trackeds}; do
          if [[ "${branch}" == "${tracked}" ]]; then
            unset not_tracked
            break
          fi
        done
        [ $not_tracked ] && echo "${remote}${branch}${terminator}" || true
      fi
    done
  fi
}

# Rebase with upstream branch (default master)
function gfr {
  local branch

  if [ "${1}" ]
  then
    if [[ "${1}" == "-s" ]]
    then
      branch="origin/$(git symbolic-ref --short HEAD)"
    else
      branch="origin/${1}"
    fi
  else
    branch="origin/$(git_main_branch)"
  fi

  git fetch --all --prune --jobs=10 && git rebase "${branch}"
}

# Merge with upstream branch (default master)
function gfm {
  local branch

  if [ "${1}" ]
  then
    branch="origin/${1}"
  else
    branch="origin/$(git_main_branch)"
  fi

  git fetch --all --prune --jobs=10 && git merge "${branch}"
}

# Go back in branch
function bgb {
  if command -v tac &> /dev/null
  then
    local rev=('tac')
  else
    local rev=('tail' '-r')
  fi

  local branches=($(git rev-parse --absolute-git-dir 2> /dev/null | xargs -I{} grep '.*checkout: moving from' "{}/logs/HEAD" | ${rev} | awk 'NR>1{print NR" "$NF}' | sort -t ' ' -k2 -k1n | uniq -f1 | sort -n | head -9 | sed 's/.* //'))

  if [[ -z $branches ]]
  then
    echo 'No git branch history found' 2> /dev/null
    return -1
  fi

  if [[ "$1" =~ '^[0-9]+$' ]]
  then
    git checkout "${branches[$1]}" > /dev/null
  else
    git checkout "${branches[1]}" > /dev/null
  fi
}

function _bgb {
  if ((CURRENT == 2))
  then

    # Setting the tag to indexes and disabling grouping
    zstyle ":completion:${curcontext}:indexes" list-grouped no

    local lines i list

    if command -v tac &> /dev/null
    then
      local rev=('tac')
    else
      local rev=('tail' '-r')
    fi

    # Allowing $HOME to be replaced
    lines=($(git rev-parse --absolute-git-dir 2> /dev/null | xargs -I{} grep '.*checkout: moving from' "{}/logs/HEAD" | ${rev[@]} | awk 'NR>1{print NR" "$NF}' | sort -t ' ' -k2 -k1n | uniq -f1 | sort -n | head -9 | sed 's/.* //' ))
    list=()
    integer i

    # The list is the format "value:description"
    for (( i = 1; i <= $#lines; i++ ))
    do
      list+="$i:$lines[$i]"
    done

    # -V disables the ordering
    _describe -V 'history indices' list

  fi
}

compdef _bgb bgb
