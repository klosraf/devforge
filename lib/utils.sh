#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────
#  Utils Library — DevForge macOS Setup v3.3
#
#  PRINCIPIO: ninguna función propaga errores. set -euo pipefail safe.
#  Cada fallo se loguea y se registra en FAILED_ITEMS[] pero
#  el script principal NUNCA se aborta por un paquete opcional.
# ─────────────────────────────────────────────────────────────────

source "$(dirname "${BASH_SOURCE[0]}")/ui.sh"
source "$(dirname "${BASH_SOURCE[0]}")/lang.sh"

# ── Log ──────────────────────────────────────────────────────────
DEVFORGE_LOG_DIR="${HOME}/.devforge/logs"
mkdir -p "${DEVFORGE_LOG_DIR}" 2>/dev/null || true
LOG_FILE="${DEVFORGE_LOG_DIR}/install-$(date +%Y%m%d-%H%M%S).log"
touch "${LOG_FILE}" 2>/dev/null || LOG_FILE="/tmp/devforge-install.log"

# ── Trackers ──────────────────────────────────────────────────────
INSTALLED_ITEMS=()
FAILED_ITEMS=()
SKIPPED_ITEMS=()
track_ok()   { INSTALLED_ITEMS+=("$*"); echo "[OK]   $*" >> "${LOG_FILE}"; }
track_fail() { FAILED_ITEMS+=("$*");   echo "[FAIL] $*" >> "${LOG_FILE}"; }
track_skip() { SKIPPED_ITEMS+=("$*");  echo "[SKIP] $*" >> "${LOG_FILE}"; }

# Usar L_INSTALLING si está definido, sino fallback a "Installing"
_l_installing() { echo "${L_INSTALLING:-Installing}"; }
_l_skipped()    { echo "${L_SKIPPED:-Skipped}"; }
_l_failed()     { echo "${L_FAILED:-Failed}"; }

ui_log() { echo "[$1] $2" >> "${LOG_FILE}" 2>/dev/null || true; }

# ── Sistema ───────────────────────────────────────────────────────
detect_system() {
  OS="$(uname -s 2>/dev/null || echo Darwin)"
  ARCH="$(uname -m 2>/dev/null || echo arm64)"
  MACOS_VERSION="$(sw_vers -productVersion 2>/dev/null || echo '15.0')"
  MACOS_MAJOR="$(echo "$MACOS_VERSION" | cut -d. -f1)"
  MACOS_MINOR="$(echo "$MACOS_VERSION" | cut -d. -f2)"
  CPU_BRAND="$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo 'Apple Silicon')"
  IS_APPLE_SILICON=false; IS_INTEL=false
  [[ "$ARCH" == "arm64"  ]] && IS_APPLE_SILICON=true
  [[ "$ARCH" == "x86_64" ]] && IS_INTEL=true
  HOMEBREW_PREFIX="/usr/local"
  [[ "$IS_APPLE_SILICON" == true ]] && HOMEBREW_PREFIX="/opt/homebrew"
  export OS ARCH MACOS_VERSION MACOS_MAJOR MACOS_MINOR CPU_BRAND \
         IS_APPLE_SILICON IS_INTEL HOMEBREW_PREFIX
}

has_cmd() { command -v "$1" &>/dev/null 2>&1; }

# ── run_task: spinner + comando, NUNCA propaga error ─────────────
run_task() {
  local label="${1}"; shift
  ui_spinner_start "$label"
  local rc=0
  "$@" >> "${LOG_FILE}" 2>&1 || rc=$?
  if [[ $rc -eq 0 ]]; then
    ui_spinner_done "$label"
    return 0
  else
    ui_spinner_fail "Falló: $label"
    echo "[FAIL-CMD] $*" >> "${LOG_FILE}"
    return 1
  fi
}

# ── _brew_is_already_installed: detecta mensajes de "ya instalado" ──
_brew_is_already_installed() {
  # Devuelve 0 (true) si el output de brew indica que el paquete
  # ya estaba instalado fuera de Homebrew o en otra versión.
  printf '%s' "${1}" | grep -qiE \
    "already installed|already exists|It seems there is already|is already installed"
}

# ── brew_install — siempre devuelve 0 ────────────────────────────
brew_install() {
  local pkg="${1}" label="${2:-$1}"
  # Verificar si ya está instalado (fórmula o tap/fórmula)
  local formula="${pkg##*/}"  # ej: hashicorp/tap/terraform → terraform
  if brew list "${formula}" &>/dev/null 2>&1; then
    track_skip "${label}"
    return 0
  fi
  ui_spinner_start "${L_INSTALLING:-Installing} ${label}"
  local output rc=0
  output=$(brew install "${pkg}" 2>&1) || rc=$?
  printf '%s\n' "${output}" >> "${LOG_FILE}"
  if [[ $rc -eq 0 ]]; then
    ui_spinner_done "${L_INSTALLING:-Installing} ${label}"
    track_ok "${label}"
  elif _brew_is_already_installed "${output}"; then
    # App ya existe (instalada fuera de Homebrew) — omitir sin error
    ui_spinner_done "${L_INSTALLING:-Installing} ${label}"
    track_skip "${label}"
  else
    ui_spinner_fail "Falló: ${L_INSTALLING:-Installing} ${label}"
    echo "[FAIL-CMD] brew install ${pkg}" >> "${LOG_FILE}"
    track_fail "${label}"
  fi
  return 0
}

# ── brew_cask_install — siempre devuelve 0 ───────────────────────
brew_cask_install() {
  local pkg="${1}" label="${2:-$1}"
  local formula="${pkg##*/}"
  if brew list --cask "${formula}" &>/dev/null 2>&1; then
    track_skip "${label}"
    return 0
  fi
  ui_spinner_start "${L_INSTALLING:-Installing} ${label}"
  local output rc=0
  output=$(brew install --cask --no-quarantine "${pkg}" 2>&1) || rc=$?
  printf '%s\n' "${output}" >> "${LOG_FILE}"
  if [[ $rc -eq 0 ]]; then
    ui_spinner_done "${L_INSTALLING:-Installing} ${label}"
    track_ok "${label}"
  elif _brew_is_already_installed "${output}"; then
    # App ya existe en /Applications (instalada fuera de Homebrew) — omitir sin error
    ui_spinner_done "${L_INSTALLING:-Installing} ${label}"
    track_skip "${label}"
  else
    ui_spinner_fail "Falló: ${L_INSTALLING:-Installing} ${label}"
    echo "[FAIL-CMD] brew install --cask --no-quarantine ${pkg}" >> "${LOG_FILE}"
    track_fail "${label}"
  fi
  return 0
}

brew_tap() {
  local tap="${1}"
  brew tap "${tap}" >> "${LOG_FILE}" 2>&1 || true
}

# ── npm_global — siempre devuelve 0 ──────────────────────────────
npm_global_install() {
  local pkg="${1}" label="${2:-$1}"
  if ! has_cmd node; then track_skip "${label} (no Node.js)"; return 0; fi
  local bin_name="${pkg##*/}"
  bin_name="${bin_name##@*/}"
  if npm list -g --depth=0 "${pkg}" &>/dev/null 2>&1; then
    track_skip "${label}"
    return 0
  fi
  if run_task "${L_INSTALLING:-Installing} ${label}" npm install -g "${pkg}" --prefer-online; then
    track_ok "${label}"
  else
    track_fail "${label}"
  fi
  return 0
}

# ── pip_install — siempre devuelve 0 ─────────────────────────────
pip_install() {
  local pkg="${1}" label="${2:-$pkg}"
  if run_task "${L_INSTALLING:-Installing} ${label}" \
       pip3 install --quiet --break-system-packages "${pkg}"; then
    track_ok "${label}"
  else
    track_fail "${label}"
  fi
  return 0
}

# ── cargo_install — siempre devuelve 0 ───────────────────────────
cargo_install_pkg() {
  local pkg="${1}" label="${2:-$pkg}"
  if ! has_cmd cargo; then track_skip "${label} (no Cargo)"; return 0; fi
  local bin="${pkg%%-[0-9]*}"  # strip version
  if cargo install --list 2>/dev/null | grep -q "^${bin} "; then
    track_skip "${label}"
    return 0
  fi
  if run_task "${L_INSTALLING:-Installing} ${label}" cargo install "${pkg}"; then
    track_ok "${label}"
  else
    track_fail "${label}"
  fi
  return 0
}

# ── go_install — siempre devuelve 0 ──────────────────────────────
go_install_pkg() {
  local pkg="${1}" label="${2:-$pkg}"
  if ! has_cmd go; then track_skip "${label} (no Go)"; return 0; fi
  if run_task "${L_INSTALLING:-Installing} ${label}" go install "${pkg}"; then
    track_ok "${label}"
  else
    track_fail "${label}"
  fi
  return 0
}

# ── pipx_install — siempre devuelve 0 ────────────────────────────
pipx_install() {
  local pkg="${1}" label="${2:-$pkg}"
  if has_cmd pipx; then
    if pipx install "${pkg}" --force >> "${LOG_FILE}" 2>&1 ||
       pipx upgrade "${pkg}"         >> "${LOG_FILE}" 2>&1; then
      track_ok "${label}"
    else
      track_fail "${label}"
    fi
  elif has_cmd pip3; then
    pip3 install "${pkg}" --break-system-packages -q >> "${LOG_FILE}" 2>&1 || true
    track_ok "${label} (via pip)"
  else
    track_skip "${label} (no pipx/pip)"
  fi
  return 0
}

# ── Helpers ───────────────────────────────────────────────────────
ensure_dir() { mkdir -p "$1" 2>/dev/null || true; }

link_file() {
  local src="${1}" dst="${2}"
  mkdir -p "$(dirname "$dst")" 2>/dev/null || true
  [[ -e "$dst" && ! -L "$dst" ]] && cp "$dst" "${dst}.bak.$(date +%s)" 2>/dev/null || true
  ln -sf "$src" "$dst" 2>/dev/null || true
}

cache_sudo() {
  ui_info "${L_SUDO_NEEDED:-Administrator access required...}"
  sudo -v 2>/dev/null || true
  while true; do sudo -n true 2>/dev/null || break; sleep 60; kill -0 "$$" 2>/dev/null || break; done &
}

require_macos() {
  local min="${1:-13}"
  [[ "$(uname -s 2>/dev/null)" != "Darwin" ]] && { ui_error "Este script requiere macOS"; exit 1; }
  local major; major="$(sw_vers -productVersion 2>/dev/null | cut -d. -f1)"
  [[ "${major:-0}" -lt "${min}" ]] && { ui_error "Se requiere macOS ${min}+"; exit 1; }
  true
}

append_to_zshrc() {
  local content="${1}" marker="${2:-devforge}"
  local zshrc="${HOME}/.zshrc"; touch "${zshrc}"
  grep -qF "# ${marker}" "${zshrc}" 2>/dev/null || printf "\n# %s\n%s\n" "${marker}" "${content}" >> "${zshrc}"
}

git_clone_or_pull() {
  local url="${1}" dest="${2}" label="${3:-repo}"
  if [[ -d "${dest}/.git" ]]; then
    git -C "${dest}" pull --quiet --ff-only >> "${LOG_FILE}" 2>&1 || true
  else
    git clone --quiet --depth=1 "${url}" "${dest}" >> "${LOG_FILE}" 2>&1 || true
  fi
}

print_summary() {
  ui_gap; ui_box "${L_SUMMARY_TITLE:-SUMMARY}" "$ACCENT"
  ui_kv "${L_SUMMARY_INSTALLED:-Installed}"  "${#INSTALLED_ITEMS[@]} ${L_SUMMARY_PACKAGES:-packages}"
  ui_kv "${L_SUMMARY_SKIPPED:-Skipped}"     "${#SKIPPED_ITEMS[@]} ${L_SUMMARY_ALREADY:-already present}"
  ui_kv "${L_SUMMARY_FAILED:-Failed}"       "${#FAILED_ITEMS[@]} ${L_SUMMARY_PACKAGES:-packages}"
  ui_kv "${L_SUMMARY_LOG:-Log file}"        "${LOG_FILE}"
  if [[ "${#FAILED_ITEMS[@]}" -gt 0 ]]; then
    ui_gap; ui_warn "${L_SUMMARY_FAILURES:-Packages with errors (see log):}"
    for item in "${FAILED_ITEMS[@]}"; do
      printf "    ${RED}✗${RESET}  ${MUTED}%s${RESET}\n" "${item}"
    done
  fi
  ui_gap
}

# ════════════════════════════════════════════════════════════════════
#  UPGRADE UTILITIES
#  Maintenance functions for keeping the dev environment up to date.
#  Source this file in ~/.zshrc or ~/.bash_profile, then call:
#    devforge_upgrade  — upgrades all components
# ════════════════════════════════════════════════════════════════════

# ── Pretty-print and execute a shell command ──────────────────────
exec_cmd() {
  printf "%s" "$@" | awk \
    'BEGIN {
      RESET="\033[0m"; BOLD="\033[1m"; UNDERLINE="\033[4m"; UNDERLINEOFF="\033[24m";
      RED="\033[31m"; GREEN="\033[32m"; YELLOW="\033[33m"; WHITE="\033[37m"; GRAY="\033[90m";
      IDENTIFIER="[_a-zA-Z][_a-zA-Z0-9]*"; idx=0; in_string=0; double_quoted=1;
      printf("%s$",RESET BOLD WHITE);
    }
    {
      for(i=1;i<=NF;++i){
        style=WHITE; post_style=WHITE;
        if(!in_string){
          if($i~/^-/) style=YELLOW;
          else if($i=="sudo"&&idx==0){style=UNDERLINE GREEN;post_style=UNDERLINEOFF WHITE;}
          else if($i~"^"IDENTIFIER"="&&idx==0){
            style=GRAY;
            if($i~"^"IDENTIFIER"=[\"'"'"']"){in_string=1;double_quoted=($i~"^"IDENTIFIER"=\"");}
          }
          else if($i~/^[12&]?>>?/||$i=="\\") style=RED;
          else{
            ++idx;
            if($i~/^["'"'"']/){in_string=1;double_quoted=($i~/^"/);}
            if(idx==1) style=GREEN;
          }
        }
        if(in_string){
          if(style==WHITE) style="";
          post_style="";
          if((double_quoted&&$i~/";?$/&&$i!~/\\";?$/)||(!double_quoted&&$i~/'"'"';?$/)) in_string=0;
        }
        if(($i~/;$/&&$i!~/\\;$/)||$i=="|"||$i=="||"||$i=="&&"){
          if(!in_string){idx=0;if($i!~/;$/) style=RED;}
        }
        if($i~/;$/&&$i!~/\\;$/) printf(" %s%s%s;%s",style,substr($i,1,length($i)-1),(in_string?WHITE:RED),post_style);
        else printf(" %s%s%s",style,$i,post_style);
        if($i=="\\") printf("\n\t");
      }
    }
    END{printf("%s\n",RESET);}' >&2
  eval "$@"
}

# ── Upgrade Homebrew ──────────────────────────────────────────────
devforge_upgrade_homebrew() {
  exec_cmd 'brew update --verbose'
  exec_cmd 'brew outdated --greedy'
  exec_cmd 'brew upgrade'
  exec_cmd 'brew autoremove --verbose'
  exec_cmd 'brew cleanup --scrub --prune 7'
}

# ── Upgrade Oh My Zsh + plugins ───────────────────────────────────
devforge_upgrade_ohmyzsh() {
  local repo
  export ZSH="${ZSH:-"${HOME}/.oh-my-zsh"}"
  export ZSH_CUSTOM="${ZSH_CUSTOM:-"${ZSH}/custom"}"
  export ZSH_CACHE_DIR="${ZSH_CACHE_DIR:-"${ZSH}/cache"}"
  rm -f "${ZSH_CACHE_DIR}/.zsh-update" 2>/dev/null || true
  zsh "${ZSH}/tools/check_for_upgrade.sh" 2>/dev/null || true
  exec_cmd 'zsh "${ZSH}/tools/upgrade.sh"'
  exec_cmd 'git -C "${ZSH}" fetch --prune'
  exec_cmd 'git -C "${ZSH}" gc --prune=all'
  while read -r repo; do
    exec_cmd "git -C \"\${ZSH_CUSTOM}/${repo}\" pull --prune --ff-only"
    exec_cmd "git -C \"\${ZSH_CUSTOM}/${repo}\" gc --prune=all"
  done < <(
    cd "${ZSH_CUSTOM}" &&
      find -L . -mindepth 3 -maxdepth 3 -not -empty -type d -name '.git' -prune -exec dirname '{}' ';' |
      cut -c3-
  )
  rm -f "${ZSH_COMPDUMP:-"${ZDOTDIR:-"${HOME}"}/.zcompdump"}" &>/dev/null || true
}

# ── Upgrade fzf ───────────────────────────────────────────────────
devforge_upgrade_fzf() {
  exec_cmd 'git -C "${HOME}/.fzf" pull --prune --ff-only'
  exec_cmd 'git -C "${HOME}/.fzf" gc --prune=all'
  exec_cmd '"${HOME}/.fzf/install" --key-bindings --completion --no-update-rc'
}

# ── Upgrade Vim plugins ───────────────────────────────────────────
devforge_upgrade_vim() {
  exec_cmd 'vim -c "PlugUpgrade | PlugUpdate | sleep 5 | quitall"'
}

# ── Pull all Git projects under a base dir ────────────────────────
devforge_pull_projects() {
  local base_dirs=("${@:-"${HOME}/Projects"}")
  local base_dir proj_dir branch remote old_hash new_hash push_remote timestamp

  timestamp="$(date +"%s")"

  for base_dir in "${base_dirs[@]}"; do
    while read -r proj_dir; do
      branch="$(git -C "${proj_dir}" branch --show-current 2>/dev/null)"
      remote="$(git -C "${proj_dir}" config branch."${branch}".remote 2>/dev/null)"
      [[ -z "${branch}" || -z "${remote}" ]] && continue
      exec_cmd "git -C \"${proj_dir/#${HOME}/\${HOME\}}\" fetch --all --prune"
      old_hash="$(git -C "${proj_dir}" rev-parse "${branch}" 2>/dev/null)"
      new_hash="$(git -C "${proj_dir}" rev-parse "${remote}/${branch}" 2>/dev/null)"
      if [[ "${new_hash}" != "${old_hash}" ]]; then
        exec_cmd "git -C \"${proj_dir/#${HOME}/\${HOME\}}\" pull ${remote} ${branch} --ff-only"
        local last_ts commit_count
        last_ts="$(git -C "${proj_dir}" config gc.lasttimestamp 2>/dev/null || echo 0)"
        if (( timestamp - last_ts >= 86400 * 3 )); then
          commit_count="$(git -C "${proj_dir}" rev-list --count --all 2>/dev/null || echo 0)"
          if (( commit_count <= 10000 || timestamp - last_ts >= 86400 * 30 )); then
            exec_cmd "git -C \"${proj_dir/#${HOME}/\${HOME\}}\" gc --aggressive"
            git -C "${proj_dir}" config gc.lasttimestamp "${timestamp}" &>/dev/null || true
          fi
        fi
      fi
      push_remote="$(git -C "${proj_dir}" config branch."${branch}".pushremote 2>/dev/null)"
      if [[ -n "${push_remote}" ]]; then
        local push_hash
        push_hash="$(git -C "${proj_dir}" rev-parse "${push_remote}/${branch}" 2>/dev/null)"
        [[ "${new_hash}" != "${push_hash}" ]] && \
          exec_cmd "git -C \"${proj_dir/#${HOME}/\${HOME\}}\" push ${push_remote} ${branch} || true"
      fi
    done < <(find -L "${base_dir}" -maxdepth 5 -not -empty -type d -name '.git' -prune -exec dirname '{}' ';' 2>/dev/null)
  done
}

# ── Proxy helpers ─────────────────────────────────────────────────
devforge_set_proxy() {
  local host="${1:-"127.0.0.1"}"
  local http_port="${2:-"7890"}"
  local https_port="${3:-"7890"}"
  local ftp_port="${4:-"7890"}"
  local socks_port="${5:-"7891"}"
  export http_proxy="http://${host}:${http_port}"
  export https_proxy="http://${host}:${https_port}"
  export ftp_proxy="http://${host}:${ftp_port}"
  export all_proxy="socks5://${host}:${socks_port}"
}

devforge_reset_proxy() {
  unset http_proxy https_proxy ftp_proxy all_proxy
}

# ── Kill dangling Python processes ────────────────────────────────
devforge_pykill() {
  local pids
  while true; do
    pids="$(pgrep -f -d ' ' -P 1 -U "${USER}" '[Pp]ython3?' 2>/dev/null || true)"
    [[ -z "${pids}" ]] && break
    exec_cmd "ps -o 'pid,user,ppid,pgid,%cpu,%mem,rss,state,time,command' -p ${pids}"
    exec_cmd "kill -KILL ${pids}"
    sleep 1
  done
}

# ── Master upgrade ────────────────────────────────────────────────
devforge_upgrade() {
  unset __DEVFORGE_HAVE_SUDO
  devforge_upgrade_homebrew
  devforge_upgrade_ohmyzsh
  devforge_upgrade_fzf
  devforge_upgrade_vim

  # Reload shell config
  if [[ -n "${ZSH_VERSION:-}" ]]; then
    rm -f "${ZSH_COMPDUMP:-"${ZDOTDIR:-"${HOME}"}/.zcompdump"}" &>/dev/null || true
    [[ -f "${ZDOTDIR:-"${HOME}"}/.zshrc" ]] && source "${ZDOTDIR:-"${HOME}"}/.zshrc"
  elif [[ -n "${BASH_VERSION:-}" ]]; then
    if [[ -f "${HOME}/.bash_profile" ]]; then source "${HOME}/.bash_profile"
    elif [[ -f "${HOME}/.profile" ]]; then source "${HOME}/.profile"; fi
  fi
}
