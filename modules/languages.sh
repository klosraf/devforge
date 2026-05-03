#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────
#  Module: languages — DevForge macOS Setup v3.3
#  20+ lenguajes con gestores de versiones
#
#  CORRECCIONES v3.3:
#  - mise: comandos correctos (nodejs@lts → node@lts)
#  - Rust: instalación non-interactive correcta
#  - Java: link correcto según arquitectura
#  - Swift: tuist via tap correcto
#  - sdkman: no disponible en brew, instalación manual
#  - Todos con || true para no propagar errores
# ─────────────────────────────────────────────────────────────────

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

module_languages() {
  ui_section "PROGRAMMING LANGUAGES" "◈"
  detect_system

  # ── mise — gestor universal de versiones ─────────────────────
  ui_step "mise (gestor universal de versiones)..."
  brew_install "mise" "mise"
  if has_cmd mise; then
    eval "$(mise activate bash 2>/dev/null)" 2>/dev/null || true
  fi

  # ── Node.js ──────────────────────────────────────────────────
  ui_step "Node.js ecosystem..."
  brew_install "node"   "Node.js (LTS via brew)"
  brew_install "pnpm"   "pnpm (fast package manager)"

  # Bun — tap correcto
  brew tap "oven-sh/bun" >> "${LOG_FILE}" 2>&1 || true
  brew_install "oven-sh/bun/bun" "Bun (all-in-one JS runtime)"

  brew_install "deno"   "Deno"

  # nvm — gestor de versiones de Node
  if [[ ! -d "${HOME}/.nvm" ]]; then
    ui_step "nvm (Node Version Manager)..."
    # Bug previo: redirigir el curl a LOG_FILE antes del pipe rompía el
    # instalador (no llegaba nada a bash). Lo correcto es redirigir solo
    # stderr y dejar que bash reciba el script por stdin.
    if curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh 2>>"${LOG_FILE}" \
         | bash >> "${LOG_FILE}" 2>&1; then
      track_ok "nvm"
    else
      track_fail "nvm (ver log)"
    fi
  else
    track_skip "nvm (ya instalado)"
  fi

  # TypeScript global
  npm_global_install "typescript"   "TypeScript"
  npm_global_install "ts-node"      "ts-node"
  npm_global_install "tsx"          "tsx"
  npm_global_install "@antfu/ni"    "ni (npm/yarn/pnpm unified)"

  # ── Python ───────────────────────────────────────────────────
  ui_step "Python ecosystem..."
  brew_install "python@3.13"   "Python 3.13"
  brew_install "python@3.12"   "Python 3.12"
  brew_install "python@3.11"   "Python 3.11"
  brew_install "pyenv"         "pyenv"
  brew_install "uv"            "uv (Python package manager en Rust)"
  brew_install "pipx"          "pipx (instalar apps Python aisladas)"

  # pipx ensurepath
  if has_cmd pipx; then
    pipx ensurepath >> "${LOG_FILE}" 2>&1 || true
  fi

  # Herramientas Python via pipx (aisladas)
  local py_tools=("poetry" "pdm" "black" "ruff" "mypy" "ipython"
                  "httpie" "rich-cli" "pre-commit" "cookiecutter")
  for tool in "${py_tools[@]}"; do
    pipx install "${tool}" >> "${LOG_FILE}" 2>&1 ||
    pipx upgrade "${tool}" >> "${LOG_FILE}" 2>&1 || true
  done
  track_ok "Python tools via pipx"

  # ── Rust ─────────────────────────────────────────────────────
  ui_step "Rust ecosystem..."
  if ! has_cmd rustc; then
    ui_info "Instalando Rust via rustup..."
    # Non-interactive, sin modificar PATH automáticamente.
    # IMPORTANTE: el curl debe enviar el script al pipe; antes se redirigía
    # a LOG_FILE rompiendo la canalización a sh.
    if curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs 2>>"${LOG_FILE}" \
         | sh -s -- -y --no-modify-path --default-toolchain stable \
           >> "${LOG_FILE}" 2>&1; then
      source "${HOME}/.cargo/env" 2>/dev/null || true
      track_ok "Rust (rustup)"
    else
      track_fail "Rust (rustup — ver log)"
    fi
  else
    rustup update stable >> "${LOG_FILE}" 2>&1 || true
    track_skip "Rust (ya instalado, actualizado)"
  fi

  if has_cmd rustup; then
    # Targets para macOS universal y WASM
    local targets=("wasm32-unknown-unknown" "wasm32-wasi")
    [[ "$IS_APPLE_SILICON" == true ]] && targets+=("x86_64-apple-darwin")
    [[ "$IS_INTEL" == true ]] && targets+=("aarch64-apple-darwin")
    for target in "${targets[@]}"; do
      rustup target add "${target}" >> "${LOG_FILE}" 2>&1 || true
    done

    # Componentes esenciales
    rustup component add clippy rustfmt rust-src >> "${LOG_FILE}" 2>&1 || true
    track_ok "Rust targets y componentes"
  fi

  # Rust tools via brew (más rápido que cargo install)
  brew_install "cargo-nextest"   "cargo-nextest"
  # cargo-watch fue archivado/eliminado de crates.io y Homebrew — usar watchexec
  brew_install "watchexec"       "watchexec (file watcher, reemplazo de cargo-watch)"
  brew_install "sccache"         "sccache (build cache para Rust)"
  brew_install "mold"            "mold (fast linker — soporta macOS 2.x+)"

  # ── Go ───────────────────────────────────────────────────────
  ui_step "Go ecosystem..."
  brew_install "go" "Go"

  if has_cmd go; then
    export GOPATH="${HOME}/go"
    export GOBIN="${GOPATH}/bin"
    export PATH="${GOBIN}:${PATH}"
    mkdir -p "${GOBIN}" 2>/dev/null || true

    local go_tools=(
      "golang.org/x/tools/gopls@latest"
      "github.com/go-delve/delve/cmd/dlv@latest"
      "github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
      "mvdan.cc/gofumpt@latest"
      "github.com/cosmtrek/air@latest"
      "github.com/pressly/goose/v3/cmd/goose@latest"
      "github.com/google/wire/cmd/wire@latest"
    )
    for tool in "${go_tools[@]}"; do
      go install "${tool}" >> "${LOG_FILE}" 2>&1 || true
    done
    track_ok "Go tools"
  fi

  # ── Ruby ─────────────────────────────────────────────────────
  ui_step "Ruby ecosystem..."
  brew_install "rbenv"       "rbenv"
  brew_install "ruby-build"  "ruby-build"

  if has_cmd rbenv; then
    eval "$(rbenv init - bash 2>/dev/null)" 2>/dev/null || true
    # Instalar Ruby estable más reciente
    local ruby_ver
    ruby_ver="$(rbenv install -l 2>/dev/null | grep -E '^\s*3\.[2-9]\.' | tail -1 | tr -d ' ')"
    if [[ -n "${ruby_ver}" ]] && ! rbenv versions 2>/dev/null | grep -q "${ruby_ver}"; then
      run_task "Ruby ${ruby_ver}" rbenv install "${ruby_ver}" || true
      rbenv global "${ruby_ver}" 2>/dev/null || true
    else
      track_skip "Ruby ${ruby_ver:-latest} (ya instalado)"
    fi
    # Gems esenciales
    if has_cmd gem; then
      for gem in bundler rake rubocop solargraph; do
        gem install "${gem}" --no-document >> "${LOG_FILE}" 2>&1 || true
      done
      track_ok "Ruby gems (bundler, rubocop, solargraph)"
    fi
  fi

  # ── Java / JVM ───────────────────────────────────────────────
  ui_step "Java / JVM ecosystem..."
  brew_install "openjdk@21"    "OpenJDK 21 (LTS)"
  brew_install "openjdk@17"    "OpenJDK 17 (LTS)"
  brew_install "maven"         "Maven"
  brew_install "gradle"        "Gradle"
  brew_install "kotlin"        "Kotlin"
  brew_install "scala"         "Scala"
  brew_install "sbt"           "sbt (Scala build tool)"
  brew_install "clojure"       "Clojure"
  brew_install "leiningen"     "Leiningen (Clojure)"
  brew_install "groovy"        "Groovy"

  # Symlink Java para que funcione JAVA_HOME
  local jdk_base="${HOMEBREW_PREFIX}/opt/openjdk@21"
  if [[ -d "${jdk_base}" ]]; then
    sudo ln -sfn "${jdk_base}/libexec/openjdk.jdk" \
      /Library/Java/JavaVirtualMachines/openjdk-21.jdk 2>/dev/null || true
    track_ok "Java symlink /Library/Java/JavaVirtualMachines/openjdk-21.jdk"
  fi

  # ── PHP ──────────────────────────────────────────────────────
  ui_step "PHP..."
  brew_install "php"        "PHP (última LTS)"
  brew_install "composer"   "Composer"

  # ── Swift ────────────────────────────────────────────────────
  ui_step "Swift ecosystem..."
  brew_install "swiftlint"      "SwiftLint"
  brew_install "swiftformat"    "SwiftFormat"
  brew_install "xcodegen"       "XcodeGen"
  # Tuist via su tap oficial
  brew tap "tuist/tuist" >> "${LOG_FILE}" 2>&1 || true
  brew_install "tuist/tuist/tuist" "Tuist"

  # ── Dart & Flutter ───────────────────────────────────────────
  ui_step "Dart & Flutter..."

  # Dart: tap oficial dart-lang/dart
  brew tap "dart-lang/dart" >> "${LOG_FILE}" 2>&1 || true
  brew_install "dart-lang/dart/dart" "Dart SDK"

  # Flutter: el cask fue eliminado de homebrew-cask (~2023)
  # Método recomendado: FVM (Flutter Version Manager)
  ui_step "Flutter via FVM (Flutter Version Manager)..."
  brew_install "leoafarias/fvm/fvm" "FVM"
  # Fallback: intentar tap explícito si brew no encontró el paquete (brew_install siempre devuelve 0)
  if ! has_cmd fvm 2>/dev/null; then
    brew tap "leoafarias/fvm" >> "${LOG_FILE}" 2>&1 || true
    brew_install "fvm" "FVM"
  fi

  if has_cmd fvm; then
    # Instalar Flutter stable via FVM
    run_task "Flutter stable (via fvm)"       fvm install stable || true
    fvm global stable >> "${LOG_FILE}" 2>&1 || true

    # Añadir flutter de FVM al PATH
    local fvm_flutter="${HOME}/fvm/default/bin"
    if [[ -d "${fvm_flutter}" ]]; then
      export PATH="${fvm_flutter}:${PATH}"
    fi
    track_ok "Flutter SDK (via fvm — ejecuta: fvm flutter doctor)"
  else
    # Fallback: instalación directa vía git clone
    ui_step "Flutter fallback — instalación directa..."
    local flutter_dir="${HOME}/development/flutter"
    if [[ ! -d "${flutter_dir}" ]]; then
      ensure_dir "${HOME}/development"
      git clone --depth=1         https://github.com/flutter/flutter.git         "${flutter_dir}"         >> "${LOG_FILE}" 2>&1 && track_ok "Flutter (git clone)" || track_fail "Flutter"
    else
      track_skip "Flutter (ya existe en ${flutter_dir})"
    fi
    ui_info "Añade Flutter al PATH: export PATH=\"${HOME}/development/flutter/bin:\$PATH\""
  fi

  # Post-install si flutter está disponible
  if has_cmd flutter || has_cmd fvm; then
    (fvm flutter config --no-analytics 2>/dev/null ||      flutter config --no-analytics 2>/dev/null) >> "${LOG_FILE}" 2>&1 || true
    track_ok "Flutter analytics desactivado"
  fi

  # ── Elixir ───────────────────────────────────────────────────
  ui_step "Elixir / Erlang..."
  brew_install "erlang"  "Erlang/OTP"
  brew_install "elixir"  "Elixir"
  if has_cmd mix; then
    mix local.hex --force >> "${LOG_FILE}" 2>&1 || true
    mix local.rebar --force >> "${LOG_FILE}" 2>&1 || true
    mix archive.install hex phx_new --force >> "${LOG_FILE}" 2>&1 || true
    track_ok "Elixir hex + Phoenix"
  fi

  # ── Haskell ──────────────────────────────────────────────────
  ui_step "Haskell..."
  ui_step "Haskell (via GHCup -- metodo oficial)..."
  # GHC via brew falla en macOS moderno: ~2GB, Apple Silicon incompatible
  if ! has_cmd ghcup; then
    ui_info "Instalando GHCup..."
    curl --proto "=https" --tlsv1.2 -sSf https://get-ghcup.haskell.org \
      | BOOTSTRAP_HASKELL_NONINTERACTIVE=1 \
        BOOTSTRAP_HASKELL_INSTALL_STACK=1 \
        BOOTSTRAP_HASKELL_INSTALL_HLS=1 \
        BOOTSTRAP_HASKELL_ADJUST_BASHRC=P \
        sh >> "${LOG_FILE}" 2>&1 \
      && track_ok "GHCup + GHC + Cabal + Stack + HLS" \
      || track_fail "GHCup (ver log)"
    source "${HOME}/.ghcup/env" 2>/dev/null || true
  else
    track_skip "GHCup (ya instalado)"
    ghcup upgrade >> "${LOG_FILE}" 2>&1 || true
  fi

  # ── Zig ──────────────────────────────────────────────────────
  ui_step "Zig..."
  brew_install "zig" "Zig"
  brew_install "zls" "ZLS (Zig LSP)"

  # ── C / C++ ──────────────────────────────────────────────────
  ui_step "C / C++ ecosystem..."
  brew_install "llvm"         "LLVM / Clang"
  brew_install "gcc"          "GCC"
  brew_install "ccache"       "ccache"
  brew_install "cppcheck"     "cppcheck (análisis estático C++)"
  brew_install "conan"        "Conan (C++ package manager)"
  # clang-format viene con llvm, no necesita paquete separado
  # GDB no soportado en macOS Apple Silicon (usar lldb)
  if [[ "$IS_INTEL" == true ]]; then
    brew_install "gdb" "GDB" 2>/dev/null || true
  fi

  # ── Lua ──────────────────────────────────────────────────────
  brew_install "lua"                  "Lua"
  brew_install "luarocks"             "LuaRocks"
  brew_install "lua-language-server"  "Lua LSP"

  # ── R ────────────────────────────────────────────────────────
  brew_install "r" "R (estadística)"

  # ── Julia ────────────────────────────────────────────────────
  brew_install "julia" "Julia"

  # ── Perl ─────────────────────────────────────────────────────
  brew_install "perl" "Perl"

  # ── Bash ─────────────────────────────────────────────────────
  ui_step "Bash / Shell tools..."
  brew_install "bash"         "Bash 5 (más moderno que el del sistema)"
  brew_install "shellcheck"   "ShellCheck (linter bash)"
  brew_install "shfmt"        "shfmt (formatter bash)"
  brew_install "bats-core"    "BATS (bash automated testing)"

  # ── WebAssembly ──────────────────────────────────────────────
  ui_step "WebAssembly toolchain..."
  brew_install "wasmtime"     "Wasmtime (runtime WASM)"
  brew_install "wasmer"       "Wasmer"
  brew_install "wasm-pack"    "wasm-pack (Rust→WASM)"
  brew_install "wasm-tools"   "wasm-tools"

  # ── LSP servers para editores ────────────────────────────────
  ui_step "Language Server Protocol servers..."
  # Via npm
  npm_global_install "typescript-language-server"   "TypeScript LSP"
  npm_global_install "vscode-langservers-extracted"  "HTML/CSS/JSON LSP"
  npm_global_install "@tailwindcss/language-server"  "Tailwind CSS LSP"
  npm_global_install "pyright"                       "Pyright (Python LSP)"
  npm_global_install "yaml-language-server"          "YAML LSP"
  npm_global_install "graphql-language-service-cli"  "GraphQL LSP"
  npm_global_install "@volar/vue-language-server"    "Vue LSP"
  npm_global_install "svelte-language-server"        "Svelte LSP"
  npm_global_install "bash-language-server"          "Bash LSP"
  npm_global_install "@astrojs/language-server"      "Astro LSP"
  # Via brew
  brew_install "taplo"         "TOML LSP (taplo)"
  # marksman: probar brew primero, fallback a cargo install
  if ! brew install marksman >> "${LOG_FILE}" 2>&1; then
    brew tap "artempyanykh/homebrew-marksman" >> "${LOG_FILE}" 2>&1 || true
    if ! brew install artempyanykh/homebrew-marksman/marksman >> "${LOG_FILE}" 2>&1; then
      # Último fallback: cargo (requiere Rust)
      if has_cmd cargo; then
        cargo install marksman >> "${LOG_FILE}" 2>&1 &&           track_ok "Markdown LSP (marksman via cargo)" ||           track_fail "Markdown LSP (marksman — todos los métodos fallaron)"
      else
        track_fail "Markdown LSP (marksman — instala manualmente desde github.com/artempyanykh/marksman)"
      fi
    else
      track_ok "Markdown LSP (marksman via tap)"
    fi
  else
    track_ok "Markdown LSP (marksman)"
  fi

  ui_success "Todos los lenguajes listos ✓"
}
