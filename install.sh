#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
#
#   ██████╗ ███████╗██╗   ██╗███████╗ ██████╗ ██████╗  ██████╗ ███████╗
#   ██╔══██╗██╔════╝██║   ██║██╔════╝██╔═══██╗██╔══██╗██╔════╝ ██╔════╝
#   ██║  ██║█████╗  ██║   ██║█████╗  ██║   ██║██████╔╝██║  ███╗█████╗
#   ██║  ██║██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║   ██║██╔══██╗██║   ██║██╔══╝
#   ██████╔╝███████╗ ╚████╔╝ ██║     ╚██████╔╝██║  ██║╚██████╔╝███████╗
#   ╚═════╝ ╚══════╝  ╚═══╝  ╚═╝      ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝
#
#   Developer Environment Forge — macOS & Linux
#   Version: 4.1.0  |  DevForge  |  macOS 13+ · Ubuntu · Debian · Fedora · Manjaro
#
# ═══════════════════════════════════════════════════════════════════

set -uo pipefail
# NOTA: No usamos 'set -e' para que los módulos no aborten el script
# ante instalaciones opcionales que fallen. Cada módulo maneja sus errores.

# ── Script paths ──────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/lib"
MODULES_DIR="${SCRIPT_DIR}/modules"

source "${LIB_DIR}/ui.sh"
source "${LIB_DIR}/lang.sh"
source "${LIB_DIR}/utils.sh"

# ── Version & metadata ────────────────────────────────────────────
readonly DEVFORGE_VERSION="4.1.0"
readonly DEVFORGE_DATE="2026"
readonly DEVFORGE_GITHUB="https://github.com/devforge/macos-setup"

# ── OS detection ──────────────────────────────────────────────────
_DEVFORGE_OS="$(uname -s 2>/dev/null)"
_DEVFORGE_LINUX_DISTRO=""
if [[ "${_DEVFORGE_OS}" == "Linux" ]]; then
  if grep -qiE 'ID.*ubuntu' /etc/*-release 2>/dev/null; then
    _DEVFORGE_LINUX_DISTRO="ubuntu"
  elif grep -qiE 'ID.*debian' /etc/*-release 2>/dev/null; then
    _DEVFORGE_LINUX_DISTRO="debian"
  elif grep -qiE 'ID.*fedora' /etc/*-release 2>/dev/null; then
    _DEVFORGE_LINUX_DISTRO="fedora"
  elif grep -qiE 'ID.*manjaro|ID.*arch' /etc/*-release 2>/dev/null; then
    _DEVFORGE_LINUX_DISTRO="manjaro"
  fi
fi

# ── State file ────────────────────────────────────────────────────
DEVFORGE_STATE_DIR="${HOME}/.devforge"
DEVFORGE_STATE_FILE="${DEVFORGE_STATE_DIR}/state.json"
ensure_dir "$DEVFORGE_STATE_DIR"

# ── Module loader — aislado para que errores no aborten install ───
load_module() {
  local mod="${1}"
  # Support linux/ sub-directory modules
  local mod_file="${MODULES_DIR}/${mod}.sh"
  [[ ! -f "${mod_file}" ]] && mod_file="${MODULES_DIR}/linux/${mod}.sh"
  if [[ -f "${mod_file}" ]]; then
    # shellcheck source=/dev/null
    source "${mod_file}" || {
      ui_warn "Módulo '${mod}' cargado con advertencias"
      return 0
    }
  else
    ui_warn "Módulo no encontrado: ${mod}"
    return 0
  fi
}

# ── Linux platform bootstrap ─────────────────────────────────────
run_linux_platform() {
  case "${_DEVFORGE_LINUX_DISTRO}" in
    ubuntu)
      load_module "linux/ubuntu"
      install_linux_ubuntu
      ;;
    debian)
      load_module "linux/debian"
      install_linux_debian
      ;;
    fedora)
      load_module "linux/fedora"
      install_linux_fedora
      ;;
    manjaro)
      load_module "linux/manjaro"
      install_linux_manjaro
      ;;
    *)
      ui_warn "Linux distro not recognized ('${_DEVFORGE_LINUX_DISTRO}'). Skipping platform bootstrap."
      ;;
  esac
}

# ════════════════════════════════════════════════════════════════
#  LANGUAGE SELECTOR
# ════════════════════════════════════════════════════════════════
show_lang_selector() {
  ui_clear
  ui_gap
  ui_gap

  # Título bilingüe siempre visible
  printf "  ${ACCENT}${BOLD}╭─────────────────────────────────────────╮${RESET}\n"
  printf "  ${ACCENT}${BOLD}│   🌐  Select language / Selecciona      │${RESET}\n"
  printf "  ${ACCENT}${BOLD}│       idioma — DevForge                 │${RESET}\n"
  printf "  ${ACCENT}${BOLD}╰─────────────────────────────────────────╯${RESET}\n"
  ui_gap

  printf "  ${ACCENT}1${RESET}  ${BOLD}${BWHITE}English${RESET}         ${MUTED}Continue in English${RESET}\n"
  printf "  ${ACCENT}2${RESET}  ${BOLD}${BWHITE}Español${RESET}         ${MUTED}Continuar en Español${RESET}\n"
  ui_gap

  # Mostrar idioma actual
  printf "  ${MUTED}Current / Actual: ${ACCENT}${L_LANG_NAME}${RESET}\n"
  ui_gap
  printf "  ${ACCENT}›${RESET}  "
  read -r lang_choice

  case "${lang_choice}" in
    1) lang_set "en"
       printf "  ${SUCCESS}✓  Language set to English${RESET}\n"
       ;;
    2) lang_set "es"
       printf "  ${SUCCESS}✓  Idioma establecido a Español${RESET}\n"
       ;;
    *) # Mantener el actual
       ;;
  esac
  sleep 0.8
}

# Cambio de idioma desde el menú principal
switch_language() {
  if [[ "${DEVFORGE_LANG}" == "es" ]]; then
    lang_set "en"
    ui_success "Language changed to English ✓"
  else
    lang_set "es"
    ui_success "Idioma cambiado a Español ✓"
  fi
  sleep 1
}

# ── Executor de módulo — captura errores y continúa ───────────────
run_module() {
  local mod="${1}"
  local fn="module_${mod}"
  ui_rule_accent
  ui_gap
  if load_module "${mod}"; then
    if declare -f "${fn}" > /dev/null 2>&1; then
      # Ejecutamos directamente (no en subshell) para preservar los arrays
      # de tracking (INSTALLED_ITEMS, FAILED_ITEMS, SKIPPED_ITEMS).
      # Cada módulo es responsable de capturar sus propios errores.
      if ! "${fn}"; then
        ui_warn "Módulo '${mod}' completado con algunos errores (ver log)"
      fi
    else
      ui_warn "Función ${fn} no encontrada en ${mod}.sh"
    fi
  fi
  ui_gap
}

# ═══════════════════════════════════════════════════════════════════
#  SPLASH SCREEN
# ═══════════════════════════════════════════════════════════════════
show_splash() {
  ui_clear
  ui_gap
  ui_gap

  local logo=(
    "  ██████╗ ███████╗██╗   ██╗███████╗ ██████╗ ██████╗  ██████╗ ███████╗"
    "  ██╔══██╗██╔════╝██║   ██║██╔════╝██╔═══██╗██╔══██╗██╔════╝ ██╔════╝"
    "  ██║  ██║█████╗  ██║   ██║█████╗  ██║   ██║██████╔╝██║  ███╗█████╗  "
    "  ██║  ██║██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║   ██║██╔══██╗██║   ██║██╔══╝  "
    "  ██████╔╝███████╗ ╚████╔╝ ██║     ╚██████╔╝██║  ██║╚██████╔╝███████╗"
    "  ╚═════╝ ╚══════╝  ╚═══╝  ╚═╝      ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝"
  )

  for line in "${logo[@]}"; do
    printf "${ACCENT}${line}${RESET}\n"
  done

  ui_gap
  printf "  ${MUTED}${L_SPLASH_SUBTITLE:-Developer Environment Forge}${RESET}  ${ACCENT}v${DEVFORGE_VERSION}${RESET}\n"
  printf "  ${SUBTLE}────────────────────────────────────────────────────────────────────${RESET}\n"
  ui_gap

  # System info
  detect_system
  local arch_label="Intel x86_64"
  [[ "${IS_APPLE_SILICON}" == true ]] && arch_label="Apple Silicon (arm64)"

  if [[ "${_DEVFORGE_OS}" == "Darwin" ]]; then
    printf "  ${MUTED}${L_SPLASH_SYSTEM:-System}${RESET}   ${ACCENT}→${RESET}  ${WHITE}macOS ${MACOS_VERSION}  ·  ${arch_label}${RESET}\n"
    printf "  ${MUTED}User${RESET}     ${ACCENT}→${RESET}  ${WHITE}$(whoami)  @  $(scutil --get ComputerName 2>/dev/null || hostname)${RESET}\n"
  else
    local _distro_pretty
    _distro_pretty="$(. /etc/os-release 2>/dev/null && echo "${PRETTY_NAME:-Linux}")"
    printf "  ${MUTED}${L_SPLASH_SYSTEM:-System}${RESET}   ${ACCENT}→${RESET}  ${WHITE}${_distro_pretty}  ·  ${ARCH}${RESET}\n"
    printf "  ${MUTED}User${RESET}     ${ACCENT}→${RESET}  ${WHITE}$(whoami)  @  $(hostname)${RESET}\n"
  fi
  printf "  ${MUTED}Brew${RESET}     ${ACCENT}→${RESET}  ${WHITE}${HOMEBREW_PREFIX}${RESET}\n"
  printf "  ${MUTED}Log${RESET}      ${ACCENT}→${RESET}  ${MUTED}${LOG_FILE}${RESET}\n"

  ui_gap
  ui_rule_accent
  ui_gap
}

# ═══════════════════════════════════════════════════════════════════
#  INSTALLATION MENU
# ═══════════════════════════════════════════════════════════════════
show_main_menu() {
  ui_gap
  printf "  ${ACCENT}${BOLD}${L_MENU_TITLE:-SELECT INSTALLATION PROFILE}${RESET}\n"
  ui_gap
  printf "  ${ACCENT}1${RESET}  ${BOLD}${BWHITE}${L_MENU_1:-Full Install}${RESET}           ${MUTED}Everything — all 9 modules (complete setup)${RESET}\n"
  printf "  ${ACCENT}2${RESET}  ${BOLD}${BWHITE}${L_MENU_2:-Core + Languages}${RESET}        ${MUTED}Homebrew, 80+ CLI tools, all languages, version managers${RESET}\n"
  printf "  ${ACCENT}3${RESET}  ${BOLD}${BWHITE}${L_MENU_3:-Editors & Terminal}${RESET}      ${MUTED}VS Code, Neovim+AI, Zed, Ghostty, Tabby, fonts, shell${RESET}\n"
  printf "  ${ACCENT}4${RESET}  ${BOLD}${BWHITE}${L_MENU_4:-DevOps & Cloud}${RESET}          ${MUTED}Docker, Kubernetes, Terraform, AWS/GCP/Azure, CI/CD${RESET}\n"
  printf "  ${ACCENT}5${RESET}  ${BOLD}${BWHITE}${L_MENU_5:-macOS Defaults}${RESET}          ${MUTED}System prefs, Dock, Finder, AeroSpace window mgr${RESET}\n"
  printf "  ${ACCENT}6${RESET}  ${BOLD}${BWHITE}${L_MENU_6:-Applications}${RESET}       ${MUTED}Browsers, DB GUIs, design tools, fonts, QuickLook${RESET}\n"
  printf "  ${ACCENT}7${RESET}  ${BOLD}${BWHITE}${L_MENU_7:-AI Coding Agents}${RESET}        ${MUTED}Claude Code, Gemini CLI, Aider, OpenCode, MCP servers${RESET}\n"
  printf "  ${ACCENT}8${RESET}  ${BOLD}${BWHITE}${L_MENU_8:-Dotfiles Setup}${RESET}          ${MUTED}chezmoi, GNU stow, mackup, dotfiles structure${RESET}\n"
  printf "  ${ACCENT}9${RESET}  ${BOLD}${BWHITE}${L_MENU_9:-iOS / Apple Dev}${RESET}         ${MUTED}Fastlane, XcodeGen, CocoaPods, simuladores, firma de código${RESET}\n"
  printf "  ${ACCENT}A${RESET}  ${BOLD}${BWHITE}${L_MENU_A:-Android Dev}${RESET}            ${MUTED}SDK, ADB, Gradle, Maestro, Fastlane, Play Store, Appium${RESET}\n"
  printf "  ${ACCENT}M${RESET}  ${BOLD}${BWHITE}${L_MENU_M:-Mobile (iOS+Android)}${RESET}  ${MUTED}Instalar ambas plataformas móviles completas${RESET}\n"
  printf "  ${ACCENT}L${RESET}  ${BOLD}${BWHITE}${L_MENU_L:-Linux Platform}${RESET}          ${MUTED}Bootstrap Linux distro (apt/dnf/pacman) + Homebrew + zsh${RESET}\n"
  printf "  ${ACCENT}c${RESET}  ${BOLD}${BWHITE}${L_MENU_C:-Custom Selection}${RESET}        ${MUTED}Choose individual modules to install${RESET}\n"
  printf "  ${ACCENT}u${RESET}  ${BOLD}${BWHITE}${L_MENU_U:-Update Everything}${RESET}       ${MUTED}Update all installed packages and tools${RESET}\n"
  printf "  ${ACCENT}x${RESET}  ${BOLD}${BWHITE}${L_MENU_X:-System Audit}${RESET}            ${MUTED}Scan and report what's installed, versions, health${RESET}\n"
  printf "  ${ACCENT}T${RESET}  ${BOLD}${BWHITE}${L_MENU_T:-Change Language}${RESET}        ${MUTED}${L_MENU_T_DESC:-Switch between English and Español}${RESET}\n"
  printf "  ${ACCENT}0${RESET}  ${RED}${L_MENU_0:-Exit}${RESET}\n"
  ui_gap
  printf "  ${ACCENT}›${RESET}  "
  read -r MENU_CHOICE
}

# ═══════════════════════════════════════════════════════════════════
#  MODULE SELECTION MENU
# ═══════════════════════════════════════════════════════════════════
show_module_menu() {
  ui_clear
  ui_gap
  printf "  ${ACCENT}${BOLD}${L_MOD_TITLE:-SELECT MODULES}${RESET}  ${MUTED}(space, enter)${RESET}\n"
  ui_gap

  local modules=(
    "core       ${L_MOD_CORE:-Core Foundation}"
    "languages  ${L_MOD_LANGUAGES:-Programming Languages}"
    "frameworks ${L_MOD_FRAMEWORKS:-Frameworks & Libraries}"
    "editors    ${L_MOD_EDITORS:-Code Editors}"
    "terminal   ${L_MOD_TERMINAL:-Terminal & Shell}"
    "macos      ${L_MOD_MACOS:-macOS Defaults}"
    "apps       ${L_MOD_APPS:-Applications}"
    "ai         ${L_MOD_AI:-AI Coding Agents}"
    "ios        ${L_MOD_IOS:-iOS / Apple Dev}"
    "android    ${L_MOD_ANDROID:-Android Dev}"
    "dotfiles   ${L_MOD_DOTFILES:-Dotfiles Management}"
  )

  local selected=()
  for i in "${!modules[@]}"; do
    local parts=(${modules[$i]})
    local mod="${parts[0]}"
    local desc="${modules[$i]#* }"
    printf "  ${MUTED}[%d]${RESET}  ${BOLD}${WHITE}%-12s${RESET}  ${MUTED}%s${RESET}\n" \
      $((i+1)) "$mod" "$desc"
    selected+=("$mod")
  done

  ui_gap
  printf "  ${MUTED}${L_MOD_HINT:-Enter module numbers (space-separated), or 'all'}:${RESET} "
  read -r selection

  SELECTED_MODULES=()
  if [[ "$selection" == "all" ]]; then
    SELECTED_MODULES=("${selected[@]}")
  else
    for num in $selection; do
      local idx=$((num - 1))
      if [[ $idx -ge 0 && $idx -lt ${#selected[@]} ]]; then
        SELECTED_MODULES+=("${selected[$idx]}")
      fi
    done
  fi
}

# ═══════════════════════════════════════════════════════════════════
#  SYSTEM AUDIT
# ═══════════════════════════════════════════════════════════════════
run_audit() {
  ui_clear
  ui_box "${L_AUDIT_TITLE:-SYSTEM AUDIT}" "$ACCENT"

  detect_system
  local arch_label="Intel x86_64"
  [[ "$IS_APPLE_SILICON" == true ]] && arch_label="Apple Silicon M-series"

  ui_section "${L_AUDIT_SYSTEM:-SYSTEM INFO}" "◈"
  ui_kv "macOS Version"  "$MACOS_VERSION"
  ui_kv "Architecture"   "$arch_label"
  ui_kv "CPU"            "$CPU_BRAND"
  ui_kv "RAM"            "$(sysctl -n hw.memsize | awk '{printf "%.0f GB\n", $1/1073741824}')"
  ui_kv "Storage"        "$(df -h / | tail -1 | awk '{print $2" total, "$4" free"}')"
  ui_kv "Homebrew"       "${HOMEBREW_PREFIX}"

  ui_section "${L_AUDIT_LANGUAGES:-LANGUAGES}" "◈"
  _check_version "node"    "node --version"
  _check_version "npm"     "npm --version"
  _check_version "pnpm"    "pnpm --version"
  _check_version "bun"     "bun --version"
  _check_version "deno"    "deno --version" "deno"
  _check_version "python3" "python3 --version"
  _check_version "pip3"    "pip3 --version"
  _check_version "uv"      "uv --version"
  _check_version "rustc"   "rustc --version"
  _check_version "cargo"   "cargo --version"
  _check_version "go"      "go version"
  _check_version "java"    "java --version" "java"
  _check_version "ruby"    "ruby --version"
  _check_version "php"     "php --version" "php"
  _check_version "lua"     "lua -v"
  _check_version "julia"   "julia --version"
  _check_version "dart"    "dart --version"
  _check_version "flutter" "flutter --version" "flutter"
  _check_version "elixir"  "elixir --version" "elixir"
  _check_version "zig"     "zig version"
  _check_version "swift"   "swift --version"

  ui_section "${L_AUDIT_EDITORS:-EDITORS}" "◈"
  _check_cmd "code"    "VS Code"
  _check_cmd "nvim"    "Neovim"
  _check_cmd "hx"      "Helix"
  _check_cmd "cursor"  "Cursor"
  _check_version "nvim" "nvim --version" "nvim"

  ui_section "${L_AUDIT_DEVOPS:-DEVOPS}" "◈"
  _check_cmd "docker"    "Docker"
  _check_cmd "kubectl"   "kubectl"
  _check_cmd "helm"      "Helm"
  _check_cmd "k9s"       "k9s"
  _check_cmd "terraform" "Terraform"
  _check_cmd "ansible"   "Ansible"
  _check_cmd "gh"        "GitHub CLI"

  ui_section "${L_AUDIT_SHELL:-SHELL TOOLS}" "◈"
  _check_version "starship" "starship --version"
  _check_cmd "zoxide"     "zoxide"
  _check_cmd "fzf"        "fzf"
  _check_cmd "bat"        "bat"
  _check_cmd "eza"        "eza"
  _check_cmd "rg"         "ripgrep"
  _check_cmd "fd"         "fd"
  _check_cmd "just"       "just (task runner)"
  _check_cmd "lazygit"    "lazygit"
  _check_cmd "gitui"      "gitui"
  _check_cmd "tmux"       "tmux"
  _check_cmd "zellij"     "Zellij"
  _check_cmd "atuin"      "Atuin (history)"
  _check_cmd "navi"       "Navi (cheatsheets)"

  ui_section "${L_AUDIT_AI:-AI TOOLS}" "◈"
  _check_cmd "claude"     "Claude Code"
  _check_cmd "gemini"     "Gemini CLI"
  _check_cmd "aider"      "Aider"
  _check_cmd "opencode"   "OpenCode"
  _check_cmd "ollama"     "Ollama"
  _check_cmd "llm"        "LLM CLI"
  _check_cmd "mods"       "Mods (AI pipe)"

  ui_section "${L_AUDIT_ANDROID:-ANDROID DEV}" "◈"
  _check_cmd "adb"             "ADB (Android Debug Bridge)"
  _check_cmd "sdkmanager"      "SDK Manager"
  _check_cmd "avdmanager"      "AVD Manager"
  _check_cmd "gradle"          "Gradle"
  _check_cmd "kotlin"          "Kotlin"
  _check_cmd "ktlint"          "ktlint"
  _check_cmd "scrcpy"          "scrcpy"
  _check_cmd "bundletool"      "bundletool"
  _check_cmd "apktool"         "apktool"
  _check_cmd "jadx"            "jadx"
  _check_cmd "appium"          "Appium"

  ui_section "${L_AUDIT_IOS:-iOS / APPLE DEV}" "◈"
  _check_cmd "fastlane"        "Fastlane"
  _check_cmd "pod"             "CocoaPods"
  _check_cmd "carthage"        "Carthage"
  _check_cmd "xcodegen"        "XcodeGen"
  _check_cmd "tuist"           "Tuist"
  _check_cmd "swiftlint"       "SwiftLint"
  _check_cmd "swiftformat"     "SwiftFormat"
  _check_cmd "ios-deploy"      "ios-deploy"
  _check_cmd "ideviceinstaller" "ideviceinstaller"
  _check_cmd "maestro"         "Maestro"
  _check_cmd "xcbeautify"      "xcbeautify"
  _check_cmd "sentry-cli"      "Sentry CLI"
  _check_cmd "firebase"        "Firebase CLI"

  ui_section "${L_AUDIT_DOTFILES:-DOTFILES}" "◈"
  _check_cmd "chezmoi"    "chezmoi"
  _check_cmd "stow"       "GNU Stow"
  _check_cmd "mackup"     "Mackup"
  _check_cmd "yadm"       "YADM"

  ui_gap
  ui_rule_accent
  ui_gap
}

_check_version() {
  local name="${1}" cmd="${2}" display="${3:-$1}"
  if has_cmd "$name"; then
    local ver
    ver="$($cmd 2>&1 | head -1)"
    printf "  ${SUCCESS}${SYM_CHECK}${RESET}  ${WHITE}%-12s${RESET}  ${MUTED}%s${RESET}\n" "$display" "$ver"
  else
    printf "  ${MUTED}${SYM_DOT}${RESET}  ${MUTED}%-12s  not installed${RESET}\n" "$display"
  fi
}

_check_cmd() {
  local name="${1}" display="${2}"
  if has_cmd "$name"; then
    printf "  ${SUCCESS}${SYM_CHECK}${RESET}  ${WHITE}${display}${RESET}\n"
  else
    printf "  ${MUTED}${SYM_DOT}${RESET}  ${MUTED}${display} — not found${RESET}\n"
  fi
}

# ═══════════════════════════════════════════════════════════════════
#  UPDATE ALL
# ═══════════════════════════════════════════════════════════════════
run_update() {
  ui_box "${L_UPDATE_TITLE:-UPDATING ALL PACKAGES}" "$ACCENT"

  run_task "${L_UPDATE_BREW:-Updating Homebrew}"  brew update
  run_task "${L_UPDATE_BREW_UPGRADE:-Upgrading Homebrew packages}" brew upgrade
  run_task "${L_UPDATE_BREW_CLEAN:-Cleaning Homebrew cache}" brew cleanup
  has_cmd npm    && run_task "Updating npm globals"       npm update -g
  has_cmd pnpm   && run_task "Updating pnpm"              pnpm add -g pnpm@latest
  has_cmd pip3   && run_task "Updating pip"               pip3 install --upgrade pip
  has_cmd rustup && run_task "Updating Rust"              rustup update
  has_cmd go     && run_task "Updating Go tools"          go install golang.org/x/tools/...@latest
  has_cmd gem    && run_task "Updating Ruby gems"         gem update --system && gem update
  has_cmd tldr   && run_task "Updating tldr"              tldr --update

  ui_success "All packages updated ✓"
}

# ═══════════════════════════════════════════════════════════════════
#  PROFILE RUNNERS
# ═══════════════════════════════════════════════════════════════════
run_profile_full() {
  # Linux platform bootstrap first
  [[ "${_DEVFORGE_OS}" == "Linux" ]] && run_linux_platform
  run_module "core"
  run_module "languages"
  run_module "frameworks"
  run_module "editors"
  run_module "terminal"
  [[ "${_DEVFORGE_OS}" == "Darwin" ]] && run_module "macos"
  run_module "apps"
  run_module "ai"
  [[ "${_DEVFORGE_OS}" == "Darwin" ]] && run_module "ios"
  [[ "${_DEVFORGE_OS}" == "Darwin" ]] && run_module "android"
  run_module "dotfiles"
}

run_profile_ios() {
  run_module "ios"
}

run_profile_android() {
  run_module "android"
}

run_profile_mobile() {
  run_module "ios"
  run_module "android"
}

run_profile_ai() {
  run_module "ai"
}

run_profile_dotfiles() {
  run_module "dotfiles"
}

run_profile_core_languages() {
  run_module "core"
  run_module "languages"
}

run_profile_editors_terminal() {
  run_module "editors"
  run_module "terminal"
}

run_profile_devops() {
  run_module "core"
  run_module "frameworks"
}

run_profile_macos() {
  run_module "macos"
}

run_profile_apps() {
  run_module "apps"
}

run_custom() {
  show_module_menu
  for mod in "${SELECTED_MODULES[@]}"; do
    run_module "$mod"
  done
}

# ═══════════════════════════════════════════════════════════════════
#  PRE-FLIGHT CHECKS
# ═══════════════════════════════════════════════════════════════════
preflight_check() {
  detect_system

  # OS-specific checks
  if [[ "${_DEVFORGE_OS}" == "Darwin" ]]; then
    require_macos 13
  elif [[ "${_DEVFORGE_OS}" == "Linux" ]]; then
    if [[ -z "${_DEVFORGE_LINUX_DISTRO}" ]]; then
      ui_warn "Unrecognized Linux distribution. Continuing with best-effort support."
    else
      ui_info "Detected Linux distro: ${_DEVFORGE_LINUX_DISTRO}"
    fi
  else
    ui_error "Unsupported OS: ${_DEVFORGE_OS}. DevForge supports macOS 13+ and Linux."
    exit 1
  fi

  # Ensure internet
  if ! curl -s --head https://api.github.com &>/dev/null; then
    ui_error "${L_NO_INTERNET:-No internet connection detected}"
    exit 1
  fi

  # Ensure not running as root
  if [[ "${EUID}" -eq 0 ]]; then
    ui_error "${L_IS_ROOT:-Do not run as root. Run as your normal user.}"
    exit 1
  fi

  # Disk space check (need at least 10 GB free)
  local free_gb
  if [[ "${_DEVFORGE_OS}" == "Darwin" ]]; then
    free_gb=$(df -g / | tail -1 | awk '{print $4}')
  else
    free_gb=$(df -BG / | tail -1 | awk '{gsub("G","",$4); print $4}')
  fi
  if [[ "${free_gb:-0}" -lt 10 ]]; then
    ui_warn "Low disk space: ${free_gb}GB free. Recommend 10GB+ for full install."
    ui_confirm "Continue anyway?" || exit 0
  fi
}

# ═══════════════════════════════════════════════════════════════════
#  MAIN LOOP
# ═══════════════════════════════════════════════════════════════════
main() {
  # Handle --audit / --update flags
  case "${1:-}" in
    --audit)   show_splash; run_audit; exit 0 ;;
    --update)  show_splash; run_update; exit 0 ;;
    --version) echo "DevForge v${DEVFORGE_VERSION}"; exit 0 ;;
    --help)    _show_help; exit 0 ;;
  esac

  show_splash
  show_lang_selector
  show_splash  # redraw with correct language
  preflight_check

  # Confirm before starting
  ui_gap
  printf "  ${ACCENT}${BOLD}${L_READY:-Ready to forge your development environment.}${RESET}\n"
  ui_gap
  if ! ui_confirm "${L_CONTINUE:-Continue with installation?}"; then
    ui_info "${L_CANCELLED:-Installation cancelled}"
    exit 0
  fi
  ui_gap

  # Cache sudo
  cache_sudo

  # Show menu and run
  while true; do
    show_main_menu
    case "$MENU_CHOICE" in
      1) run_profile_full;             break ;;
      2) run_profile_core_languages;   break ;;
      3) run_profile_editors_terminal; break ;;
      4) run_profile_devops;           break ;;
      5) run_profile_macos;            break ;;
      6) run_profile_apps;             break ;;
      7) run_profile_ai;               break ;;
      8) run_profile_dotfiles;         break ;;
      9) run_profile_ios;              break ;;
      A|a) run_profile_android;        break ;;
      M|m) run_profile_mobile;         break ;;
      L|l) run_linux_platform;         break ;;
      T|t) switch_language;            continue ;;
      c|C) run_custom;                 break ;;
      u|U) run_update;                 break ;;
      x|X) run_audit;                  break ;;
      0) ui_info "${L_GOODBYE:-Goodbye! Happy coding! 🚀}"; exit 0 ;;
      *) ui_warn "${L_INVALID:-Invalid choice.}" ;;
    esac
  done

  # Done
  ui_gap
  ui_box "${L_COMPLETE_TITLE:-INSTALLATION COMPLETE}" "$SUCCESS"
  print_summary

  ui_gap
  printf "  ${SUCCESS}${BOLD}${L_COMPLETE_MSG:-Your macOS development environment is ready!}${RESET}\n"
  ui_gap
  printf "  ${MUTED}${L_NEXT_STEPS:-Next steps:}${RESET}\n"
  printf "    ${ACCENT}${SYM_ARROW}${RESET}  Restart your terminal or run ${ACCENT}source ~/.zshrc${RESET}\n"
  printf "    ${ACCENT}${SYM_ARROW}${RESET}  Open ${ACCENT}nvim${RESET} to trigger LazyVim plugin installation\n"
  printf "    ${ACCENT}${SYM_ARROW}${RESET}  Run ${ACCENT}./install.sh --audit${RESET} to verify your environment\n"
  printf "    ${ACCENT}${SYM_ARROW}${RESET}  Check logs at ${MUTED}${LOG_FILE}${RESET}\n"
  ui_gap
  ui_rule_accent
  ui_gap
}

# ── Help ──────────────────────────────────────────────────────────
_show_help() {
  cat << HELP

  DevForge macOS Developer Environment Setup  v${DEVFORGE_VERSION}

  USAGE:
    ./install.sh              Interactive TUI menu
    ./install.sh --audit      Scan installed tools and versions
    ./install.sh --update     Update all packages
    ./install.sh --version    Print version
    ./install.sh --help       Show this help

  MODULES:
    core        Homebrew, Xcode CLT, Zsh, Git, essential CLIs
    languages   All programming languages + version managers
    frameworks  Frameworks, libraries, DevOps, databases
    editors     VS Code, Neovim (LazyVim), Zed, Cursor, Helix
    terminal    Ghostty, Tabby, WezTerm, fonts, tmux, zellij, starship
    macos       System defaults, Dock, Finder, AeroSpace, security
    apps        Open-source apps, productivity tools, AI tools

HELP
}

main "$@"
