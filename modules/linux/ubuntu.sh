#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
#  modules/linux/ubuntu.sh — DevForge Ubuntu/Debian Setup Module
#  Compatible with: Ubuntu 22.04+, Debian 12+
#  Managed by DevForge macOS Setup
# ═══════════════════════════════════════════════════════════════════

[[ "$(uname -s)" != "Linux" ]] && { echo "This module requires Linux"; return 0; }

# Detect APT-based distro
if ! command -v apt-get &>/dev/null; then
  echo "apt-get not found — skipping Ubuntu/Debian module"
  return 0
fi

# ── Helpers (inline for standalone sourcing) ──────────────────────
_apt() { sudo apt-get "$@" --yes; }
_apt_install() { _apt install "$@"; }

# ── Step 1: Bootstrap essentials ─────────────────────────────────
devforge_linux_bootstrap() {
  ui_section "${L_INSTALLING:-Installing} core apt packages" 2>/dev/null || echo "==> Core apt packages"

  run_task "Update package lists" sudo apt-get update
  run_task "Upgrade CA certificates" sudo apt-get install --only-upgrade ca-certificates --yes

  # Core CLI tools
  local pkgs=(
    zsh bash bash-completion
    curl wget git git-lfs git-extras
    vim tmux
    make cmake build-essential pkg-config
    gcc g++ gdb clang clang-format llvm lldb
    ruby-full perl libssl-dev libreadline-dev libyaml-dev zlib1g-dev
    shellcheck jq highlight colordiff atool tree
    htop net-tools ssh xclip
    software-properties-common apt-transport-https gpg
  )
  run_task "Install core packages" sudo apt-get install "${pkgs[@]}" --yes

  # Modern CLI: eza
  if ! command -v eza &>/dev/null; then
    if sudo apt-get install eza --yes 2>/dev/null; then
      track_ok "eza"
    else
      _devforge_install_eza_from_release
    fi
  else
    track_skip "eza"
  fi

  # Modern CLI: fd
  if ! command -v fd &>/dev/null && ! command -v fdfind &>/dev/null; then
    sudo apt-get install fd-find --yes 2>/dev/null && \
      (ln -sf "$(command -v fdfind)" "${HOME}/.local/bin/fd" 2>/dev/null || true) && \
      track_ok "fd-find" || _devforge_install_fd_from_release
  else
    track_skip "fd"
  fi

  # Modern CLI: bat
  if ! command -v bat &>/dev/null && ! command -v batcat &>/dev/null; then
    sudo apt-get install bat --yes 2>/dev/null && \
      (ln -sf "$(command -v batcat)" "${HOME}/.local/bin/bat" 2>/dev/null || true) && \
      track_ok "bat" || _devforge_install_bat_from_release
  else
    track_skip "bat"
  fi

  # Modern CLI: ripgrep
  if ! command -v rg &>/dev/null; then
    sudo apt-get install ripgrep --yes 2>/dev/null && track_ok "ripgrep" || \
      _devforge_install_ripgrep_from_release
  else
    track_skip "ripgrep"
  fi

  # Modern CLI: delta (git-delta)
  if ! command -v delta &>/dev/null; then
    sudo apt-get install git-delta --yes 2>/dev/null && track_ok "git-delta" || \
      _devforge_install_delta_from_release
  else
    track_skip "git-delta"
  fi

  # Modern CLI: ranger
  sudo apt-get install ranger --yes 2>/dev/null && track_ok "ranger" || track_fail "ranger"

  run_task "Autoremove unused packages" sudo apt-get autoremove --purge --yes
  run_task "Autoclean apt cache" sudo apt-get autoclean
}

# ── Fallback: install tools from GitHub releases ─────────────────
_devforge_install_eza_from_release() {
  local ver
  ver="$(curl -fsSL https://api.github.com/repos/eza-community/eza/releases/latest \
         | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/' 2>/dev/null)" || return 1
  local url="https://github.com/eza-community/eza/releases/download/v${ver}/eza_x86_64-unknown-linux-gnu.tar.gz"
  run_task "Install eza ${ver} from release" bash -c "
    curl -fsSL '${url}' | tar -xz -C /tmp && \
    sudo install -m755 /tmp/eza /usr/local/bin/eza
  " && track_ok "eza" || track_fail "eza"
}

_devforge_install_fd_from_release() {
  local ver
  ver="$(curl -fsSL https://api.github.com/repos/sharkdp/fd/releases/latest \
         | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/' 2>/dev/null)" || return 1
  local url="https://github.com/sharkdp/fd/releases/download/v${ver}/fd-v${ver}-x86_64-unknown-linux-gnu.tar.gz"
  run_task "Install fd ${ver} from release" bash -c "
    curl -fsSL '${url}' | tar -xz -C /tmp && \
    sudo install -m755 /tmp/fd-v${ver}-x86_64-unknown-linux-gnu/fd /usr/local/bin/fd
  " && track_ok "fd" || track_fail "fd"
}

_devforge_install_bat_from_release() {
  local ver
  ver="$(curl -fsSL https://api.github.com/repos/sharkdp/bat/releases/latest \
         | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/' 2>/dev/null)" || return 1
  local url="https://github.com/sharkdp/bat/releases/download/v${ver}/bat-v${ver}-x86_64-unknown-linux-gnu.tar.gz"
  run_task "Install bat ${ver} from release" bash -c "
    curl -fsSL '${url}' | tar -xz -C /tmp && \
    sudo install -m755 /tmp/bat-v${ver}-x86_64-unknown-linux-gnu/bat /usr/local/bin/bat
  " && track_ok "bat" || track_fail "bat"
}

_devforge_install_ripgrep_from_release() {
  local ver
  ver="$(curl -fsSL https://api.github.com/repos/BurntSushi/ripgrep/releases/latest \
         | grep '"tag_name"' | sed 's/.*"\([^"]*\)".*/\1/' 2>/dev/null)" || return 1
  local url="https://github.com/BurntSushi/ripgrep/releases/download/${ver}/ripgrep-${ver}-x86_64-unknown-linux-musl.tar.gz"
  run_task "Install ripgrep ${ver} from release" bash -c "
    curl -fsSL '${url}' | tar -xz -C /tmp && \
    sudo install -m755 /tmp/ripgrep-${ver}-x86_64-unknown-linux-musl/rg /usr/local/bin/rg
  " && track_ok "ripgrep" || track_fail "ripgrep"
}

_devforge_install_delta_from_release() {
  local ver
  ver="$(curl -fsSL https://api.github.com/repos/dandavison/delta/releases/latest \
         | grep '"tag_name"' | sed 's/.*"\([^"]*\)".*/\1/' 2>/dev/null)" || return 1
  local url="https://github.com/dandavison/delta/releases/download/${ver}/delta-${ver}-x86_64-unknown-linux-gnu.tar.gz"
  run_task "Install delta ${ver} from release" bash -c "
    curl -fsSL '${url}' | tar -xz -C /tmp && \
    sudo install -m755 /tmp/delta-${ver}-x86_64-unknown-linux-gnu/delta /usr/local/bin/delta
  " && track_ok "git-delta" || track_fail "git-delta"
}

# ── Step 2: Homebrew on Linux ─────────────────────────────────────
devforge_linux_homebrew() {
  if command -v brew &>/dev/null; then
    track_skip "Homebrew (already installed)"
    return 0
  fi

  local brew_prefix="/home/linuxbrew/.linuxbrew"
  mkdir -p "${HOME}/.local/bin" 2>/dev/null || true

  run_task "Install Homebrew" bash -c \
    'NONINTERACTIVE=true /bin/bash -c "$(curl -fsSL https://github.com/Homebrew/install/raw/HEAD/install.sh)"'

  # Activate
  if [[ -x "${brew_prefix}/bin/brew" ]]; then
    eval "$("${brew_prefix}/bin/brew" shellenv)"
    track_ok "Homebrew"
  elif [[ -x "${HOME}/.linuxbrew/bin/brew" ]]; then
    eval "$("${HOME}/.linuxbrew/bin/brew" shellenv)"
    track_ok "Homebrew (user mode)"
  else
    track_fail "Homebrew"
  fi

  # Persist to shell profile
  if command -v brew &>/dev/null; then
    local brew_shellenv
    brew_shellenv="$(brew shellenv)"
    append_to_zshrc "${brew_shellenv}" "devforge-homebrew" 2>/dev/null || true
  fi
}

# ── Step 3: zsh as default shell ──────────────────────────────────
devforge_linux_zsh_default() {
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

# ── Step 4: Git global config ─────────────────────────────────────
devforge_linux_git_config() {
  local gitconfig="${SCRIPT_DIR:-"$(pwd)"}/config/dotfiles/gitconfig"
  if [[ -f "${gitconfig}" ]]; then
    # Only set non-personal keys (user.name/email left to user)
    git config --global core.pager "$(command -v delta 2>/dev/null || echo less)"
    git config --global delta.navigate true
    git config --global delta.dark true
    git config --global delta.line-numbers true
    git config --global interactive.diffFilter "delta --color-only"
    git config --global init.defaultBranch main
    git config --global pull.ff only
    git config --global fetch.prune true
    track_ok "git global config"
  fi
}

# ── Entry point ───────────────────────────────────────────────────
install_linux_ubuntu() {
  devforge_linux_bootstrap
  devforge_linux_homebrew
  devforge_linux_zsh_default
  devforge_linux_git_config
}
