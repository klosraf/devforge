#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
#  modules/linux/debian.sh — DevForge Debian Setup Module
#  Compatible with: Debian 11+
#  Managed by DevForge macOS Setup
# ═══════════════════════════════════════════════════════════════════

# Debian is very similar to Ubuntu — delegate with a Debian flag
[[ "$(uname -s)" != "Linux" ]] && { echo "This module requires Linux"; return 0; }

if ! command -v apt-get &>/dev/null; then
  echo "apt-get not found — skipping Debian module"
  return 0
fi

# ── Source shared Ubuntu module ───────────────────────────────────
_LINUX_MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./ubuntu.sh
source "${_LINUX_MODULE_DIR}/ubuntu.sh"

# ── Debian-specific overrides ─────────────────────────────────────

# Debian backports — uncomment to enable if on Debian stable
_devforge_enable_backports() {
  local codename
  codename="$(. /etc/os-release && echo "${VERSION_CODENAME:-stable}")"
  local sources="/etc/apt/sources.list.d/devforge-backports.list"
  if [[ ! -f "${sources}" ]]; then
    echo "deb http://deb.debian.org/debian ${codename}-backports main" | \
      sudo tee "${sources}" > /dev/null
    sudo apt-get update
    track_ok "Debian backports enabled"
  else
    track_skip "Debian backports (already configured)"
  fi
}

# ── Entry point ───────────────────────────────────────────────────
install_linux_debian() {
  devforge_linux_bootstrap
  devforge_linux_homebrew
  devforge_linux_zsh_default
  devforge_linux_git_config
}
