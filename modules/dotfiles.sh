#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────
#  Module: dotfiles — DevForge macOS Setup
#  Dotfiles management: chezmoi, mackup, stow, symlinks
# ─────────────────────────────────────────────────────────────────

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

module_dotfiles() {
  ui_section "DOTFILES MANAGEMENT" "◈"

  # ── Chezmoi — cross-machine dotfiles ─────────────────────────
  ui_step "Chezmoi — dotfiles manager with templates & secrets..."
  brew_install "chezmoi" "Chezmoi"

  # ── GNU Stow — symlink farm manager ──────────────────────────
  ui_step "GNU Stow — symlink manager for dotfiles..."
  brew_install "stow" "GNU Stow"

  # ── Mackup — backup & sync app settings ──────────────────────
  ui_step "Mackup — backup & restore macOS app settings..."
  brew_install "mackup" "Mackup"
  _write_mackup_config

  # ── YADM — Git-based dotfiles manager ────────────────────────
  ui_step "YADM — Yet Another Dotfiles Manager..."
  brew_install "yadm" "YADM"

  # ── Dotbot ───────────────────────────────────────────────────
  ui_step "Dotbot — dotfiles bootstrapper..."
  if has_cmd pip3; then
    pip3 install dotbot --break-system-packages 2>/dev/null || true
    track_ok "Dotbot"
  fi

  # ── Dockutil — Dock management CLI ───────────────────────────
  ui_step "Dockutil — manage macOS Dock from command line..."
  brew_install "dockutil" "Dockutil"

  # ── Initialize chezmoi structure ──────────────────────────────
  ui_step "Setting up chezmoi structure..."
  if has_cmd chezmoi; then
    local chezmoi_src
    chezmoi_src="$(chezmoi source-path 2>/dev/null || echo "${HOME}/.local/share/chezmoi")"
    ensure_dir "${chezmoi_src}"
    _write_chezmoi_config "${chezmoi_src}"
    track_ok "Chezmoi initialized"
  fi

  # ── Create dotfiles directory structure ───────────────────────
  ui_step "Creating organized dotfiles directory..."
  local dotfiles_dir="${HOME}/.dotfiles"
  ensure_dir "${dotfiles_dir}"
  ensure_dir "${dotfiles_dir}/zsh"
  ensure_dir "${dotfiles_dir}/git"
  ensure_dir "${dotfiles_dir}/nvim"
  ensure_dir "${dotfiles_dir}/tmux"
  ensure_dir "${dotfiles_dir}/ghostty"
  ensure_dir "${dotfiles_dir}/starship"
  ensure_dir "${dotfiles_dir}/scripts"
  ensure_dir "${dotfiles_dir}/bin"
  track_ok "Dotfiles directory structure created"

  # ── Install DevForge dotfiles from config/dotfiles/ ───────────
  ui_step "Installing DevForge dotfiles..."
  _install_devforge_dotfiles

  # ── Write dotfiles README ─────────────────────────────────────
  cat > "${dotfiles_dir}/README.md" << 'DOTFILES_README'
# My Dotfiles (DevForge)

Managed with **chezmoi** and **GNU Stow**.

## Structure
```
~/.dotfiles/
├── zsh/          → Zsh config (.zshrc, .zsh_aliases, .zsh_functions)
├── git/          → Git config (.gitconfig, .gitignore_global)
├── nvim/         → Neovim config (init.lua, lua/)
├── tmux/         → tmux config (.tmux.conf)
├── ghostty/      → Ghostty terminal config
├── starship/     → Starship prompt (starship.toml)
├── scripts/      → Utility scripts
└── bin/          → Personal binaries (add to PATH)
```

## Usage
```bash
# Apply with GNU Stow
cd ~/.dotfiles && stow zsh git nvim tmux

# Or with chezmoi
chezmoi apply

# Backup app settings with Mackup
mackup backup

# Restore on new machine
mackup restore
```
DOTFILES_README

  ui_success "Dotfiles infrastructure ready ✓"
}

# ── Private helpers ───────────────────────────────────────────────
_write_mackup_config() {
  cat > "${HOME}/.mackup.cfg" << 'MACKUP_CFG'
[storage]
engine = icloud
directory = Mackup

[applications_to_ignore]
transmission
MACKUP_CFG
  track_ok "Mackup configured"
}

_write_chezmoi_config() {
  local src_dir="${1}"
  ensure_dir "${HOME}/.config/chezmoi"
  cat > "${HOME}/.config/chezmoi/chezmoi.toml" << 'CHEZMOI_TOML'
[data]
  name = "DevForge User"
  email = "user@example.com"

[git]
  autoCommit = false
  autoPush = false

[diff]
  pager = "delta"

[edit]
  command = "nvim"
CHEZMOI_TOML
  track_ok "Chezmoi config written"
}

# ── Install dotfiles from config/dotfiles/ ────────────────────────
# For each file, if the destination doesn't exist we copy it.
# If it already exists and differs we back it up first.
_install_devforge_dotfiles() {
  local config_dir="${SCRIPT_DIR:-"$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"}/config/dotfiles"

  if [[ ! -d "${config_dir}" ]]; then
    ui_warn "config/dotfiles/ not found — skipping dotfile installation"
    return 0
  fi

  # map: source filename → destination path
  declare -A DOTFILE_MAP=(
    ["zshrc"]="${HOME}/.zshrc"
    ["bashrc"]="${HOME}/.bashrc"
    ["bash_profile"]="${HOME}/.bash_profile"
    ["gitconfig"]="${HOME}/.gitconfig"
    ["gitignore_global"]="${HOME}/.gitignore_global"
    ["vimrc"]="${HOME}/.vimrc"
    ["tmux.conf"]="${HOME}/.tmux.conf"
  )

  for src_name in "${!DOTFILE_MAP[@]}"; do
    local src="${config_dir}/${src_name}"
    local dst="${DOTFILE_MAP[${src_name}]}"
    [[ ! -f "${src}" ]] && continue

    if [[ -f "${dst}" && ! -L "${dst}" ]]; then
      # Back up existing file
      local bak="${dst}.devforge.bak.$(date +%s)"
      cp "${dst}" "${bak}" 2>/dev/null && ui_info "Backed up $(basename "${dst}") → $(basename "${bak}")"
    fi
    ln -sf "${src}" "${dst}" 2>/dev/null && track_ok "Linked ${src_name}" || track_fail "Link ${src_name}"
  done

  # Git global excludes
  if [[ -f "${HOME}/.gitconfig" ]]; then
    git config --global core.excludesfile "${HOME}/.gitignore_global" 2>/dev/null || true
  fi

  # Install utilities.sh to ~/.devforge/utilities.sh
  local utils_src="${SCRIPT_DIR:-"$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"}/lib/utils.sh"
  ensure_dir "${HOME}/.devforge"
  if [[ -f "${utils_src}" ]]; then
    cp "${utils_src}" "${HOME}/.devforge/utilities.sh" 2>/dev/null && \
      track_ok "DevForge utilities installed to ~/.devforge/utilities.sh" || \
      track_fail "DevForge utilities copy"
  fi

  # Ranger config
  local ranger_src="${SCRIPT_DIR:-"$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"}/config/ranger"
  if [[ -d "${ranger_src}" ]]; then
    ensure_dir "${HOME}/.config/ranger"
    for rf in rc.conf commands.py scope.sh; do
      [[ -f "${ranger_src}/${rf}" ]] && \
        ln -sf "${ranger_src}/${rf}" "${HOME}/.config/ranger/${rf}" 2>/dev/null && \
        track_ok "Linked ranger/${rf}" || true
    done
  fi

  # Claude Code settings
  local claude_src="${SCRIPT_DIR:-"$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"}/config/claude/settings.json"
  if [[ -f "${claude_src}" ]]; then
    ensure_dir "${HOME}/.claude"
    ln -sf "${claude_src}" "${HOME}/.claude/settings.json" 2>/dev/null && \
      track_ok "Linked Claude Code settings" || true
  fi

  track_ok "DevForge dotfiles installed"
}
