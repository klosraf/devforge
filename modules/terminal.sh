#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────
#  Module: terminal — DevForge macOS Setup v3.4
#  Terminales, fuentes, shell, Oh My Zsh, Powerlevel10k
#
#  CORRECCIONES v3.4:
#  - _install_zsh_plugins: eliminado local -A / ${(@k)} (zsh-only en bash)
#  - Stubs serve/fkill reemplazados por funciones reales
#  - Keybinding autosuggest-accept-suggested-small-word eliminado (no existe)
#  - xargs -r → compatible con BSD/macOS
#  - tar --zstd → fallback compatible con macOS
#  - pnpm completion: sintaxis corregida
#  - _install_ohmyzsh: export explícito de RUNZSH/CHSH
# ─────────────────────────────────────────────────────────────────

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

module_terminal() {
  ui_section "TERMINAL & SHELL" "◈"
  detect_system

  # ── Fuentes Nerd Font ────────────────────────────────────────
  ui_step "Instalando Nerd Fonts (verificadas en homebrew-cask-fonts)..."

  # NOTA: los nombres de fuentes se verificaron contra el catálogo 2025/2026
  # Ref: https://github.com/Homebrew/homebrew-cask-fonts
  local fonts=(
    "font-jetbrains-mono-nerd-font"       # JetBrainsMono (la más usada)
    "font-fira-code-nerd-font"            # Fira Code con ligaduras
    "font-cascadia-code-nerd-font"        # Cascadia Code (MS)
    "font-cascadia-mono-nerd-font"        # Cascadia Mono sin ligaduras
    "font-geist-mono-nerd-font"           # Geist Mono (Vercel)
    "font-monaspace-nerd-font"            # Monaspace (GitHub)
    "font-victor-mono-nerd-font"          # Victor Mono (cursiva)
    "font-iosevka-nerd-font"              # Iosevka (condensada)
    "font-iosevka-term-nerd-font"         # Iosevka Term
    "font-symbols-only-nerd-font"         # Solo iconos (complemento)
    "font-commit-mono-nerd-font"          # Commit Mono
    "font-hack-nerd-font"                 # Hack
    "font-source-code-pro-nerd-font"      # Source Code Pro (Adobe)
    "font-lilex-nerd-font"               # Lilex
    "font-meslo-lg-nerd-font"            # MesloLGS NF (requerida por Powerlevel10k)
    "font-recursive"                      # Recursive (variable font)
    "font-inter"                          # Inter (UI)
    "font-maple-mono-nerd-font"           # Maple Mono
  )

  local font_ok=0
  for font in "${fonts[@]}"; do
    if brew install --cask "${font}" >> "${LOG_FILE}" 2>&1; then
      ((font_ok++)) || true
    fi
  done
  track_ok "Fuentes Nerd Font (${font_ok}/${#fonts[@]})"

  # ── Ghostty ──────────────────────────────────────────────────
  ui_step "Ghostty (terminal principal)..."
  brew_cask_install "ghostty" "Ghostty"
  ensure_dir "${HOME}/.config/ghostty"
  _write_ghostty_config

  # ── WezTerm ──────────────────────────────────────────────────
  ui_step "WezTerm..."
  brew_cask_install "wezterm" "WezTerm"
  ensure_dir "${HOME}/.config/wezterm"
  _write_wezterm_config

  # ── iTerm2 ───────────────────────────────────────────────────
  ui_step "iTerm2..."
  brew_cask_install "iterm2" "iTerm2"

  # ── Warp ─────────────────────────────────────────────────────
  ui_step "Warp (terminal con AI integrada)..."
  brew_cask_install "warp" "Warp"

  # ── tmux ─────────────────────────────────────────────────────
  ui_step "tmux + TPM..."
  brew_install "tmux" "tmux"

  # TPM (Tmux Plugin Manager)
  local tpm_dir="${HOME}/.tmux/plugins/tpm"
  if [[ ! -d "${tpm_dir}" ]]; then
    git clone --depth=1 https://github.com/tmux-plugins/tpm "${tpm_dir}" \
      >> "${LOG_FILE}" 2>&1 && track_ok "TPM" || track_fail "TPM"
  else
    track_skip "TPM (ya instalado)"
  fi
  _write_tmux_config

  # ── Zellij ───────────────────────────────────────────────────
  ui_step "Zellij (multiplexor moderno)..."
  brew_install "zellij" "Zellij"
  ensure_dir "${HOME}/.config/zellij"
  _write_zellij_config

  # ── Starship ─────────────────────────────────────────────────
  ui_step "Starship (prompt cross-shell)..."
  brew_install "starship" "Starship"
  ensure_dir "${HOME}/.config"
  _write_starship_config

  # ── Atuin (historial de shell en SQLite) ──────────────────────
  ui_step "Atuin (historial de shell encriptado)..."
  brew_install "atuin" "Atuin"

  # ── Oh My Zsh ─────────────────────────────────────────────────
  ui_step "Oh My Zsh..."
  _install_ohmyzsh

  # ── Powerlevel10k ─────────────────────────────────────────────
  ui_step "Powerlevel10k (tema principal)..."
  _install_powerlevel10k

  # ── Plugins Zsh ───────────────────────────────────────────────
  ui_step "Plugins Zsh (autosuggestions, syntax, completions...)..."
  _install_zsh_plugins

  # ── Shell: .zshrc, aliases, functions, p10k ───────────────────
  ui_step "Configurando .zshrc, aliases, funciones, completions y p10k..."
  _write_zshrc
  _write_zsh_aliases
  _write_zsh_functions
  _write_zsh_completions
  _write_p10k_config

  ui_success "Terminal & shell configurados ✓"
}

# ════════════════════════════════════════════════════════════════
#  GHOSTTY CONFIG
# ════════════════════════════════════════════════════════════════
_write_ghostty_config() {
  cat > "${HOME}/.config/ghostty/config" << 'GHOSTTY'
# DevForge — Ghostty Config (Catppuccin Macchiato)
theme = catppuccin-macchiato
font-family = "JetBrainsMono Nerd Font"
font-size = 14
font-feature = calt
font-feature = liga
background-opacity = 0.92
background-blur-radius = 20
cursor-style = bar
cursor-blink = true
copy-on-select = clipboard
scrollback-limit = 10000
shell-integration = zsh
window-decoration = true
macos-titlebar-style = hidden
macos-option-as-alt = true
keybind = super+shift+enter=new_split:right
keybind = super+enter=new_split:down
keybind = super+d=close_surface
GHOSTTY
  track_ok "Ghostty config"
}

# ════════════════════════════════════════════════════════════════
#  WEZTERM CONFIG
# ════════════════════════════════════════════════════════════════
_write_wezterm_config() {
  cat > "${HOME}/.config/wezterm/wezterm.lua" << 'WEZTERM'
-- DevForge — WezTerm Config (Catppuccin Macchiato)
local wezterm = require 'wezterm'
local config  = wezterm.config_builder()

config.color_scheme = 'Catppuccin Macchiato'
config.font = wezterm.font('JetBrainsMono Nerd Font', { weight='Regular' })
config.font_size = 14.0
config.line_height = 1.1
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity = 0.92
config.macos_window_background_blur = 20
config.window_decorations = 'RESIZE'
config.initial_cols = 220
config.initial_rows = 50
config.scrollback_lines = 10000
config.cursor_blink_rate = 500
config.default_cursor_style = 'BlinkingBar'
config.audible_bell = 'Disabled'
config.window_padding = { left=8, right=8, top=8, bottom=4 }

-- Keys
config.keys = {
  { key='\\', mods='CMD', action=wezterm.action.SplitHorizontal{ domain='CurrentPaneDomain' } },
  { key='-',  mods='CMD', action=wezterm.action.SplitVertical{ domain='CurrentPaneDomain' } },
  { key='h',  mods='CMD|OPT', action=wezterm.action.ActivatePaneDirection 'Left' },
  { key='l',  mods='CMD|OPT', action=wezterm.action.ActivatePaneDirection 'Right' },
  { key='k',  mods='CMD|OPT', action=wezterm.action.ActivatePaneDirection 'Up' },
  { key='j',  mods='CMD|OPT', action=wezterm.action.ActivatePaneDirection 'Down' },
}
return config
WEZTERM
  track_ok "WezTerm config"
}

# ════════════════════════════════════════════════════════════════
#  TMUX CONFIG
# ════════════════════════════════════════════════════════════════
_write_tmux_config() {
  cat > "${HOME}/.tmux.conf" << 'TMUX'
# DevForge — tmux Config (Catppuccin Macchiato)

# ── Prefix ────────────────────────────────────────────────────
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# ── General ───────────────────────────────────────────────────
set -g default-terminal "tmux-256color"
set -as terminal-overrides ',xterm*:Tc'
set -g mouse on
set -g history-limit 50000
set -sg escape-time 0
set -g focus-events on
set -g status-interval 5
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -g set-clipboard on

# ── Splits ────────────────────────────────────────────────────
bind | split-window -h -c '#{pane_current_path}'
bind - split-window -v -c '#{pane_current_path}'
unbind '"'; unbind '%'

# ── Navigation (vim-style) ─────────────────────────────────────
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Resize panes
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

# ── Windows ───────────────────────────────────────────────────
bind c new-window -c '#{pane_current_path}'
bind Tab last-window
bind n next-window
bind p previous-window

# ── Copy mode ─────────────────────────────────────────────────
setw -g mode-keys vi
bind [ copy-mode
bind -T copy-mode-vi v send-keys -X begin-selection
bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"
bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"

# ── Reload ────────────────────────────────────────────────────
bind r source-file ~/.tmux.conf \; display "Config recargado ✓"

# ── Status bar (Catppuccin Macchiato) ─────────────────────────
set -g status on
set -g status-position bottom
set -g status-left-length 60
set -g status-right-length 80

# Colores Catppuccin Macchiato
CRUST="#181926"
MANTLE="#1e2030"
BASE="#24273a"
SURFACE0="#363a4f"
OVERLAY1="#8087a2"
TEXT="#cad3f5"
MAUVE="#c6a0f6"
PINK="#f5bde6"
GREEN="#a6da95"
YELLOW="#eed49f"
BLUE="#8aadf4"
RED="#ed8796"

set -g status-style "bg=${BASE},fg=${TEXT}"
set -g status-left  "#[bg=${MAUVE},fg=${BASE},bold] 󰤋 #S #[bg=${BASE},fg=${MAUVE}]"
set -g status-right "#[fg=${OVERLAY1}] %d/%m %H:%M #[fg=${BLUE}]#{battery_percentage} #[fg=${GREEN}]#{cpu_percentage} CPU "
setw -g window-status-format         "#[fg=${OVERLAY1}] #I:#W "
setw -g window-status-current-format "#[bg=${SURFACE0},fg=${BLUE},bold] #I:#W#{?window_zoomed_flag, 󰊓,} "
set -g pane-border-style        "fg=${SURFACE0}"
set -g pane-active-border-style "fg=${MAUVE}"
set -g message-style            "bg=${SURFACE0},fg=${TEXT}"

# ── Plugins (TPM) ─────────────────────────────────────────────
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'tmux-plugins/tmux-pain-control'
set -g @plugin 'christoomey/vim-tmux-navigator'
set -g @plugin 'tmux-plugins/tmux-cpu'
set -g @plugin 'tmux-plugins/tmux-battery'
set -g @plugin 'tmux-plugins/tmux-prefix-highlight'

set -g @resurrect-capture-pane-contents 'on'
set -g @continuum-restore 'on'
set -g @continuum-save-interval '15'

# Initialize TPM (debe ser la última línea)
run '~/.tmux/plugins/tpm/tpm'
TMUX
  track_ok "tmux config"
}

# ════════════════════════════════════════════════════════════════
#  ZELLIJ CONFIG
# ════════════════════════════════════════════════════════════════
_write_zellij_config() {
  cat > "${HOME}/.config/zellij/config.kdl" << 'ZELLIJ'
// DevForge — Zellij Config
theme "catppuccin-macchiato"
default_layout "compact"
mouse_mode true
pane_frames true
scroll_buffer_size 50000
copy_on_select true
copy_clipboard "system"

keybinds clear-defaults=true {
    normal {
        bind "Ctrl a" { SwitchToMode "tmux"; }
    }
    tmux {
        bind "Ctrl a" { Write 2; SwitchToMode "normal"; }
        bind "\"" { NewPane "Down"; SwitchToMode "normal"; }
        bind "%" { NewPane "Right"; SwitchToMode "normal"; }
        bind "h" { MoveFocus "Left"; SwitchToMode "normal"; }
        bind "j" { MoveFocus "Down"; SwitchToMode "normal"; }
        bind "k" { MoveFocus "Up"; SwitchToMode "normal"; }
        bind "l" { MoveFocus "Right"; SwitchToMode "normal"; }
        bind "n" { GoToNextTab; SwitchToMode "normal"; }
        bind "p" { GoToPreviousTab; SwitchToMode "normal"; }
        bind "c" { NewTab; SwitchToMode "normal"; }
        bind "d" { Detach; }
        bind "z" { ToggleFocusFullscreen; SwitchToMode "normal"; }
    }
    shared_except "locked" {
        bind "Alt h" { MoveFocusOrTab "Left"; }
        bind "Alt l" { MoveFocusOrTab "Right"; }
        bind "Alt j" { MoveFocus "Down"; }
        bind "Alt k" { MoveFocus "Up"; }
        bind "Alt +" { Resize "Increase"; }
        bind "Alt -" { Resize "Decrease"; }
    }
}
ZELLIJ
  track_ok "Zellij config"
}

# ════════════════════════════════════════════════════════════════
#  STARSHIP CONFIG
# ════════════════════════════════════════════════════════════════
_write_starship_config() {
  cat > "${HOME}/.config/starship.toml" << 'STARSHIP'
# DevForge — Starship (Catppuccin Macchiato)
"$schema" = 'https://starship.rs/config-schema.json'
format = """
$os$username$hostname$directory$git_branch$git_status$git_metrics\
$python$node$rust$golang$java$ruby$kotlin$dart$elixir$zig\
$docker_context$kubernetes$terraform$aws\
$cmd_duration$line_break$character"""
add_newline = true

[os]
disabled = false
style = "bold fg:#cad3f5"
[os.symbols]
Macos = "󰀵 "

[username]
show_always = false
format = "[$user]($style) "
style_user = "bold fg:#8aadf4"
style_root = "bold fg:#ed8796"

[hostname]
ssh_only = true
format = "@[$hostname]($style) "
style = "fg:#a6da95"

[directory]
format = "[$path]($style)[$read_only]($read_only_style) "
style = "bold fg:#8aadf4"
read_only = " 󰌾"
truncation_length = 4
truncate_to_repo = true
home_symbol = "~"

[git_branch]
format = "[$symbol$branch(:$remote_branch)]($style) "
symbol = " "
style = "bold fg:#c6a0f6"

[git_status]
format = "([$all_status$ahead_behind]($style)) "
style = "fg:#eed49f"
conflicted = "⚡"
ahead = "⇡${count}"
behind = "⇣${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
untracked = "?${count}"
stashed = "󰏗 "
modified = "!${count}"
staged = "+${count}"
renamed = "»${count}"
deleted = "✘${count}"

[git_metrics]
added_style = "fg:#a6da95"
deleted_style = "fg:#ed8796"
format = "([+$added]($added_style) )([-$deleted]($deleted_style) )"
disabled = false

[python]
format = "[$symbol$version]($style) "
symbol = "󰌠 "
style = "fg:#eed49f"
detect_extensions = ["py"]
python_binary = ["python3", "python"]

[nodejs]
format = "[$symbol$version]($style) "
symbol = " "
style = "fg:#a6da95"

[rust]
format = "[$symbol$version]($style) "
symbol = "󱘗 "
style = "fg:#ed8796"

[golang]
format = "[$symbol$version]($style) "
symbol = " "
style = "fg:#89dceb"

[java]
format = "[$symbol$version]($style) "
symbol = " "
style = "fg:#f38ba8"

[ruby]
format = "[$symbol$version]($style) "
symbol = "󰴭 "
style = "fg:#ed8796"

[kotlin]
format = "[$symbol$version]($style) "
symbol = "󱈙 "
style = "fg:#c6a0f6"

[dart]
format = "[$symbol$version]($style) "
symbol = " "
style = "fg:#89dceb"

[elixir]
format = "[$symbol$version]($style) "
symbol = " "
style = "fg:#c6a0f6"

[zig]
format = "[$symbol$version]($style) "
symbol = " "
style = "fg:#eed49f"

[docker_context]
format = "[$symbol$context]($style) "
symbol = " "
style = "fg:#89dceb"
only_with_files = true

[kubernetes]
format = "[$symbol$context( \\($namespace\\))]($style) "
symbol = "󱃾 "
style = "fg:#8aadf4"
disabled = false

[terraform]
format = "[$symbol$workspace]($style) "
symbol = "󱁢 "
style = "fg:#c6a0f6"

[aws]
format = "[$symbol$profile(/$region)]($style) "
symbol = "󰸏 "
style = "fg:#eed49f"

[cmd_duration]
format = "[$duration]($style) "
style = "fg:#6e738d"
min_time = 2000

[character]
success_symbol = "[❯](bold fg:#a6da95)"
error_symbol   = "[❯](bold fg:#ed8796)"
vimcmd_symbol  = "[❮](bold fg:#c6a0f6)"

[line_break]
disabled = false
STARSHIP
  track_ok "Starship config"
}

# ════════════════════════════════════════════════════════════════
#  .ZSHRC
# ════════════════════════════════════════════════════════════════
_write_zshrc() {
  # Hacer backup si existe
  [[ -f "${HOME}/.zshrc" && ! -f "${HOME}/.zshrc.bak" ]] && \
    cp "${HOME}/.zshrc" "${HOME}/.zshrc.bak" 2>/dev/null || true

  cat > "${HOME}/.zshrc" << 'ZSHRC'
# DevForge .zshrc — Catppuccin Macchiato + Powerlevel10k

# ── Powerlevel10k instant prompt (DEBE ser lo primero) ────────
# Habilita el prompt instantáneo para una carga más rápida.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ── PATH ──────────────────────────────────────────────────────
export PATH="${HOME}/.local/bin:${PATH}"
export PATH="${HOME}/.cargo/bin:${PATH}"
export PATH="${HOME}/go/bin:${PATH}"
export PATH="${HOME}/.devforge/bin:${PATH}"

# Homebrew
if [[ -f /opt/homebrew/bin/brew ]]; then          # Apple Silicon
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then            # Intel
  eval "$(/usr/local/bin/brew shellenv)"
fi

# ── Oh My Zsh ─────────────────────────────────────────────────
export ZSH="${HOME}/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  gitfast
  brew
  npm
  node
  python
  pip
  rust
  golang
  docker
  kubectl
  terraform
  aws
  macos
  sudo
  z
  colored-man-pages
  command-not-found
  copypath
  copyfile
  dirhistory
  extract
  history
  web-search
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  zsh-history-substring-search
  you-should-use
  fzf-tab
  zsh-autopair
)

source "${ZSH}/oh-my-zsh.sh" 2>/dev/null || true

# ── Completions ───────────────────────────────────────────────
# Regenerar dump solo si tiene más de 24h (acelera el arranque)
autoload -Uz compinit
if [[ -n "${HOME}/.zcompdump"(#qNmh+24) ]]; then
  compinit
else
  compinit -C
fi
# Activar cache de completions
mkdir -p "${HOME}/.zsh/cache"
zstyle ':completion:*'              use-cache        on
zstyle ':completion:*'              cache-path       "${HOME}/.zsh/cache"
# Menú interactivo de selección (Tab navega, Enter confirma)
zstyle ':completion:*'              menu             select
# Case-insensitive + partial-match + substrings
zstyle ':completion:*'              matcher-list     \
  'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
# Colorear las entradas del menú con LS_COLORS
zstyle ':completion:*'              list-colors      "${(s.:.)LS_COLORS}"
# Mostrar descripciones de grupos con colores
zstyle ':completion:*'              verbose          yes
zstyle ':completion:*:descriptions' format           '%F{yellow}[ %d ]%f'
zstyle ':completion:*:messages'     format           '%F{purple} %d %f'
zstyle ':completion:*:warnings'     format           '%F{red}sin resultados para: %d%f'
zstyle ':completion:*:corrections'  format           '%F{green}%d (errores: %e)%f'
# Agrupar por categoría
zstyle ':completion:*'              group-name       ''
# Completar . y .. como directorios
zstyle ':completion:*'              special-dirs     true
# Completar procesos para kill
zstyle ':completion:*:*:kill:*'     menu             yes select
zstyle ':completion:*:kill:*'       force-list       always
zstyle ':completion:*:processes'    command          'ps -u $USER -o pid,user,comm -w'
# Completar sudo con los comandos del PATH raíz
zstyle ':completion::complete:*'    gain-privileges  1
# Completar flags de git
zstyle ':completion:*:git-*'        use-fallback     false
# Ignorar duplicados en la lista
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' stop            yes

# ── Aliases, funciones y completions extra ────────────────────
[[ -f "${HOME}/.zsh_aliases" ]]      && source "${HOME}/.zsh_aliases"
[[ -f "${HOME}/.zsh_functions" ]]    && source "${HOME}/.zsh_functions"
[[ -f "${HOME}/.zsh_completions" ]]  && source "${HOME}/.zsh_completions"

# ── Herramientas modernas ──────────────────────────────────────
# Starship prompt (desactivado: Powerlevel10k es el tema principal)
# Descomenta la siguiente línea si prefieres Starship en lugar de p10k:
# command -v starship &>/dev/null && eval "$(starship init zsh)"

# Zoxide (smarter cd)
command -v zoxide &>/dev/null && eval "$(zoxide init zsh --cmd cd)"

# Atuin (historial encriptado)
command -v atuin &>/dev/null && eval "$(atuin init zsh)"

# direnv (variables por directorio)
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"

# thefuck (corrector de comandos)
command -v thefuck &>/dev/null && eval "$(thefuck --alias 2>/dev/null)"

# mise (gestor de versiones universal)
command -v mise &>/dev/null && eval "$(mise activate zsh)"

# pyenv
if command -v pyenv &>/dev/null; then
  export PYENV_ROOT="${HOME}/.pyenv"
  export PATH="${PYENV_ROOT}/bin:${PATH}"
  eval "$(pyenv init -)"
fi

# rbenv
command -v rbenv &>/dev/null && eval "$(rbenv init - zsh)"

# nvm
export NVM_DIR="${HOME}/.nvm"
[[ -s "${NVM_DIR}/nvm.sh" ]] && source "${NVM_DIR}/nvm.sh" --no-use 2>/dev/null

# cargo
[[ -f "${HOME}/.cargo/env" ]] && source "${HOME}/.cargo/env"

# bun
export BUN_INSTALL="${HOME}/.bun"
[[ -d "${BUN_INSTALL}/bin" ]] && export PATH="${BUN_INSTALL}/bin:${PATH}"

# deno
export DENO_INSTALL="${HOME}/.deno"
[[ -d "${DENO_INSTALL}/bin" ]] && export PATH="${DENO_INSTALL}/bin:${PATH}"

# Go
export GOPATH="${HOME}/go"
export GOBIN="${GOPATH}/bin"
[[ -d "${GOBIN}" ]] && export PATH="${GOBIN}:${PATH}"

# Java
[[ -d /opt/homebrew/opt/openjdk@21 ]] && \
  export JAVA_HOME="/opt/homebrew/opt/openjdk@21"
[[ -d /usr/local/opt/openjdk@21 ]] && \
  export JAVA_HOME="/usr/local/opt/openjdk@21"
[[ -n "${JAVA_HOME}" ]] && export PATH="${JAVA_HOME}/bin:${PATH}"

# Flutter / Dart
# FVM (Flutter Version Manager) — ruta principal
[[ -d "${HOME}/fvm/default/bin"          ]] && export PATH="${HOME}/fvm/default/bin:${PATH}"
[[ -d "${HOME}/.fvm/default/bin"         ]] && export PATH="${HOME}/.fvm/default/bin:${PATH}"
# Flutter instalación directa (git clone fallback)
[[ -d "${HOME}/development/flutter/bin"  ]] && export PATH="${HOME}/development/flutter/bin:${PATH}"
[[ -d "${HOME}/flutter/bin"              ]] && export PATH="${HOME}/flutter/bin:${PATH}"

# pipx
export PATH="${HOME}/.local/bin:${PATH}"

# ── fzf ───────────────────────────────────────────────────────
if command -v fzf &>/dev/null; then
  source <(fzf --zsh 2>/dev/null) 2>/dev/null || true
  # Colores Catppuccin Macchiato
  export FZF_DEFAULT_OPTS="
    --color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796
    --color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6
    --color=marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796
    --border=rounded --prompt='  ' --marker='❯' --pointer='◆'
    --layout=reverse --height=50%"
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# ── bat como pager ────────────────────────────────────────────
command -v bat &>/dev/null && export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# ── Variables de entorno globales ─────────────────────────────
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export LESS="-R --quit-if-one-screen"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export TERM="xterm-256color"
export COLORTERM="truecolor"
export HISTSIZE=100000
export SAVEHIST=100000
export HISTFILE="${HOME}/.zsh_history"

# Zsh options
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt CORRECT
setopt NO_BEEP
setopt INTERACTIVE_COMMENTS

# ── Keybindings ───────────────────────────────────────────────
bindkey '^[[A'    history-substring-search-up      # ↑ buscar en historial
bindkey '^[[B'    history-substring-search-down    # ↓ buscar en historial
bindkey '^[[1;5C' forward-word                     # Ctrl+→ avanza palabra
bindkey '^[[1;5D' backward-word                    # Ctrl+← retrocede palabra
bindkey '^[f'     forward-word                     # Alt+f avanza palabra
bindkey '^[b'     backward-word                    # Alt+b retrocede palabra
bindkey '^ '      autosuggest-accept               # Ctrl+Space acepta sugerencia completa
bindkey '^E'      autosuggest-accept               # Ctrl+E    acepta sugerencia completa
bindkey '^[l'     forward-word                     # Alt+l     acepta una palabra
bindkey '^[[Z'    reverse-menu-complete            # Shift+Tab cicla hacia atrás

# ── Autosuggestions ───────────────────────────────────────────
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#6e738d,underline"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)  # historial primero, luego completions
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20             # no sugerir en comandos largos
ZSH_AUTOSUGGEST_USE_ASYNC=true                 # no bloquea mientras escribe
ZSH_AUTOSUGGEST_MANUAL_REBIND=true             # evita relink innecesario en cada prompt
ZSH_AUTOSUGGEST_HISTORY_IGNORE="cd *|ls *|ll *|la *|rm *|mv *|cp *"

# ── fzf-tab ─────────────────────────────────────────────────
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:*:*:*' query current
zstyle ':fzf-tab:default' fzf-command fzf
zstyle ':fzf-tab:*' color 'bg+:#363a4f,bg:#24273a,fg:#cad3f5,pointer:#f4dbd6,marker:#f4dbd6,hl:#ed8796,hl+:#c6a0f6'

# ── bashcompinit ────────────────────────────────────────────
# Cargar compatibilidad con completions de bash
autoload -U +X bashcompinit && bashcompinit

# ── zsh-autopair ───────────────────────────────────────────
# Auto-cerrar paréntesis, corchetes, llaves y comillas
autopair-init

# ── Syntax Highlighting — Paleta Catppuccin Macchiato ──────────
# Debe estar configurado DESPUÉS de cargar oh-my-zsh
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)

# Tokens principales
ZSH_HIGHLIGHT_STYLES[default]='none'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#ed8796,bold'          # rojo — error
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#c6a0f6'               # mauve — keywords
ZSH_HIGHLIGHT_STYLES[alias]='fg=#a6da95'                       # verde — alias
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#a6da95'
ZSH_HIGHLIGHT_STYLES[global-alias]='fg=#a6da95,italic'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#8aadf4'                     # azul — builtins
ZSH_HIGHLIGHT_STYLES[function]='fg=#8aadf4'                    # azul — funciones
ZSH_HIGHLIGHT_STYLES[command]='fg=#a6da95'                     # verde — comandos
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#a6da95,italic'           # verde itálica — sudo etc.
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#c6a0f6'            # mauve — ; | &&
ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=#eed49f,italic'        # amarillo — dir solo
ZSH_HIGHLIGHT_STYLES[path]='fg=#cad3f5,underline'              # texto — paths
ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=#8aadf4'          # azul — /
ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]='fg=#8aadf4'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#f4dbd6'                    # rosewater — * ? []
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#c6a0f6'           # mauve — !!
# Opciones y argumentos
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#eed49f'        # amarillo — -f
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#eed49f'        # amarillo — --flag
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#c6a0f6'        # mauve — `cmd`
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#a6da95'      # verde — 'str'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#a6da95'      # verde — "str"
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#eed49f'      # amarillo — $'str'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#eed49f'  # amarillo — $var en ""
ZSH_HIGHLIGHT_STYLES[assign]='fg=#cad3f5'                      # texto — VAR=val
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#f5bde6'                 # pink — > >> |
ZSH_HIGHLIGHT_STYLES[comment]='fg=#6e738d,italic'              # gris — # comentarios
ZSH_HIGHLIGHT_STYLES[named-fd]='none'
ZSH_HIGHLIGHT_STYLES[numeric-fd]='none'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=#a6da95'

# Brackets (colores por nivel de anidación)
ZSH_HIGHLIGHT_STYLES[bracket-error]='fg=#ed8796,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-1]='fg=#8aadf4,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-2]='fg=#a6da95,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-3]='fg=#c6a0f6,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-4]='fg=#eed49f,bold'
ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]='standout'

# ── Powerlevel10k ─────────────────────────────────────────────
# Para reconfigurar el prompt, ejecuta: p10k configure
[[ -f "${HOME}/.p10k.zsh" ]] && source "${HOME}/.p10k.zsh"
ZSHRC
  track_ok ".zshrc escrito"
}

# ════════════════════════════════════════════════════════════════
#  ALIASES
# ════════════════════════════════════════════════════════════════
_write_zsh_aliases() {
  cat > "${HOME}/.zsh_aliases" << 'ALIASES'
# DevForge — Aliases

# ── Reemplazos modernos ───────────────────────────────────────
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first --git'
alias lt='eza -la --tree --level=2 --icons --git'
alias lta='eza -la --tree --level=3 --icons --git'
alias cat='bat --paging=never'
alias less='bat --paging=always'
alias grep='rg'
alias find='fd'
alias du='dust'
alias df='duf'
alias top='btop'
alias ps='procs'
alias sed='sd'
alias cd='z'   # zoxide
alias j='z'    # jump con zoxide

# ── Git ───────────────────────────────────────────────────────
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gaa='git add -A'
alias gc='git commit -m'
alias gca='git commit --amend'
alias gcan='git commit --amend --no-edit'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gl='git pull'
alias glo='git log --oneline --graph --decorate'
alias glg='git log --color --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'
alias gd='git diff'
alias gds='git diff --staged'
alias gb='git branch -vv'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gst='git stash'
alias gstp='git stash pop'
alias gstl='git stash list'
alias grb='git rebase'
alias grbi='git rebase -i'
alias gundo='git reset --soft HEAD~1'
alias gunstage='git restore --staged'
alias lg='lazygit'

# ── npm / pnpm / bun ─────────────────────────────────────────
alias ni='pnpm install'
alias na='pnpm add'
alias nrm='pnpm remove'
alias nr='pnpm run'
alias nd='pnpm run dev'
alias nb='pnpm run build'
alias nt='pnpm run test'
alias nls='pnpm list --depth=0'

# ── Python ────────────────────────────────────────────────────
alias py='python3'
alias pip='pip3'
alias ipy='ipython'
alias venv='python3 -m venv .venv && source .venv/bin/activate'
alias activate='source .venv/bin/activate'
alias uvr='uv run'

# ── Docker ────────────────────────────────────────────────────
alias d='docker'
alias dc='docker compose'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dpsa='docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias di='docker images'
alias dex='docker exec -it'
alias dlogs='docker logs -f'
alias drm='docker rm'
alias drmi='docker rmi'
alias dprune='docker system prune -f'
alias ld='lazydocker'

# ── Kubernetes ────────────────────────────────────────────────
alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'
alias kdel='kubectl delete'
alias ka='kubectl apply -f'
alias kl='kubectl logs -f'
alias kex='kubectl exec -it'
alias kns='kubens'
alias kctx='kubectx'
alias k9='k9s'

# ── Tmux ─────────────────────────────────────────────────────
alias t='tmux'
alias ta='tmux attach -t'
alias tl='tmux list-sessions'
alias tn='tmux new -s'
alias tk='tmux kill-session -t'

# ── Sistema macOS ─────────────────────────────────────────────
alias reload='source ~/.zshrc'
alias zshrc='${EDITOR} ~/.zshrc'
alias hosts='sudo ${EDITOR} /etc/hosts'
alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
alias showfiles='defaults write com.apple.Finder AppleShowAllFiles true && killall Finder'
alias hidefiles='defaults write com.apple.Finder AppleShowAllFiles false && killall Finder'
alias cleanup='find . -name ".DS_Store" -delete && find . -name "node_modules" -maxdepth 2 -exec rm -rf {} +'
alias cpu='btop'
alias mem='btop'
alias ports='lsof -iTCP -sTCP:LISTEN -P'
alias myip='curl -s https://api.ipify.org && echo'
alias localip='ipconfig getifaddr en0'
alias wifi='networksetup -getairportnetwork en0'
alias update='brew update && brew upgrade && brew cleanup'

# ── Editores ─────────────────────────────────────────────────
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias nv='nvim'
alias code='code'

# ── Varios ───────────────────────────────────────────────────
alias path='echo $PATH | tr ":" "\n"'
alias size='du -sh'
alias disk='duf'
alias tree='eza --tree --icons'
alias weather='curl wttr.in'
alias cheat='navi'
alias mk='mkdir -p'
alias rf='rm -rf'
alias cp='cp -iv'
alias mv='mv -iv'
alias ln='ln -iv'
alias mkdir='mkdir -pv'
alias h='history'
alias hg='history | rg'
alias e='exit'
alias q='exit'
alias c='clear'
ALIASES
  track_ok ".zsh_aliases escrito"
}

# ════════════════════════════════════════════════════════════════
#  FUNCIONES ZSH
# ════════════════════════════════════════════════════════════════
_write_zsh_functions() {
  cat > "${HOME}/.zsh_functions" << 'FUNCTIONS'
# DevForge — Funciones Zsh

# ── Navegación ───────────────────────────────────────────────
# mkcd: crear directorio y entrar
mkcd() { mkdir -p "$@" && cd "$_"; }

# up: subir N directorios
up() {
  local n="${1:-1}" path=".."
  for (( i=1; i<n; i++ )); do path="${path}/.."; done
  cd "${path}" || return
}

# fcd: fuzzy cd usando fzf
fcd() {
  local dir
  dir="$(fd --type d --hidden --exclude .git 2>/dev/null | fzf --preview 'eza --tree --icons {} | head -30')" && cd "${dir}"
}

# ── Archivos ──────────────────────────────────────────────────
# extract: descomprimir cualquier archivo
extract() {
  if [[ -f "$1" ]]; then
    case "$1" in
      *.tar.bz2) tar xjf "$1"    ;;
      *.tar.gz)  tar xzf "$1"    ;;
      *.tar.xz)  tar xJf "$1"    ;;
      *.tar.zst) tar -x --use-compress-program=unzstd -f "$1" 2>/dev/null \
                   || { zstd -d "$1" -c | tar xf -; } ;;
      *.bz2)     bunzip2 "$1"    ;;
      *.gz)      gunzip "$1"     ;;
      *.tar)     tar xf "$1"     ;;
      *.tbz2)    tar xjf "$1"    ;;
      *.tgz)     tar xzf "$1"    ;;
      *.zip)     unzip "$1"      ;;
      *.Z)       uncompress "$1" ;;
      *.7z)      7z x "$1"       ;;
      *.xz)      unxz "$1"       ;;
      *.rar)     unrar x "$1"    ;;
      *.lz4)     lz4 -d "$1"     ;;
      *.zst)     zstd -d "$1"    ;;
      *)         echo "'$1' no se puede extraer automáticamente" ;;
    esac
  else
    echo "'$1' no es un archivo válido"
  fi
}

# ── Desarrollo ────────────────────────────────────────────────
# serve: servidor HTTP en directorio actual
serve() {
  local port="${1:-8080}"
  if command -v python3 &>/dev/null; then
    echo "🌐 Servidor en http://localhost:${port}  (Ctrl+C para detener)"
    python3 -m http.server "${port}"
  elif command -v npx &>/dev/null; then
    npx serve -l "${port}"
  else
    echo "No se encontró python3 ni npx" && return 1
  fi
}

# ghclone: clonar repo de GitHub de forma rápida
ghclone() {
  local repo="${1}" dir="${2:-}"
  [[ -z "${repo}" ]] && echo "Uso: ghclone usuario/repo [directorio]" && return 1
  local url="https://github.com/${repo}.git"
  local dest="${dir:-${repo##*/}}"
  git clone "${url}" "${dest}" && cd "${dest}"
}

# new-project: scaffold de proyecto nuevo
new-project() {
  local type="${1}" name="${2}"
  [[ -z "${type}" || -z "${name}" ]] && \
    echo "Uso: new-project <tipo> <nombre>" && \
    echo "Tipos: ts, react, next, vue, python, rust, go, node" && return 1

  case "${type}" in
    ts|typescript)  pnpm create vite "${name}" --template typescript ;;
    react)          pnpm create vite "${name}" --template react-ts ;;
    next)           pnpm create next-app "${name}" ;;
    vue)            pnpm create vue "${name}" ;;
    svelte)         pnpm create svelte "${name}" ;;
    astro)          pnpm create astro "${name}" ;;
    python)         mkdir "${name}" && cd "${name}" && uv init ;;
    rust)           cargo new "${name}" && cd "${name}" ;;
    go)             mkdir "${name}" && cd "${name}" && go mod init "${name}" ;;
    node)           mkdir "${name}" && cd "${name}" && pnpm init ;;
    *) echo "Tipo desconocido: ${type}" && return 1 ;;
  esac
}

# ── Git ───────────────────────────────────────────────────────
# git-cleanup: eliminar ramas merged
git-cleanup() {
  git fetch --prune
  # xargs -r es GNU-only; en macOS (BSD) se omite -r y se filtra con grep primero
  local merged
  merged="$(git branch --merged | grep -v '^\*\|main\|master\|dev\|develop')"
  if [[ -n "${merged}" ]]; then
    echo "${merged}" | xargs git branch -d
    echo "✔ Ramas merged eliminadas"
  else
    echo "No hay ramas merged para eliminar"
  fi
}

# fkill: matar proceso interactivo con fzf
fkill() {
  local pid
  pid="$(ps aux \
    | fzf --header='↑↓ selecciona · Enter mata · Esc cancela' \
          --header-lines=1 --prompt='kill › ' --height=50% --border=rounded \
    | awk '{print $2}')" || return
  [[ -n "${pid}" ]] && kill -9 "${pid}" && echo "✔ Proceso ${pid} terminado"
}

# ── Red ──────────────────────────────────────────────────────
# port: mostrar qué proceso usa un puerto
port() {
  local p="${1}"
  [[ -z "${p}" ]] && echo "Uso: port <número>" && return 1
  lsof -iTCP:"${p}" -sTCP:LISTEN -P -n
}

# ipinfo: mostrar info de IP pública
ipinfo() {
  curl -s "https://ipinfo.io/${1:-}" | jq '.'
}

# ── Utilidades ────────────────────────────────────────────────
# jwt-decode: decodificar JWT sin validar firma
jwt-decode() {
  local token="${1}"
  [[ -z "${token}" ]] && echo "Uso: jwt-decode <token>" && return 1
  echo "${token}" | cut -d. -f2 | base64 -d 2>/dev/null | jq '.' 2>/dev/null || \
    echo "${token}" | cut -d. -f2 | python3 -c "import sys,base64,json; \
      d=sys.stdin.read().strip(); \
      d+='='*(-len(d)%4); \
      print(json.dumps(json.loads(base64.b64decode(d).decode()),indent=2))"
}

# json: formato bonito de JSON
json() { echo "${1}" | jq '.'; }

# timezsh: medir tiempo de inicio de zsh
timezsh() {
  local shell="${SHELL}"
  for i in $(seq 1 5); do
    /usr/bin/time "${shell}" -i -c exit 2>&1
  done
}

# man: man pages con bat (syntax highlighting)
man() {
  MANPAGER="sh -c 'col -bx | bat -l man -p'" command man "$@"
}

# docker-clean: limpiar todo lo que Docker no usa
docker-clean() {
  docker system prune -af --volumes
  echo "Docker limpiado ✓"
}

# ── Git avanzado ─────────────────────────────────────────────
# groot: ir al directorio raíz del repo
groot() {
  local root
  root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
    echo "No estás en un repositorio git" && return 1
  }
  cd "${root}"
}

# ghpr: abrir Pull Request en el navegador
# (renombrado desde gpr — oh-my-zsh git plugin reserva gpr como alias)
ghpr() {
  local branch remote_url
  branch="$(git symbolic-ref --short HEAD 2>/dev/null)" || return 1
  remote_url="$(git remote get-url origin 2>/dev/null)"
  # GitHub
  if [[ "${remote_url}" =~ github\.com ]]; then
    local repo="${remote_url##*github.com[:/]}"
    repo="${repo%.git}"
    open "https://github.com/${repo}/compare/${branch}?expand=1"
  # GitLab
  elif [[ "${remote_url}" =~ gitlab\.com ]]; then
    local repo="${remote_url##*gitlab.com[:/]}"
    repo="${repo%.git}"
    open "https://gitlab.com/${repo}/-/merge_requests/new?merge_request[source_branch]=${branch}"
  else
    echo "URL remota no reconocida: ${remote_url}"
  fi
}

# gsync: sync fork con upstream
gsync() {
  git fetch upstream 2>/dev/null || { echo "Agrega upstream: git remote add upstream <URL>"; return 1; }
  git checkout main 2>/dev/null || git checkout master
  git merge upstream/main 2>/dev/null || git merge upstream/master
  git push origin HEAD
}

# ── Fuzzy / fzf helpers ───────────────────────────────────────
# fssh: conectar a servidor via fzf (lee ~/.ssh/config)
fssh() {
  local host
  host="$(grep -oP '^Host \K[^\*].*' "${HOME}/.ssh/config" 2>/dev/null \
    | fzf --prompt=' SSH › ' --height=40% --border=rounded)" || return
  ssh "${host}"
}

# fenv: buscar y copiar variable de entorno
fenv() {
  local out
  out="$(env | sort | fzf --prompt='env › ' --height=40% --border=rounded)" || return
  echo "${out}" | awk -F= '{print $2}' | pbcopy
  echo "Copiado: ${out%%=*}"
}

# flog: navegar git log con fzf y ver diff
flog() {
  git log --oneline --color=always | \
    fzf --ansi --preview 'git show --color=always {1}' \
        --preview-window=right:60% \
        --bind 'enter:execute(git show --color=always {1} | less -R)' \
        --prompt='log › '
}

# fbranch: cambiar de rama con fzf
fbranch() {
  local branch
  branch="$(git branch -a --color=always \
    | grep -v HEAD \
    | fzf --ansi --prompt='branch › ' --height=40% --border=rounded \
          --preview 'git log --oneline --color=always {1} | head -20')" || return
  branch="${branch##* }"
  branch="${branch#remotes/origin/}"
  git checkout "${branch}"
}

# ── Desarrollo ────────────────────────────────────────────────
# envup: cargar archivo .env en el shell actual
envup() {
  local file="${1:-.env}"
  [[ ! -f "${file}" ]] && echo "No se encontró ${file}" && return 1
  set -o allexport
  source "${file}"
  set +o allexport
  echo "✔ Variables cargadas desde ${file}"
}

# bak: hacer backup numerado de un archivo
bak() {
  [[ -z "$1" ]] && echo "Uso: bak <archivo>" && return 1
  cp "$1" "${1}.bak.$(date +%Y%m%d_%H%M%S)" && echo "✔ Backup: ${1}.bak.*"
}

# mkenv: crear virtualenv Python y activarlo
mkenv() {
  local name="${1:-.venv}"
  python3 -m venv "${name}" && source "${name}/bin/activate"
  echo "✔ Virtualenv activado: ${name}"
}

# dsh: abrir shell interactivo en un contenedor Docker
dsh() {
  local container="${1}"
  if [[ -z "${container}" ]]; then
    container="$(docker ps --format '{{.Names}}' \
      | fzf --prompt='docker › ' --height=40% --border=rounded)" || return
  fi
  local shell
  docker exec -it "${container}" bash 2>/dev/null || \
  docker exec -it "${container}" sh
}

# dlogs: seguir logs de un contenedor con fzf
dfzf() {
  local container
  container="$(docker ps --format '{{.Names}}' \
    | fzf --prompt='logs › ' --height=40% --border=rounded)" || return
  docker logs -f "${container}"
}

# ── Red ──────────────────────────────────────────────────────
# myports: puertos abiertos con formato legible
myports() {
  echo "COMANDO                          PID    PUERTO"
  echo "────────────────────────────────────────────────"
  lsof -iTCP -sTCP:LISTEN -P -n \
    | awk 'NR>1 {printf "%-32s %-6s %s\n", $1, $2, $9}' \
    | sort -k3
}

# tunnel: crear tunel SSH reverso rápido
tunnel() {
  local local_port="${1}" remote_port="${2}" host="${3}"
  [[ -z "${local_port}" || -z "${host}" ]] && \
    echo "Uso: tunnel <puerto_local> <puerto_remoto> <host>" && return 1
  ssh -N -L "${local_port}:localhost:${remote_port:-$local_port}" "${host}"
}

# ── Utilidades ────────────────────────────────────────────────
# genpass: generar contraseña segura
genpass() {
  local len="${1:-32}"
  LC_ALL=C tr -dc 'A-Za-z0-9!@#$%^&*()-_=+[]{}|;:,.<>?' </dev/urandom \
    | head -c "${len}"
  echo
}

# gentoken: generar token hex (para secrets, API keys, etc.)
gentoken() {
  local len="${1:-32}"
  openssl rand -hex "${len}"
}

# sizeof: tamaño de archivo o directorio de forma legible
sizeof() {
  du -sh "${1:-.}" | cut -f1
}

# repeat-cmd: repetir un comando N veces
repeat-cmd() {
  local n="${1}"; shift
  for _ in $(seq 1 "${n}"); do "$@"; done
}

# ── AI helpers ────────────────────────────────────────────────
# explain: explicar un comando con AI
explain() {
  local cmd="${*}"
  [[ -z "${cmd}" ]] && echo "Uso: explain <comando>" && return 1
  if command -v llm &>/dev/null; then
    echo "Explicando: ${cmd}" | llm "Explica brevemente qué hace este comando de shell:"
  elif command -v claude &>/dev/null; then
    echo "claude: Explica brevemente '${cmd}'"
  else
    echo "Instala 'llm' o 'claude' para usar esta función"
  fi
}

# tldr-fn: resumen rápido de una función de este archivo
help-fn() {
  grep -A2 "^# " "${HOME}/.zsh_functions" \
    | grep -v "^--$" \
    | fzf --ansi --prompt='funciones › ' --height=50% --border=rounded \
          --preview 'grep -A20 "^{}" '"${HOME}/.zsh_functions"
}
FUNCTIONS
  track_ok ".zsh_functions escrito"
}

# ════════════════════════════════════════════════════════════════
#  COMPLETIONS EXTRA — ~/.zsh_completions
#  Completions de terceros no incluidos en oh-my-zsh
# ════════════════════════════════════════════════════════════════
_write_zsh_completions() {
  local comp_dir="${HOME}/.zsh/completions"
  ensure_dir "${comp_dir}"

  cat > "${HOME}/.zsh_completions" << 'COMPLETIONS'
# DevForge — Completions extra
# Sourcear este archivo DESPUÉS de oh-my-zsh y compinit

# ── fpath para completions personalizadas ─────────────────────
fpath=("${HOME}/.zsh/completions" $fpath)

# ── Completion scripts de herramientas (si están instaladas) ──

# gh (GitHub CLI)
command -v gh      &>/dev/null && eval "$(gh completion -s zsh)"

# docker (solo si no lo carga oh-my-zsh ya)
# command -v docker  &>/dev/null && source <(docker completion zsh) 2>/dev/null

# kubectl
command -v kubectl &>/dev/null && source <(kubectl completion zsh) 2>/dev/null

# helm
command -v helm    &>/dev/null && source <(helm completion zsh) 2>/dev/null

# terraform
command -v terraform &>/dev/null && complete -C "$(command -v terraform)" terraform

# aws-cli v2
command -v aws     &>/dev/null && complete -C "$(command -v aws_completer)" aws 2>/dev/null

# pnpm
# pnpm: genera completions para el shell actual (auto-detectado)
if command -v pnpm &>/dev/null; then
  eval "$(pnpm completion 2>/dev/null)" 2>/dev/null || true
fi

# bun
command -v bun     &>/dev/null && source <(bun completions 2>/dev/null) || true

# rustup
[[ -f "${HOME}/.rustup/toolchains/stable-aarch64-apple-darwin/share/zsh/site-functions/_rustup" ]] && \
  source "${HOME}/.rustup/toolchains/stable-aarch64-apple-darwin/share/zsh/site-functions/_rustup" 2>/dev/null || true

# cargo (rustup provee _cargo automáticamente en el fpath)

# mise
command -v mise    &>/dev/null && eval "$(mise completion zsh)" 2>/dev/null || true

# ── Completions personalizadas inline ─────────────────────────

# Completar ramas de git para fbranch/gco
_git_branch_completion() {
  local branches
  branches=($(git branch -a 2>/dev/null | sed 's/\* //' | sed 's/remotes\/origin\///' | sort -u))
  compadd -a branches
}
compdef _git_branch_completion fbranch gco gcob 2>/dev/null || true

# Completar contenedores docker para dsh/dfzf
_docker_container_completion() {
  local containers
  containers=($(docker ps --format '{{.Names}}' 2>/dev/null))
  compadd -a containers
}
compdef _docker_container_completion dsh dfzf dlogs 2>/dev/null || true

# Completar hosts SSH para fssh
_ssh_host_completion() {
  local hosts
  hosts=($(grep -oP '^Host \K[^\*].*' "${HOME}/.ssh/config" 2>/dev/null))
  compadd -a hosts
}
compdef _ssh_host_completion fssh ssh 2>/dev/null || true

# Completar archivos comprimidos para extract
_extract_completion() {
  _files -g '*.{tar,gz,bz2,xz,zst,zip,rar,7z,lz4,tgz,tbz2,tar.gz,tar.bz2,tar.xz,tar.zst}'
}
compdef _extract_completion extract 2>/dev/null || true
COMPLETIONS
  track_ok ".zsh_completions escrito"
}

# ════════════════════════════════════════════════════════════════
#  OH MY ZSH — Instalación
# ════════════════════════════════════════════════════════════════
_install_ohmyzsh() {
  if [[ -d "${HOME}/.oh-my-zsh" ]]; then
    track_skip "Oh My Zsh (ya instalado)"
    # Intentar actualizar silenciosamente
    git -C "${HOME}/.oh-my-zsh" pull --quiet --ff-only >> "${LOG_FILE}" 2>&1 || true
    return 0
  fi
  # export explícito evita problemas con comillas anidadas
  if run_task "Instalando Oh My Zsh" \
    env RUNZSH=no CHSH=no \
    bash -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'; then
    track_ok "Oh My Zsh"
  else
    track_fail "Oh My Zsh"
  fi
}

# ════════════════════════════════════════════════════════════════
#  POWERLEVEL10K — Instalación del tema
# ════════════════════════════════════════════════════════════════
_install_powerlevel10k() {
  local p10k_dir="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/themes/powerlevel10k"
  if [[ -d "${p10k_dir}" ]]; then
    track_skip "Powerlevel10k (ya instalado)"
    git -C "${p10k_dir}" pull --quiet --ff-only >> "${LOG_FILE}" 2>&1 || true
    return 0
  fi
  if run_task "Clonando Powerlevel10k" \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${p10k_dir}"; then
    track_ok "Powerlevel10k"
  else
    track_fail "Powerlevel10k"
  fi
}

# ════════════════════════════════════════════════════════════════
#  PLUGINS ZSH — Instalación de plugins externos
# ════════════════════════════════════════════════════════════════
_install_zsh_plugins() {
  local custom_dir="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins"
  ensure_dir "${custom_dir}"

  # Array indexado de pares "nombre|url"
  # (bash 3.2 en macOS no soporta `local -A` — nunca usar asociativos)
  local zsh_plugins=(
    "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions"
    "zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting"
    "zsh-completions|https://github.com/zsh-users/zsh-completions"
    "zsh-history-substring-search|https://github.com/zsh-users/zsh-history-substring-search"
    "you-should-use|https://github.com/MichaelAquilina/zsh-you-should-use"
    "fzf-tab|https://github.com/Aloxaf/fzf-tab"
    "zsh-autopair|https://github.com/hlissner/zsh-autopair"
  )

  local entry plugin_name plugin_url dest
  for entry in "${zsh_plugins[@]}"; do
    plugin_name="${entry%%|*}"
    plugin_url="${entry#*|}"
    dest="${custom_dir}/${plugin_name}"
    if [[ -d "${dest}" ]]; then
      track_skip "${plugin_name}"
      git -C "${dest}" pull --quiet --ff-only >> "${LOG_FILE}" 2>&1 || true
    else
      if run_task "Instalando ${plugin_name}" \
        git clone --depth=1 "${plugin_url}" "${dest}"; then
        track_ok "${plugin_name}"
      else
        track_fail "${plugin_name}"
      fi
    fi
  done
}

# ════════════════════════════════════════════════════════════════
#  POWERLEVEL10K CONFIG — Configuración pre-optimizada
# ════════════════════════════════════════════════════════════════
_write_p10k_config() {
  # Solo escribir si no existe ya una configuración personalizada
  if [[ -f "${HOME}/.p10k.zsh" ]]; then
    track_skip ".p10k.zsh (ya existe — ejecuta 'p10k configure' para reconfigurar)"
    return 0
  fi

  cat > "${HOME}/.p10k.zsh" << 'P10K'
# DevForge — Powerlevel10k Config (Developer Optimized)
# Para reconfigurar desde cero: p10k configure
# Requiere fuente: MesloLGS NF

'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  # ── Segmentos izquierda ─────────────────────────────────────
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    os_icon
    dir
    vcs
    newline
    prompt_char
  )

  # ── Segmentos derecha ───────────────────────────────────────
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status
    command_execution_time
    background_jobs
    node_version
    python_version
    go_version
    rust_version
    docker_context
    aws
    kubecontext
    terraform
    time
  )

  # ── General ─────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_MODE=nerdfont-v3
  typeset -g POWERLEVEL9K_ICON_PADDING=moderate
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=same-dir
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose

  # ── OS Icon ─────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=232
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=7

  # ── Directorio ──────────────────────────────────────────────
  typeset -g POWERLEVEL9K_DIR_BACKGROUND=4
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=254
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=''
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=80
  typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=v3
  typeset -g POWERLEVEL9K_DIR_NOT_WRITABLE_BACKGROUND=1
  local anchor_files=(
    .bzr .git .github .hg .node-version .python-version .ruby-version
    .terraform .tool-versions .venv composer.json go.mod package.json
    Pipfile pyproject.toml requirements.txt setup.py
  )
  typeset -g POWERLEVEL9K_SHORTEN_FOLDER_MARKER="(${(j:|:)anchor_files})"

  # ── Git / VCS ───────────────────────────────────────────────
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=' '
  typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=2
  typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=3
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=2
  typeset -g POWERLEVEL9K_VCS_CONFLICTED_BACKGROUND=3
  typeset -g POWERLEVEL9K_VCS_LOADING_BACKGROUND=8
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=0
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=0
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=0

  # ── Carácter del prompt ─────────────────────────────────────
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=76
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=196
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=''

  # ── Status ──────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_STATUS_EXTENDED_STATES=true
  typeset -g POWERLEVEL9K_STATUS_OK=false
  typeset -g POWERLEVEL9K_STATUS_ERROR=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=160
  typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND=0
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL=true

  # ── Tiempo de ejecución ─────────────────────────────────────
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=248
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'

  # ── Node.js ─────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_NODE_VERSION_FOREGROUND=70
  typeset -g POWERLEVEL9K_NODE_VERSION_BACKGROUND=0
  typeset -g POWERLEVEL9K_NODE_VERSION_PROJECT_ONLY=true

  # ── Python ──────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_PYTHON_VERSION_FOREGROUND=37
  typeset -g POWERLEVEL9K_PYTHON_VERSION_BACKGROUND=0
  typeset -g POWERLEVEL9K_PYTHON_VERSION_PROJECT_ONLY=true

  # ── Go ──────────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_GO_VERSION_FOREGROUND=37
  typeset -g POWERLEVEL9K_GO_VERSION_BACKGROUND=0
  typeset -g POWERLEVEL9K_GO_VERSION_PROJECT_ONLY=true

  # ── Rust ────────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_RUST_VERSION_FOREGROUND=208
  typeset -g POWERLEVEL9K_RUST_VERSION_BACKGROUND=0
  typeset -g POWERLEVEL9K_RUST_VERSION_PROJECT_ONLY=true

  # ── Docker ──────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_DOCKER_CONTEXT_SHOW_DEFAULT=false
  typeset -g POWERLEVEL9K_DOCKER_CONTEXT_FOREGROUND=247
  typeset -g POWERLEVEL9K_DOCKER_CONTEXT_BACKGROUND=0

  # ── AWS ─────────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_AWS_SHOW_ON_COMMAND='aws|terraform|pulumi|terragrunt'
  typeset -g POWERLEVEL9K_AWS_CLASSES=('*prod*' PROD '*staging*' STAGING '*dev*' DEV '*' DEFAULT)
  typeset -g POWERLEVEL9K_AWS_DEFAULT_FOREGROUND=208
  typeset -g POWERLEVEL9K_AWS_DEFAULT_BACKGROUND=0
  typeset -g POWERLEVEL9K_AWS_PROD_FOREGROUND=9
  typeset -g POWERLEVEL9K_AWS_PROD_BACKGROUND=0

  # ── Kubernetes ──────────────────────────────────────────────
  typeset -g POWERLEVEL9K_KUBECONTEXT_SHOW_ON_COMMAND='kubectl|helm|kubens|kubectx|k9s|flux'
  typeset -g POWERLEVEL9K_KUBECONTEXT_CLASSES=('*prod*' PROD '*staging*' STAGING '*' DEFAULT)
  typeset -g POWERLEVEL9K_KUBECONTEXT_DEFAULT_FOREGROUND=134
  typeset -g POWERLEVEL9K_KUBECONTEXT_DEFAULT_BACKGROUND=0
  typeset -g POWERLEVEL9K_KUBECONTEXT_PROD_FOREGROUND=9
  typeset -g POWERLEVEL9K_KUBECONTEXT_PROD_BACKGROUND=0

  # ── Terraform ───────────────────────────────────────────────
  typeset -g POWERLEVEL9K_TERRAFORM_SHOW_DEFAULT=false
  typeset -g POWERLEVEL9K_TERRAFORM_CLASSES=('*prod*' PROD '*staging*' STAGING '*' DEFAULT)
  typeset -g POWERLEVEL9K_TERRAFORM_DEFAULT_FOREGROUND=105
  typeset -g POWERLEVEL9K_TERRAFORM_DEFAULT_BACKGROUND=0
  typeset -g POWERLEVEL9K_TERRAFORM_PROD_FOREGROUND=9
  typeset -g POWERLEVEL9K_TERRAFORM_PROD_BACKGROUND=0

  # ── Hora ────────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M}'
  typeset -g POWERLEVEL9K_TIME_FOREGROUND=66
  typeset -g POWERLEVEL9K_TIME_BACKGROUND=0

  # ── Hot reload ──────────────────────────────────────────────
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=false

  (( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
  'builtin' 'unset' 'p10k_config_opts'
}
P10K
  track_ok ".p10k.zsh escrito"
}
