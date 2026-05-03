#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────
#  Module: core — DevForge macOS Setup v3.2
#  Foundation: Homebrew, Xcode CLT, CLI tools verificados, Zsh
#
#  NOMBRES DE FÓRMULA VERIFICADOS en homebrew-core 2025/2026
#  Packages marcados "|| true" son opcionales / pueden variar por arch
# ─────────────────────────────────────────────────────────────────

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

# ── Helper: brew con tap + formula en un paso ─────────────────────
brew_tap_formula() {
  local tap="${1}" formula="${2}" label="${3:-$2}"
  brew tap "${tap}" >> "${LOG_FILE}" 2>&1 || true
  brew_install "${formula}" "${label}"
}

module_core() {
  ui_section "CORE FOUNDATION" "◈"
  require_macos

  # ── 1. Xcode Command Line Tools ──────────────────────────────────
  ui_step "Xcode Command Line Tools..."
  if ! xcode-select -p &>/dev/null 2>&1; then
    ui_info "Abriendo instalador de Xcode CLT..."
    xcode-select --install 2>/dev/null || true
    ui_info "Acepta el diálogo de instalación y espera que termine."
    # Esperar a que se instale (hasta 5 min)
    local waited=0
    until xcode-select -p &>/dev/null 2>&1 || [[ $waited -gt 300 ]]; do
      sleep 10; ((waited+=10)) || true
    done
    track_ok "Xcode CLT"
  else
    track_skip "Xcode CLT (ya instalado)"
  fi

  # ── 2. Rosetta 2 (solo Apple Silicon) ────────────────────────────
  detect_system
  if [[ "$IS_APPLE_SILICON" == true ]]; then
    if ! /usr/bin/pgrep oahd &>/dev/null 2>&1; then
      ui_step "Instalando Rosetta 2..."
      softwareupdate --install-rosetta --agree-to-license 2>/dev/null || true
      track_ok "Rosetta 2"
    else
      track_skip "Rosetta 2 (instalado)"
    fi
  fi

  # ── 3. Homebrew ───────────────────────────────────────────────────
  ui_step "Homebrew package manager..."
  if ! has_cmd brew; then
    ui_info "Instalando Homebrew (puede pedir contraseña)..."
    /bin/bash -c "$(curl -fsSL \
      https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
      </dev/null 2>&1 | tee -a "${LOG_FILE}" || true

    # Añadir brew al PATH de la sesión actual
    if [[ -f /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
    track_ok "Homebrew instalado"
  else
    track_skip "Homebrew (ya instalado)"
    brew update --quiet >> "${LOG_FILE}" 2>&1 || true
  fi

  # Taps — solo los necesarios para este módulo
  # NOTA: homebrew/cask-fonts y homebrew/cask-versions fueron deprecados
  # y eliminados a finales de 2024. No los añadimos.
  ui_step "Añadiendo taps de Homebrew..."
  local taps=(
    "nikitabobko/tap"           # AeroSpace window manager
    "oven-sh/bun"               # Bun JavaScript runtime
    "mongodb/brew"              # MongoDB
    "charmbracelet/tap"         # gum, mods y otras herramientas Charm
    "arl/arl"                   # gitmux
    "pvolok/mprocs"             # mprocs (runner de procesos)
  )
  for tap in "${taps[@]}"; do
    brew tap "${tap}" >> "${LOG_FILE}" 2>&1 || true
  done
  track_ok "Homebrew listo"

  # ── 4. Control de versiones ────────────────────────────────────────
  ui_step "Herramientas de control de versiones..."
  brew_install "git"             "Git"
  brew_install "git-lfs"         "Git LFS"
  brew_install "git-delta"       "Delta (git diff mejorado)"
  brew_install "lazygit"         "LazyGit (TUI para git)"
  brew_install "gitui"           "GitUI (alternativa Rust a lazygit)"
  brew_install "tig"             "Tig (historial git en terminal)"
  brew_install "gh"              "GitHub CLI"
  brew_install "glab"            "GitLab CLI"
  brew_install "git-flow"        "Git Flow"
  # gitmux: requiere tap arl/arl (añadido arriba)
  brew_install "arl/arl/gitmux"  "Gitmux (git en barra tmux)"

  # ── 5. Red y HTTP ─────────────────────────────────────────────────
  ui_step "Herramientas de red y HTTP..."
  brew_install "curl"            "curl"
  brew_install "wget"            "wget"
  brew_install "openssh"         "OpenSSH"
  brew_install "gnupg"           "GnuPG"
  brew_install "mosh"            "Mosh (shell móvil sobre UDP)"
  brew_install "httpie"          "HTTPie (HTTP CLI amigable)"
  brew_install "xh"              "xh (HTTPie en Rust, más rápido)"
  brew_install "curlie"          "Curlie (curl + httpie)"
  brew_install "doggo"           "doggo (DNS client moderno)"   # alternativa: dig (ya en macOS)

  # ── 6. Reemplazos modernos de Unix (Rust/Go) ─────────────────────
  ui_step "Reemplazos modernos de comandos Unix..."

  # ls → eza
  brew_install "eza"                   "eza (ls moderno con colores y git)"

  # cat → bat
  brew_install "bat"                   "bat (cat con syntax highlighting)"

  # grep → ripgrep
  brew_install "ripgrep"               "ripgrep (grep en Rust, 10x más rápido)"
  brew_install "the_silver_searcher"   "ag (the silver searcher)"

  # find → fd
  brew_install "fd"                    "fd (find moderno)"

  # fuzzy finder
  brew_install "fzf"                   "fzf (fuzzy finder universal)"

  # cd → zoxide
  brew_install "zoxide"                "zoxide (cd inteligente con historial)"

  # tree interactivo
  brew_install "broot"                 "broot (navegador de árbol de directorios)"

  # du → dust
  brew_install "dust"                  "dust (du visual en Rust)"
  brew_install "ncdu"                  "ncdu (analizador de disco interactivo)"

  # df → duf
  brew_install "duf"                   "duf (df moderno con colores)"

  # top → btop
  brew_install "htop"                  "htop"
  brew_install "btop"                  "btop (monitor de recursos moderno)"
  brew_install "bottom"                "bottom (btm — gráficos en terminal)"

  # ps → procs
  brew_install "procs"                 "procs (ps moderno en Rust)"

  # sed → sd
  brew_install "sd"                    "sd (sed moderno con sintaxis clara)"

  # ── 7. Procesamiento de texto y datos ─────────────────────────────
  ui_step "Procesamiento de datos (jq, yq, CSV...)..."
  brew_install "jq"              "jq (procesador JSON)"
  brew_install "yq"              "yq (procesador YAML/JSON/XML)"
  brew_install "jless"           "jless (paginador JSON interactivo)"
  brew_install "fx"              "fx (visor JSON interactivo)"
  brew_install "jo"              "jo (constructor JSON desde shell)"
  brew_install "gron"            "gron (JSON como texto grep-able)"
  brew_install "htmlq"           "htmlq (jq para HTML)"
  # CORRECTO: el paquete se llama 'choose-rust', NO 'choose'
  brew_install "choose-rust"     "choose (alternativa a awk/cut)"
  brew_install "miller"          "Miller (CSV/JSON/TSV processor)"
  brew_install "csvkit"          "csvkit (herramientas para CSV)"

  # ── 8. Archivos y compresión ──────────────────────────────────────
  ui_step "Compresión y archivos..."
  brew_install "ouch"            "ouch (compresión/descompresión universal)"
  brew_install "p7zip"           "p7zip (7-Zip)"
  brew_install "unar"            "unar (descompresor universal)"
  brew_install "rename"          "rename (renombrado masivo por regex)"

  # ── 9. Benchmarking y análisis ────────────────────────────────────
  ui_step "Benchmarking..."
  brew_install "hyperfine"       "hyperfine (benchmark de comandos)"
  brew_install "tokei"           "Tokei (estadísticas de código)"
  brew_install "cloc"            "cloc (contador de líneas)"

  # ── 10. Servidor HTTP local ──────────────────────────────────────
  ui_step "Servidor HTTP local..."
  brew_install "miniserve"       "miniserve (servidor HTTP estático rápido)"

  # ── 11. Multiplexores de terminal ─────────────────────────────────
  ui_step "Multiplexores de terminal..."
  brew_install "tmux"            "tmux"
  brew_install "zellij"          "Zellij (multiplexor moderno con UI)"
  # mprocs: requiere tap pvolok/mprocs (añadido arriba)
  brew_install "pvolok/mprocs/mprocs" "mprocs (runner de múltiples procesos)"

  # ── 12. Shell enhancement ─────────────────────────────────────────
  ui_step "Mejoras de shell..."
  brew_install "starship"        "Starship (prompt cross-shell)"
  brew_install "atuin"           "Atuin (historial de shell en SQLite)"
  brew_install "mcfly"           "McFly (historial inteligente con ML)"
  brew_install "navi"            "Navi (cheatsheets interactivas)"
  brew_install "tldr"            "tldr (man pages simplificados)"
  brew_install "thefuck"         "thefuck (corrector de comandos)"
  brew_install "direnv"          "direnv (variables de entorno por directorio)"

  # ── 13. Task runners y build tools ───────────────────────────────
  ui_step "Task runners y build tools..."
  brew_install "just"            "just (task runner moderno, alternativa a make)"
  brew_install "cmake"           "CMake"
  brew_install "ninja"           "Ninja (build system)"
  brew_install "meson"           "Meson (build system)"
  brew_install "pkg-config"      "pkg-config"
  brew_install "autoconf"        "autoconf"
  brew_install "automake"        "automake"
  brew_install "libtool"         "libtool"

  # ── 14. TUI y herramientas visuales ──────────────────────────────
  ui_step "Herramientas TUI y visuales..."
  brew_install "gum"             "gum (Charm — TUI scripting toolkit)"
  brew_install "lolcat"          "lolcat (colores arcoíris en terminal)"
  brew_install "figlet"          "figlet (texto ASCII art)"
  brew_install "toilet"          "toilet (figlet con más estilos)"
  brew_install "cmatrix"         "cmatrix (efecto Matrix)"
  brew_install "peco"            "peco (filtro interactivo)"

  # ── 15. Análisis de código y repo ────────────────────────────────
  ui_step "Análisis y utilidades de código..."
  brew_install "onefetch"        "onefetch (info del repo con ASCII art)"
  brew_install "grex"            "grex (generador de regex desde ejemplos)"
  brew_install "ctags"           "ctags"
  brew_install "shellcheck"      "ShellCheck (linter para scripts bash)"
  brew_install "shfmt"           "shfmt (formatter para scripts bash)"

  # ── 16. Info del sistema ──────────────────────────────────────────
  ui_step "Información del sistema..."
  # neofetch fue eliminado de Homebrew en 2024 — usar fastfetch
  brew_install "fastfetch"       "fastfetch (sucesor moderno de neofetch)"
  brew_install "lnav"            "lnav (visor de logs interactivo)"

  # ── 17. Secretos y criptografía ──────────────────────────────────
  ui_step "Gestión de secretos..."
  brew_install "age"             "age (cifrado de archivos moderno)"
  brew_install "sops"            "SOPS (gestión de secretos encriptados)"
  # GnuPG ya instalado en sección Red y HTTP

  # ── 18. Utilidades misceláneas ────────────────────────────────────
  ui_step "Utilidades misceláneas..."
  brew_install "tree"            "tree"
  brew_install "watch"           "watch"
  brew_install "pv"              "pv (pipe viewer — barra de progreso)"
  brew_install "parallel"        "GNU Parallel"
  # moreutils CONFLICTA con GNU Parallel (ambos instalan el cmd 'parallel')
  # Solución: instalar moreutils con --ignore-dependencies para evitar el conflicto
  if ! brew list moreutils &>/dev/null 2>&1; then
    brew install moreutils --ignore-dependencies >> "${LOG_FILE}" 2>&1 && \
      track_ok "moreutils (sponge, vidir, ts, vipe...)" || \
      track_fail "moreutils (conflicto con GNU parallel — instala manualmente)"
  else
    track_skip "moreutils (ya instalado)"
  fi
  brew_install "imagemagick"     "ImageMagick"
  brew_install "ffmpeg"          "FFmpeg"
  brew_install "pandoc"          "Pandoc (conversor de documentos)"
  brew_install "poppler"         "Poppler (utilidades PDF)"
  brew_install "exiftool"        "ExifTool (metadatos de imágenes)"
  brew_install "mas"             "mas (Mac App Store CLI)"

  # ── 19. Oh My Zsh ─────────────────────────────────────────────────
  ui_step "Instalando Oh My Zsh..."
  if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
    env RUNZSH=no CHSH=no \
      sh -c "$(curl -fsSL \
        https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
      >> "${LOG_FILE}" 2>&1 || true
    track_ok "Oh My Zsh instalado"
  else
    track_skip "Oh My Zsh (ya instalado)"
  fi

  # ── 20. Plugins de Zsh ────────────────────────────────────────────
  ui_step "Plugins de Zsh..."
  local omz_custom="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"
  mkdir -p "${omz_custom}/plugins" 2>/dev/null || true

  # Pares "nombre|url" — usamos array indexado en vez de asociativo
  # porque bash 3.2 (el bash por defecto en macOS) NO soporta `local -A`.
  local zsh_plugins=(
    "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions"
    "zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting"
    "zsh-completions|https://github.com/zsh-users/zsh-completions"
    "fzf-tab|https://github.com/Aloxaf/fzf-tab"
    "you-should-use|https://github.com/MichaelAquilina/zsh-you-should-use"
    "zsh-history-substring-search|https://github.com/zsh-users/zsh-history-substring-search"
    "fast-syntax-highlighting|https://github.com/zdharma-continuum/fast-syntax-highlighting"
  )

  for entry in "${zsh_plugins[@]}"; do
    local plugin_name="${entry%%|*}"
    local plugin_url="${entry#*|}"
    local plugin_dir="${omz_custom}/plugins/${plugin_name}"
    if [[ ! -d "${plugin_dir}" ]]; then
      if git clone --depth=1 "${plugin_url}" "${plugin_dir}" \
           >> "${LOG_FILE}" 2>&1; then
        track_ok "Plugin: ${plugin_name}"
      else
        track_fail "Plugin: ${plugin_name} (fallo de red)"
      fi
    else
      track_skip "Plugin: ${plugin_name} (ya instalado)"
    fi
  done

  # Powerlevel10k theme
  local p10k_dir="${omz_custom}/themes/powerlevel10k"
  if [[ ! -d "${p10k_dir}" ]]; then
    git clone --depth=1 \
      https://github.com/romkatv/powerlevel10k.git "${p10k_dir}" \
      >> "${LOG_FILE}" 2>&1 || true
    track_ok "Theme: Powerlevel10k"
  fi

  # ── 21. Configuración global de Git ──────────────────────────────
  ui_step "Configuración global de Git..."

  # Delta como pager — solo si delta está disponible
  if has_cmd delta; then
    git config --global core.pager "delta" 2>/dev/null || true
    git config --global interactive.diffFilter "delta --color-only" 2>/dev/null || true
    git config --global delta.navigate true 2>/dev/null || true
    git config --global delta.light false 2>/dev/null || true
    git config --global delta.side-by-side true 2>/dev/null || true
    git config --global delta.line-numbers true 2>/dev/null || true
  fi

  git config --global merge.conflictstyle "diff3" 2>/dev/null || true
  git config --global diff.colorMoved "default" 2>/dev/null || true
  git config --global pull.rebase true 2>/dev/null || true
  git config --global fetch.prune true 2>/dev/null || true
  git config --global init.defaultBranch "main" 2>/dev/null || true
  git config --global core.autocrlf "input" 2>/dev/null || true
  git config --global rerere.enabled true 2>/dev/null || true
  git config --global rebase.autoStash true 2>/dev/null || true

  # push.autoSetupRemote requiere Git 2.37+
  local git_minor
  git_minor="$(git --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -1 | cut -d. -f2)"
  if [[ "${git_minor:-0}" -ge 37 ]]; then
    git config --global push.autoSetupRemote true 2>/dev/null || true
  fi

  # Editor (nvim si está disponible, vi como fallback)
  if has_cmd nvim; then
    git config --global core.editor "nvim" 2>/dev/null || true
  else
    git config --global core.editor "vi" 2>/dev/null || true
  fi

  # Aliases útiles
  git config --global alias.lg \
    "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit" \
    2>/dev/null || true
  git config --global alias.st   "status -sb"        2>/dev/null || true
  git config --global alias.co   "checkout"           2>/dev/null || true
  git config --global alias.br   "branch -vv"         2>/dev/null || true
  git config --global alias.df   "diff"               2>/dev/null || true
  git config --global alias.dc   "diff --cached"      2>/dev/null || true
  git config --global alias.undo "reset --soft HEAD~1" 2>/dev/null || true
  git config --global alias.last "log -1 HEAD"        2>/dev/null || true
  git config --global alias.contributors \
    "shortlog --summary --numbered"                   2>/dev/null || true

  # .gitignore global
  cat > "${HOME}/.gitignore_global" << 'GITIGNORE'
# macOS
.DS_Store
._*
.Spotlight-V100
.Trashes
.AppleDouble
.LSOverride
Icon?

# Editors / IDEs
.idea/
*.swp
*.swo
*~
.netrwhist
tags
TAGS
.vscode/settings.json
!.vscode/extensions.json
!.vscode/launch.json
!.vscode/tasks.json

# Node
node_modules/
npm-debug.log*
.pnpm-debug.log
.env.local
.env.*.local

# Python
__pycache__/
*.py[cod]
.venv/
venv/
.pytest_cache/
.mypy_cache/
.ruff_cache/
dist/
*.egg-info/

# Rust
target/

# Go
vendor/

# Secrets (¡NUNCA commitear!)
.env
*.pem
*.key
*.p12
secrets/
credentials/
GITIGNORE

  git config --global core.excludesfile "${HOME}/.gitignore_global" 2>/dev/null || true
  track_ok "Git configurado"

  ui_success "Core foundation completo ✓"
}
