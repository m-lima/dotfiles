# # TODO: Make this persistent?
# zstyle ':completion:*' use-cache yes
# zstyle ':completion:*' cache-path /Users/celo/.zgen/robbyrussell/oh-my-zsh-master/cache
#
# zstyle '*' single-ignored show
# zstyle ':completion:*' list-colors 'di=1;36' 'ln=35' 'so=32' 'pi=33' 'ex=31' 'bd=34;46' 'cd=34;43' 'su=30;41' 'sg=30;46' 'tw=30;42' 'ow=30;43'
# zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'
#
# # Complete '.' and '..'
# zstyle ':completion:*' special-dirs true
#
#
# zstyle ':completion:*:*:*:*:*' menu select
#
# # TODO: Update with $USERNAME
# zstyle ':completion:*:*:*:*:processes' command 'ps -u celo -o pid,user,comm -w -w'
#
# # Don't complete uninteresting users
# zstyle ':completion:*:*:*:users' ignored-patterns adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm ldap lp mail mailman mailnull man messagebus mldonkey mysql nagios named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp usbmux uucp vcsa wwwrun xfs '_*'
# zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
#
# # Disable named-directories autocompletion
# zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
# zstyle zle-hook types isearch-exit isearch-update line-pre-redraw line-init line-finish history-line-set keymap-select
# zstyle zle-line-finish widgets 0:user:zle-line-finish 1:_zsh_highlight__zle-line-finish
# zstyle zle-line-pre-redraw widgets 1:_zsh_highlight__zle-line-pre-redraw
#
# # zstyle ':url-quote-magic:*' url-metas '*?[]^(|)~#{}='
# # zstyle -e ':url-quote-magic:*' url-seps 'reply=(";&<>${histchars[1]}")'
# # zstyle -e :url-quote-magic url-globbers $'zmodload -i zsh/parameter;\n\t reply=( noglob\n\t\t ${(k)galiases[(R)(* |)(noglob|urlglobber|globurl) *]:-}\n\t\t ${(k)aliases[(R)(* |)(noglob|urlglobber|globurl) *]:-} )'
# # zstyle :urlglobber url-local-schema ftp file
# # zstyle :urlglobber url-other-schema http https ftp
#
#
# # Export autoload as well
#
# # # Set options (setopt)
# # # alwaystoend
# # autopushd
# # combiningchars
# # # completeinword
# # extendedhistory
# # noflowcontrol
# # histexpiredupsfirst
# # histignorealldups
# # histignoredups
# # histignorespace
# # histverify
# # interactive
# # interactivecomments
# # login
# # longlistjobs
# # monitor
# # promptsubst
# # pushdignoredups
# # pushdminus
# # sharehistory
# # shinstdin
# # zle
