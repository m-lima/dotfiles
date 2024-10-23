# Colors for ls
LSCOLORS='Gxfxcxdxbxagafxbabacad'
LS_COLORS='di=1;36:ln=35:so=32:pi=33:ex=31:bd=30;46:cd=30;45:su=0;41:sg=30;41:tw=30;42:ow=30;43'

# Match the completion colors to LS_COLORS
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Nicer colors for the `kill` completion
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
