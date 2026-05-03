#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
#  modules/linux/manjaro.sh — DevForge Manjaro/Arch Setup Module
#  Compatible with: Manjaro, Arch Linux
#  Managed by DevForge macOS Setup
# ═══════════════════════════════════════════════════════════════════

[[ "$(uname -s)" != "Linux" ]] && { echo "This module requires Linux"; return 0; }

if ! command -v pacman &>/dev/null; then
  echo "pacman not found — skipping Manjaro/Arch module"
  return 0
fi

# ── Helpers ───────────────────────────────────────────────────────
_pacman() { sudo pacman "$@" --noconfirm; }
_pacman_install() { _pacman -S "$@"; }

# ── Step 1: Bootstrap essentials ─────────────────────────────────
devforge_manjaro_bootstrap() {
  ui_section "${L_INSTALLING:-Installing} core Pacman packages" 2>/dev/null || echo "==> Core Pacman packages"

  run_task "Update package database" sudo pacman -Syu --noconfirm

  local pkgs=(
    zsh bash bash-completion
    curl wget git git-lfs
    vim tmux
    base-devel make cmake
    gcc gdb clang llvm lldb
    ruby perl openssl readline libyaml zlib
    shellcheck jq highlight colordiff atool tree
    htop openssh net-tools xclip
    eza fd bat ripgrep git-delta ranger
  )
  run_task "Install core packages" sudo pacman -S "${pkgs[@]}" --noconfirm

  # AUR helper: yay (if not present)
  if ! command -v yay &>/dev/null; then
    run_task "Install yay (AUR helper)" bash -c '
      git clone --depth=1 https://aur.archlinux.org/yay-bin.git /tmp/yay-bin &&
      (cd /tmp/yay-bin && makepkg -si --noconfirm) &&
      rm -rf /tmp/yay-bin
    ' && track_ok "yay" || track_fail "yay"
  else
    track_skip "yay (already installed)"
  fi

  run_task "Remove orphan packages" sudo pacman -Rns "$(pacman -Qtdq)" --noconfirm 2>/dev/null || true
}

# ── Step 2: Homebrew on Linux ─────────────────────────────────────
devforge_manjaro_homebrew() {
  if command -v brew &>/dev/null; then
    track_skip "Homebrew (already installed)"
    return 0
  fi

  run_task "Install Homebrew" bash -c \
    'NONINTERACTIVE=true /bin/bash -c "$(curl -fsSL https://github.com/Homebrew/install/raw/HEAD/install.sh)"'

  local brew_prefix="/home/linuxbrew/.linuxbrew"
  if [[ -x "${brew_prefix}/bin/brew" ]]; then
    eval "$("${brew_prefix}/bin/brew" shellenv)"
    track_ok "Homebrew"
  elif [[ -x "${HOME}/.linuxbrew/bin/brew" ]]; then
    eval "$("${HOME}/.linuxbrew/bin/brew" shellenv)"
    track_ok "Homebrew (user mode)"
  else
    track_fail "Homebrew"
  fi

  command -v brew &>/dev/null && append_to_zshrc "$(brew shellenv)" "devforge-homebrew" 2>/dev/null || true
}

# ── Step 3: zsh as default shell ──────────────────────────────────
devforge_manjaro_zsh_default() {
  local zsh_path
  zsh_path="$(command -v zsh 2>/dev/null)"
  [[ -z "${zsh_path}" ]] && { track_fail "zsh (not found)"; return 0; }
  grep -qF "${zsh_path}" /etc/shells 2>/dev/null || \
    echo "${zsh_path}" | sudo tee -a /etc/shells >/dev/null
  if [[ "${SHELL}" != "${zsh_path}" ]]; then
    run_task "Set zsh as default shell" sudo chsh -s "${zsh_path}" "${USER}"
    track_ok "Default shell → zsh"
  else
    track_skip "Default shell (already zsh)"
  fi
}

# ── Entry point ───────────────────────────────────────────────────
install_linux_manjaro() {
  devforge_manjaro_bootstrap
  devforge_manjaro_homebrew
  devforge_manjaro_zsh_default
}
