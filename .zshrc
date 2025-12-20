#!/bin/zsh
# ============================================================================
# ZSH Configuration
# ============================================================================
# A clean and organized ZSH configuration with autocompletion
# ============================================================================

# ────────────────────────────────────────────────────────────────────────────
# 🎨 Colors & Prompt
# ────────────────────────────────────────────────────────────────────────────
export CLICOLOR=1
autoload -U colors && colors

# LS Colors - Colorful file listings (optimized for development)
export LS_COLORS='di=1;34:ln=1;36:so=1;35:pi=33:ex=1;32:bd=1;33;40:cd=1;33;40:su=37;41:sg=30;43:tw=30;42:ow=34;42:*.dart=1;95:*.java=1;33:*.kt=1;35:*.kts=1;35:*.gradle=1;32:*.xml=1;33:*.yaml=1;36:*.yml=1;36:*.json=1;33:*.js=1;93:*.ts=1;94:*.jsx=1;93:*.tsx=1;94:*.py=1;33:*.sh=1;32:*.bash=1;32:*.zsh=1;32:*.c=1;33:*.cpp=1;33:*.h=1;35:*.hpp=1;35:*.go=1;36:*.rs=1;91:*.rb=1;31:*.php=1;35:*.html=1;31:*.css=1;94:*.scss=1;35:*.md=1;37:*.txt=37:*.pdf=1;31:*.doc=1;31:*.docx=1;31:*.xls=1;32:*.xlsx=1;32:*.ppt=1;91:*.pptx=1;91:*.zip=1;91:*.tar=1;91:*.gz=1;91:*.bz2=1;91:*.7z=1;91:*.rar=1;91:*.png=1;95:*.jpg=1;95:*.jpeg=1;95:*.gif=1;95:*.svg=1;95:*.ico=1;95:*.webp=1;95:*.mp4=1;35:*.mkv=1;35:*.avi=1;35:*.mp3=1;36:*.flac=1;36:*.wav=1;36:*.lock=2;90:*.log=2;90:*.tmp=2;90:*.bak=2;90:*.swp=2;90:*.cache=2;90:*README=1;97:*README.md=1;97:*LICENSE=1;93:*Makefile=1;93:*Dockerfile=1;94:*.env=1;33:*.gitignore=2;90:*.dockerignore=2;90'

# Enable prompt substitution
setopt PROMPT_SUBST

# Git prompt function (simple, one-line)
git_prompt_info() {
  local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  if [[ -n "$branch" ]]; then
    echo " %{$fg[cyan]%}($branch)%{$reset_color%}"
  fi
}

# Custom prompt: [user@host ~/path (git-branch)]$
PS1='%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$(git_prompt_info)$%b '

# ────────────────────────────────────────────────────────────────────────────
# 📝 History Configuration
# ────────────────────────────────────────────────────────────────────────────
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history

# Create history directory if it doesn't exist
[[ ! -d ~/.cache/zsh ]] && mkdir -p ~/.cache/zsh

# ────────────────────────────────────────────────────────────────────────────
# 🔧 ZSH Options
# ────────────────────────────────────────────────────────────────────────────
setopt HIST_IGNORE_DUPS          # Don't record duplicate entries
setopt HIST_FIND_NO_DUPS         # Don't display duplicates when searching
setopt HIST_REDUCE_BLANKS        # Remove unnecessary blanks
setopt SHARE_HISTORY             # Share history between sessions
setopt AUTO_CD                   # Auto cd when typing directory name
setopt CORRECT                   # Command correction

# ────────────────────────────────────────────────────────────────────────────
# 📂 CDPATH - CD von überall aus
# ────────────────────────────────────────────────────────────────────────────
# Fügt Suchpfade für cd hinzu - du kannst von überall "cd Downloads" machen
export CDPATH=".:~:~/Downloads:~/Documents:~/development:~/git"

# ────────────────────────────────────────────────────────────────────────────
# ⚡ Completion System (Optimized with smart caching)
# ────────────────────────────────────────────────────────────────────────────
autoload -Uz compinit

# Smart compinit: only regenerate cache once per day
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# Enable completion caching
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zsh/completion

# Better completion menu
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # Case insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"    # Colored completion
zstyle ':completion:*' group-name ''                       # Group results
zstyle ':completion:*:descriptions' format '%B%d%b'        # Format group names

# Fix duplicate completions caused by CDPATH
zstyle ':completion:*' ignore-parents parent pwd directory
zstyle ':completion:*:cd:*' tag-order local-directories path-directories
zstyle ':completion:*:complete:(cd|pushd):*' tag-order 'local-directories named-directories'

# Arrow key driven interface
zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

# ────────────────────────────────────────────────────────────────────────────
# 🛠️  Editor
# ────────────────────────────────────────────────────────────────────────────
export EDITOR='nvim'
export VISUAL='nvim'

# ────────────────────────────────────────────────────────────────────────────
# 📦 Function Path
# ────────────────────────────────────────────────────────────────────────────
fpath+=${ZDOTDIR:-~}/.zsh_functions

# ────────────────────────────────────────────────────────────────────────────
# 🌐 NVM (Node Version Manager) - Lazy Loaded for fast startup
# ────────────────────────────────────────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"

# Lazy load NVM - nur laden wenn gebraucht (spart ~200ms beim Start!)
nvm() {
  unset -f nvm node npm npx
  [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
  [[ -s "$NVM_DIR/bash_completion" ]] && \. "$NVM_DIR/bash_completion"
  nvm "$@"
}

node() {
  unset -f nvm node npm npx
  [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
  [[ -s "$NVM_DIR/bash_completion" ]] && \. "$NVM_DIR/bash_completion"
  node "$@"
}

npm() {
  unset -f nvm node npm npx
  [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
  [[ -s "$NVM_DIR/bash_completion" ]] && \. "$NVM_DIR/bash_completion"
  npm "$@"
}

npx() {
  unset -f nvm node npm npx
  [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
  [[ -s "$NVM_DIR/bash_completion" ]] && \. "$NVM_DIR/bash_completion"
  npx "$@"
}

# ────────────────────────────────────────────────────────────────────────────
# 🛤️  PATH Configuration
# ────────────────────────────────────────────────────────────────────────────
# Load PATH from separate file for better organization
[[ -f ~/.zshpath ]] && source ~/.zshpath

# ────────────────────────────────────────────────────────────────────────────
# 🎯 Local Environment
# ────────────────────────────────────────────────────────────────────────────
[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

# ────────────────────────────────────────────────────────────────────────────
# 🎁 Aliases
# ────────────────────────────────────────────────────────────────────────────
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias grep='grep --color=auto'
alias cat='batcat'  # Syntax highlighting for files (use bat if installed as 'bat')
alias ..='cd ..'
alias ...='cd ../..'
#alias yt-dlp='yt-dlp -f bestvideo+bestaudio --merge-output-format mkv'
# ────────────────────────────────────────────────────────────────────────────
# 📚 Directory Bookmarks
# ────────────────────────────────────────────────────────────────────────────
# Usage: bookmark name -> saves current dir
#        goto name     -> jumps to saved dir
if [[ ! -f ~/.zsh_bookmarks ]]; then
  touch ~/.zsh_bookmarks
fi

function bookmark() {
  [[ -z "$1" ]] && echo "Usage: bookmark <name>" && return 1
  echo "export bookmark_$1='$PWD'" >> ~/.zsh_bookmarks
  source ~/.zsh_bookmarks
  echo "Bookmark '$1' saved: $PWD"
}

function goto() {
  [[ -z "$1" ]] && echo "Usage: goto <name>" && return 1
  [[ -f ~/.zsh_bookmarks ]] && source ~/.zsh_bookmarks
  local bookmark_var="bookmark_$1"
  local target="${(P)bookmark_var}"
  [[ -z "$target" ]] && echo "Bookmark '$1' not found" && return 1
  cd "$target"
}

function list_bookmarks() {
  [[ ! -s ~/.zsh_bookmarks ]] && echo "No bookmarks saved" && return
  echo "Saved bookmarks:"
  source ~/.zsh_bookmarks
  env | grep '^bookmark_' | sed 's/bookmark_/  /' | sed "s/=/ -> /"
}
alias bm='bookmark'
#alias go='goto'
alias bml='list_bookmarks'

# ────────────────────────────────────────────────────────────────────────────
# 🔔 Auto-Notify (for long running commands > 30 seconds)
# ────────────────────────────────────────────────────────────────────────────
export AUTO_NOTIFY_THRESHOLD=30
export AUTO_NOTIFY_EXPIRE_TIME=5000

function auto_notify_precmd() {
  if [[ -n "$AUTO_NOTIFY_START_TIME" ]]; then
    local elapsed=$((SECONDS - AUTO_NOTIFY_START_TIME))
    if (( elapsed > AUTO_NOTIFY_THRESHOLD )); then
      notify-send "Command finished" "Took ${elapsed}s: $AUTO_NOTIFY_COMMAND" 2>/dev/null
    fi
    unset AUTO_NOTIFY_START_TIME
    unset AUTO_NOTIFY_COMMAND
  fi
}

function auto_notify_preexec() {
  AUTO_NOTIFY_START_TIME=$SECONDS
  AUTO_NOTIFY_COMMAND="$1"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd auto_notify_precmd
add-zsh-hook preexec auto_notify_preexec

# ────────────────────────────────────────────────────────────────────────────
# 🌈 Colored Output for GCC and Make
# ────────────────────────────────────────────────────────────────────────────
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# ────────────────────────────────────────────────────────────────────────────
# 🎯 Syntax Highlighting (Feature 1)
# ────────────────────────────────────────────────────────────────────────────
if [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Custom syntax highlighting styles
ZSH_HIGHLIGHT_STYLES[command]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=blue,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=magenta,bold'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=green'
ZSH_HIGHLIGHT_STYLES[path]='fg=cyan,underline'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=yellow,bold'

# Highlight specific development commands
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
ZSH_HIGHLIGHT_PATTERNS+=('flutter' 'fg=blue,bold')
ZSH_HIGHLIGHT_PATTERNS+=('dart' 'fg=blue,bold')
ZSH_HIGHLIGHT_PATTERNS+=('npm' 'fg=red,bold')
ZSH_HIGHLIGHT_PATTERNS+=('npx' 'fg=red,bold')
ZSH_HIGHLIGHT_PATTERNS+=('gradle' 'fg=green,bold')
ZSH_HIGHLIGHT_PATTERNS+=('docker' 'fg=cyan,bold')
ZSH_HIGHLIGHT_PATTERNS+=('git' 'fg=magenta,bold')
ZSH_HIGHLIGHT_PATTERNS+=('python' 'fg=yellow,bold')
ZSH_HIGHLIGHT_PATTERNS+=('pip' 'fg=yellow,bold')

# ────────────────────────────────────────────────────────────────────────────
# 💡 Auto-Suggestions (Feature 2)
# ────────────────────────────────────────────────────────────────────────────
if [[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
# Accept suggestion with Ctrl+Space or End key
bindkey '^ ' autosuggest-accept
bindkey '^[[F' autosuggest-accept

# ────────────────────────────────────────────────────────────────────────────
# 🔍 FZF Integration (Feature 5)
# ────────────────────────────────────────────────────────────────────────────
if [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
  source /usr/share/doc/fzf/examples/completion.zsh
fi
# Ctrl+T: Find files, Ctrl+R: History search, Alt+C: CD to directory

# ────────────────────────────────────────────────────────────────────────────
# 🚀 Zoxide - Smarter CD (lernt deine häufigen Ordner)
# ────────────────────────────────────────────────────────────────────────────
if command -v zoxide &> /dev/null; then
  # Initialize zoxide with default 'z' command (not overriding cd)
  eval "$(zoxide init zsh)"

  # Create a safe cd wrapper that falls back to builtin cd
  function cd() {
    if (( ${+functions[__zoxide_z]} )); then
      __zoxide_z "$@"
    else
      builtin cd "$@"
    fi
  }
fi
# Usage: z chuk   -> springt zu ~/git/chuk_chat (smart jump)
#        zi       -> interaktive Auswahl mit fzf
#        cd       -> works like normal cd with zoxide tracking

# ────────────────────────────────────────────────────────────────────────────
# 🔌 Custom Configurations
# ────────────────────────────────────────────────────────────────────────────
# Add your custom configurations below this line


# opencode

export PATH=$PATH:/usr/local/go/bin
export PATH=/home/user/.opencode/bin:$PATH
export QT_QPA_PLATFORMTHEME=gnome
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export QT_AUTO_SCREEN_SCALE_FACTOR=1
export _JAVA_AWT_WM_NONREPARENTING=1

export PATH=$PATH:/home/user/.spicetify
