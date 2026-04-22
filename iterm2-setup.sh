#!/usr/bin/env bash
# =============================================================================
# iTerm2 Minimal Developer Setup
#
# What this installs:
#   - iTerm2        — terminal emulator
#   - Starship      — minimal cross-shell prompt (Rust, fast, no framework)
#   - zsh plugins   — autosuggestions + syntax highlighting (standalone)
#   - fzf           — fuzzy finder for history, files, git
#   - bat           — better cat with syntax highlighting
#   - eza           — better ls with icons + git status
#   - zoxide        — smarter cd
#   - ripgrep       — fast grep
#   - fd            — fast find
#   - lazygit       — git TUI
#   - Catppuccin    — color scheme for iTerm2
#   - JetBrains Mono Nerd Font
# =============================================================================

set -e

# ── Colors ────────────────────────────────────────────────────────────────────
RESET="\033[0m"
BOLD="\033[1m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m"
RED="\033[0;31m"

log()     { echo -e "${CYAN}${BOLD}==> $1${RESET}"; }
success() { echo -e "${GREEN}✓ $1${RESET}"; }
warn()    { echo -e "${YELLOW}⚠ $1${RESET}"; }
error()   { echo -e "${RED}✗ $1${RESET}"; exit 1; }

[[ "$OSTYPE" != "darwin"* ]] && error "This script is macOS only."

echo ""
echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${CYAN}${BOLD}  iTerm2 Minimal Dev Setup${RESET}"
echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

# ── 1. Homebrew ───────────────────────────────────────────────────────────────
log "Checking Homebrew..."
if ! command -v brew &>/dev/null; then
  log "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  [[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
  success "Homebrew installed"
else
  success "Homebrew found — updating..."
  brew update && brew upgrade
  success "Homebrew updated"
fi

# ── 2. iTerm2 ─────────────────────────────────────────────────────────────────
ITERM2_INSTALLED=false
log "Checking iTerm2..."
if brew list --cask iterm2 &>/dev/null || [[ -d "/Applications/iTerm.app" ]]; then
  success "iTerm2 already installed"
  ITERM2_INSTALLED=true
else
  log "Installing iTerm2..."
  brew install --cask iterm2
  success "iTerm2 installed"
fi

# ── 3. CLI tools ──────────────────────────────────────────────────────────────
log "Installing CLI tools..."
TOOLS=(starship fzf bat eza zoxide ripgrep fd lazygit)
for tool in "${TOOLS[@]}"; do
  if brew list "$tool" &>/dev/null; then
    success "$tool already installed"
  else
    brew install "$tool"
    success "$tool installed"
  fi
done

# ── 4. fzf shell integration ──────────────────────────────────────────────────
log "Setting up fzf shell integration..."
if [[ -f "$HOME/.fzf.zsh" ]]; then
  success "fzf shell integration already configured"
else
  "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc
  success "fzf integration done"
fi

# ── 5. Standalone zsh plugins ──────────────────────────
ZSH_PLUGINS_DIR="$HOME/.zsh/plugins"
mkdir -p "$ZSH_PLUGINS_DIR"

log "Installing zsh-autosuggestions..."
if [[ -d "$ZSH_PLUGINS_DIR/zsh-autosuggestions" ]]; then
  success "zsh-autosuggestions already installed"
else
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_PLUGINS_DIR/zsh-autosuggestions"
  success "zsh-autosuggestions installed"
fi

log "Installing zsh-syntax-highlighting..."
if [[ -d "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" ]]; then
  success "zsh-syntax-highlighting already installed"
else
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting"
  success "zsh-syntax-highlighting installed"
fi

# ── 6. Font: JetBrains Mono Nerd Font ────────────────────────────────────────
log "Installing JetBrains Mono Nerd Font..."
if brew list --cask font-jetbrains-mono-nerd-font &>/dev/null; then
  success "JetBrains Mono Nerd Font already installed"
else
  brew tap homebrew/cask-fonts 2>/dev/null || true
  brew install --cask font-jetbrains-mono-nerd-font
  success "JetBrains Mono Nerd Font installed"
fi

# ── 7. Starship config ────────────────────────────────────────────────────────
log "Writing Starship config (~/.config/starship.toml)..."
mkdir -p "$HOME/.config"

STARSHIP_CONFIG="$HOME/.config/starship.toml"
if [[ -f "$STARSHIP_CONFIG" ]]; then
  cp "$STARSHIP_CONFIG" "${STARSHIP_CONFIG}.backup.$(date +%Y%m%d%H%M%S)"
  warn "Backed up existing starship.toml"
fi

cat > "$STARSHIP_CONFIG" << 'EOF'
# Starship — minimal dev prompt
# Docs: https://starship.rs/config/

add_newline = true
command_timeout = 1000

format = """
$directory$git_branch$git_status$nodejs$python$rust$golang$cmd_duration
$character"""

[character]
success_symbol = "[❯](bold green)"
error_symbol   = "[❯](bold red)"

[directory]
truncation_length = 3
truncate_to_repo  = true
style             = "bold cyan"

[git_branch]
format = "[ $branch](bold purple) "
symbol = " "

[git_status]
format    = "([$all_status$ahead_behind]($style) )"
style     = "bold yellow"
conflicted = "⚡"
ahead     = "⇡${count}"
behind    = "⇣${count}"
diverged  = "⇕⇡${ahead_count}⇣${behind_count}"
modified  = "✦${count}"
untracked = "?${count}"
staged    = "+${count}"
deleted   = "✘${count}"

[nodejs]
format = "[  $version](bold green) "
detect_files = ["package.json", ".nvmrc", ".node-version"]

[python]
format = "[ $version($virtualenv)](bold yellow) "

[rust]
format = "[ $version](bold red) "

[golang]
format = "[ $version](bold cyan) "

[cmd_duration]
min_time = 2000
format   = "[⏱ $duration](dimmed white) "

# Disable noisy modules
[package]
disabled = true

[aws]
disabled = true

[gcloud]
disabled = true

[azure]
disabled = true
EOF

success "Starship config written"

# ── 8. Catppuccin Macchiato color scheme ──────────────────────────────────────
THEME_FILE="$HOME/Downloads/catppuccin-macchiato.itermcolors"
log "Downloading Catppuccin Macchiato color scheme..."
if [[ -f "$THEME_FILE" ]]; then
  success "Color scheme already downloaded"
else
  curl -fsSL \
    "https://raw.githubusercontent.com/catppuccin/iterm/main/colors/catppuccin-macchiato.itermcolors" \
    -o "$THEME_FILE"
  success "Downloaded to ~/Downloads"
fi
open "$THEME_FILE" 2>/dev/null || warn "Could not auto-open — open it manually from ~/Downloads"

# ── 9. Write clean ~/.zshrc ───────────────────────────────────────────────────
ZSHRC="$HOME/.zshrc"
MARKER="# ── iterm2-minimal-setup additions ──"

# Backup
[[ -f "$ZSHRC" ]] && cp "$ZSHRC" "${ZSHRC}.backup.$(date +%Y%m%d%H%M%S)" && success "Backed up ~/.zshrc"

if grep -q "$MARKER" "$ZSHRC" 2>/dev/null; then
  warn "Setup block already in .zshrc — skipping to avoid duplicates"
else
  log "Patching ~/.zshrc..."
  cat >> "$ZSHRC" << 'EOF'

# ── iterm2-minimal-setup additions ────────────────────────────────────────────

# ── History ───────────────────────────────────────────────────────────────────
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY        # save timestamps
setopt HIST_IGNORE_DUPS        # no consecutive duplicates
setopt HIST_IGNORE_SPACE       # skip commands starting with space
setopt HIST_VERIFY             # confirm history expansion before running
setopt SHARE_HISTORY           # share history across sessions

# ── Navigation ────────────────────────────────────────────────────────────────
setopt AUTO_CD                 # type a dir name to cd into it
setopt AUTO_PUSHD              # push dirs onto stack automatically
setopt PUSHD_IGNORE_DUPS       # no duplicate dirs in stack

# ── Completion ────────────────────────────────────────────────────────────────
autoload -Uz compinit
compinit -d "$HOME/.zcompdump"
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # case-insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ── Plugins (standalone) ───────────────────────────────────────
source "$HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# ── fzf ───────────────────────────────────────────────────────────────────────
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
export FZF_DEFAULT_OPTS="--layout=reverse --border --height=40%"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range=:50 {}'"

# ── zoxide (smarter cd) ───────────────────────────────────────────────────────
eval "$(zoxide init zsh)"

# ── Aliases ───────────────────────────────────────────────────────────────────
alias ls='eza --icons'
alias ll='eza -la --icons --git'
alias la='eza -a --icons'
alias tree='eza --tree --icons --level=2'
alias cat='bat'
alias grep='rg'
alias find='fd'
alias lg='lazygit'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias reload='source ~/.zshrc'

# ── Starship prompt ───────────────────────────────────────────────────────────
eval "$(starship init zsh)"

# ─────────────────────────────────────────────────────────────────────────────
EOF
  success "~/.zshrc patched"
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN}${BOLD}  ✓ Done!${RESET}"
echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

if [[ "$ITERM2_INSTALLED" == false ]]; then
  echo -e "${YELLOW}${BOLD}iTerm2 was just installed.${RESET}"
  echo -e "  You're currently in $(basename "$SHELL") in your old terminal."
  echo -e "  ${BOLD}Open iTerm2 now${RESET} to continue with the steps below."
  echo ""
fi

echo -e "${BOLD}3 manual steps in iTerm2:${RESET}"
echo ""
echo -e "  1. ${CYAN}Preferences → Profiles → Colors → Color Presets${RESET}"
echo -e "     → select ${BOLD}Catppuccin Macchiato${RESET}"
echo ""
echo -e "  2. ${CYAN}Preferences → Profiles → Text → Font${RESET}"
echo -e "     → select ${BOLD}JetBrainsMono Nerd Font${RESET}, size 13"
echo ""
echo -e "  3. ${CYAN}Preferences → Profiles → Keys → Key Mappings → Presets${RESET}"
echo -e "     → select ${BOLD}Natural Text Editing${RESET}"
echo ""
echo -e "  Then reload: ${CYAN}source ~/.zshrc${RESET}"
echo ""
