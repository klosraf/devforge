#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
#  modules/linux/fedora.sh — DevForge Fedora Setup Module
#  Compatible with: Fedora 38+
#  Managed by DevForge macOS Setup
# ═══════════════════════════════════════════════════════════════════

[[ "$(uname -s)" != "Linux" ]] && { echo "This module requires Linux"; return 0; }

if ! command -v dnf &>/dev/null; then
  echo "dnf not found — skipping Fedora module"
  return 0
fi

# ── Helpers ───────────────────────────────────────────────────────
_dnf() { sudo dnf "$@" --assumeyes; }
_dnf_install() { _dnf install "$@"; }

# ── Step 1: Bootstrap essentials ─────────────────────────────────
devforge_fedora_bootstrap() {
  ui_section "${L_INSTALLING:-Installing} core DNF packages" 2>/dev/null || echo "==> Core DNF packages"

  run_task "Update system" sudo dnf update --assumeyes

  local pkgs=(
    zsh bash bash-completion
    curl wget git git-lfs
    vim tmux
    make cmake gcc gcc-c++ gdb
    clang clang-tools-extra llvm lldb
    ruby perl openssl-devel readline-devel yaml-cpp-devel zlib-devel
    ShellCheck jq highlight colordiff atool tree
    htop openssh net-tools xclip
    eza fd-find bat ripgrep git-delta ranger
  )
  run_task "Install core packages" sudo dnf install "${pkgs[@]}" --assumeyes

  run_task "Autoremove unused packages" sudo dnf autoremove --assumeyes
}

# ── Step 2: Homebrew on Linux ─────────────────────────────────────
devforge_fedora_homebrew() {
  if command -v brew &>/dev/null; then
    track_skip "Homebrew (already installed)"
    return 0
  fi

  # DNF prerequisites
  run_task "Install Homebrew prerequisites" sudo dnf groupinstall "Development Tools" --assumeyes

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
devforge_fedora_zsh_default() {
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
install_linux_fedora() {
  devforge_fedora_bootstrap
  devforge_fedora_homebrew
  devforge_fedora_zsh_default
}
