branch=$(git -C "${1}" symbolic-ref --short HEAD || git -C "${1}" rev-parse --short HEAD)

[ "${branch}" ] && echo -n "#[fg=colour237]#[fg=magenta,bg=colour237] #[fg=colour246]${branch} "
