# Enable multiple streams: echo >file1 >file2
setopt multios

# Show long lint format job notifications
setopt long_list_jobs

# Recognize comments
setopt interactivecomments

# Pager options
export PAGER='less'
export LESS='-F -i -M -R -S -w -z-4'

# Language options
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Be very pedantic on word boundaries
export WORDCHARS=''
