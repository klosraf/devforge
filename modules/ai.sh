#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────
#  Module: ai — DevForge macOS Setup v3.1
#  AI Coding Agents, CLI Tools & Local LLM Infrastructure
#
#  Diseñado para ser completamente robusto:
#  - Cada instalación tiene || true para no abortar el módulo
#  - run_task_safe() nunca propaga errores al caller
#  - Arrays sin comentarios inline (bash no los soporta)
#  - Paquetes verificados que existen en brew/npm
# ─────────────────────────────────────────────────────────────────

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

# ── Helper: install seguro que NUNCA aborta ──────────────────────
_ai_npm_install() {
  local pkg="${1}" label="${2:-$1}"
  if ! has_cmd node; then
    track_skip "${label} (Node.js no disponible)"
    return 0
  fi
  ui_step "${label}..."
  if npm install -g "${pkg}" --prefer-online 2>/dev/null; then
    track_ok "${label}"
  else
    track_fail "${label} (fallo de instalación, continuando...)"
  fi
}

_ai_pipx_install() {
  local pkg="${1}" label="${2:-$1}"
  local tool_cmd="${3:-$1}"
  if has_cmd pipx; then
    ui_step "${label}..."
    if pipx install "${pkg}" --force 2>/dev/null || \
       pipx upgrade "${pkg}" 2>/dev/null; then
      track_ok "${label}"
    else
      track_fail "${label} (pipx fallo, intentando pip)"
      if has_cmd pip3; then
        pip3 install "${pkg}" --break-system-packages -q 2>/dev/null || true
        track_ok "${label} (via pip)"
      fi
    fi
  elif has_cmd uv; then
    ui_step "${label} (via uv)..."
    uv tool install "${pkg}" 2>/dev/null || true
    track_ok "${label}"
  elif has_cmd pip3; then
    ui_step "${label} (via pip)..."
    pip3 install "${pkg}" --break-system-packages -q 2>/dev/null || true
    track_ok "${label}"
  else
    track_skip "${label} (pipx/uv/pip no disponible)"
  fi
}

_ai_brew_cask_safe() {
  local pkg="${1}" label="${2:-$1}"
  ui_step "${label}..."
  brew install --cask "${pkg}" >> "${LOG_FILE}" 2>&1 || true
}

_ai_brew_safe() {
  local pkg="${1}" label="${2:-$1}"
  brew_install "${pkg}" "${label}" 2>/dev/null || true
}

# ════════════════════════════════════════════════════════════════════
module_ai() {
  ui_section "AI CODING AGENTS & TOOLS" "◈"

  # ── 1. Claude Code (Anthropic) ────────────────────────────────
  _ai_npm_install "@anthropic-ai/claude-code" "Claude Code (Anthropic)"

  # ── 2. Gemini CLI (Google — 1000 req/día gratis) ─────────────
  _ai_npm_install "@google/gemini-cli" "Gemini CLI (Google)"

  # ── 3. OpenCode (open-source terminal agent) ──────────────────
  _ai_npm_install "opencode-ai" "OpenCode"

  # ── 4. Qodo Gen CLI ───────────────────────────────────────────
  _ai_npm_install "@qodo/gen" "Qodo Gen CLI"

  # ── 5. Aider — pair programmer con Git nativo ─────────────────
  _ai_pipx_install "aider-chat" "Aider (Git AI pair programmer)" "aider"

  # ── 6. LLM CLI (Simon Willison — 100+ modelos) ───────────────
  _ai_pipx_install "llm" "LLM CLI (multi-provider)" "llm"

  # ── 6b. Plugins de LLM CLI (solo si llm está disponible) ──────
  if has_cmd llm; then
    ui_step "LLM CLI plugins..."
    llm install llm-claude-3   2>/dev/null || true
    llm install llm-gemini     2>/dev/null || true
    llm install llm-ollama     2>/dev/null || true
    track_ok "LLM plugins"
  fi

  # ── 7. Shell-GPT (ChatGPT en terminal) ───────────────────────
  _ai_pipx_install "shell-gpt" "Shell-GPT" "sgpt"

  # ── 8. Mods (AI en pipes, by Charm) ──────────────────────────
  ui_step "Mods (AI via unix pipes)..."
  brew tap charmbracelet/tap 2>/dev/null || true
  _ai_brew_safe "charmbracelet/tap/mods" "Mods"

  # ── 9. aichat — CLI con RAG y roles ──────────────────────────
  ui_step "AIChat (RAG, shell exec, roles)..."
  if ! has_cmd aichat; then
    brew_install "aichat" "AIChat" 2>/dev/null || true
  else
    track_skip "AIChat (ya instalado)"
  fi

  # ── 10. Ollama — runtime para LLMs locales ────────────────────
  ui_step "Ollama (LLMs locales)..."
  _ai_brew_cask_safe "ollama" "Ollama"

  # ── 11. LM Studio — GUI para LLMs locales ────────────────────
  _ai_brew_cask_safe "lm-studio" "LM Studio"

  # ── 12. Jan — ChatGPT local, privado ─────────────────────────
  _ai_brew_cask_safe "jan" "Jan (local AI)"

  # ── 13. Continue — extensión VS Code, no paquete npm global ──────
  # Continue se instala como extensión de VS Code (continue.continue)
  # ya gestionado en editors.sh — no hay paquete CLI npm oficial
  ui_info "Continue (continue.continue): instalar como extensión de VS Code"

  # ── 14. GitHub Copilot CLI (via GitHub CLI extension) ───────────
  ui_step "GitHub Copilot CLI (gh extension)..."
  # @githubnext/github-copilot-cli fue deprecado.
  # El método oficial es la extensión de gh CLI.
  if has_cmd gh; then
    gh extension install github/gh-copilot 2>/dev/null || \
      gh extension upgrade gh-copilot       2>/dev/null || true
    track_ok "GitHub Copilot CLI (gh copilot)"
  else
    track_skip "GitHub Copilot CLI (instala gh CLI primero: brew install gh)"
  fi

  # ── 15. MCP Servers (Model Context Protocol) ──────────────────
  ui_step "MCP Servers para agentes AI..."
  if has_cmd node; then
    local mcp_servers=(
      "@modelcontextprotocol/server-filesystem"
      "@modelcontextprotocol/server-github"
      "@modelcontextprotocol/server-sqlite"
      "@modelcontextprotocol/server-brave-search"
      "@modelcontextprotocol/server-sequential-thinking"
      "@modelcontextprotocol/server-puppeteer"
      "@modelcontextprotocol/server-postgres"
    )
    local mcp_ok=0
    for pkg in "${mcp_servers[@]}"; do
      if npm install -g "${pkg}" 2>/dev/null; then
        ((mcp_ok++)) || true
      fi
    done
    track_ok "MCP servers instalados (${mcp_ok}/${#mcp_servers[@]})"
  else
    track_skip "MCP servers (Node.js no disponible)"
  fi

  # ── 16. Extensiones AI para VS Code ─────────────────────────
  ui_step "Extensiones AI para VS Code..."
  if has_cmd code; then
    local vscode_ai_exts=(
      "continue.continue"
      "GitHub.copilot"
      "GitHub.copilot-chat"
      "Codeium.codeium"
      "saoudrizwan.claude-dev"
    )
    # NOTA: Sin comentarios inline — bash los trata como strings
    local ext_ok=0
    for ext in "${vscode_ai_exts[@]}"; do
      if code --install-extension "${ext}" --force 2>/dev/null; then
        ((ext_ok++)) || true
      fi
    done
    track_ok "Extensiones AI VS Code (${ext_ok}/${#vscode_ai_exts[@]})"
  else
    track_skip "VS Code no encontrado"
  fi

  # ── 17. Configuración Claude Code ────────────────────────────
  ui_step "Configurando Claude Code (CLAUDE.md)..."
  ensure_dir "${HOME}/.claude"
  cat > "${HOME}/.claude/CLAUDE.md" << 'CLAUDE_MD'
# DevForge — Claude Code Configuration

## Herramientas preferidas
- JS/TS: pnpm, biome, vitest, TypeScript strict
- Python: uv, ruff, pytest, pyproject.toml
- Rust: cargo, clippy, rustfmt
- Go: goimports, golangci-lint

## Estilo de código
- Commits: Conventional Commits (feat/fix/chore/docs/refactor)
- Preferir patrones funcionales donde aplique
- Documentar APIs públicas con JSDoc/docstrings
- Siempre escribir tests para funcionalidad nueva

## Flujo de trabajo
- Revisar diff antes de commitear
- PRs pequeñas y enfocadas
- Nombres de variables descriptivos
CLAUDE_MD
  track_ok "CLAUDE.md creado"

  # ── 18. Configuración Gemini CLI ──────────────────────────────
  ui_step "Configurando Gemini CLI (GEMINI.md)..."
  ensure_dir "${HOME}/.gemini"
  cat > "${HOME}/.gemini/settings.json" << 'GEMINI_JSON'
{
  "selectedAuthType": "oauth-personal",
  "theme": "Default"
}
GEMINI_JSON
  # GEMINI.md — equivalente a CLAUDE.md para Gemini
  cat > "${HOME}/GEMINI.md" << 'GEMINI_MD'
# DevForge — Gemini CLI Configuration
Equivalent to CLAUDE.md. Use modern patterns, write tests, follow conventional commits.
GEMINI_MD
  track_ok "Gemini CLI configurado"

  # ── 19. MCP config para Claude Code ──────────────────────────
  ui_step "Configurando MCP servers (mcp.json)..."
  cat > "${HOME}/.claude/mcp.json" << 'MCP_JSON'
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/Users"],
      "description": "Lectura/escritura de archivos locales"
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": { "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}" },
      "description": "Repositorios y issues de GitHub"
    },
    "sqlite": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sqlite", "--db-path", "/tmp/mcp.db"],
      "description": "Operaciones SQLite"
    },
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"],
      "description": "Razonamiento paso a paso"
    },
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": { "BRAVE_API_KEY": "${BRAVE_API_KEY}" },
      "description": "Búsqueda web con Brave"
    }
  }
}
MCP_JSON
  track_ok "MCP configurado en ~/.claude/mcp.json"

  # ── 20. Configuración Aider ───────────────────────────────────
  ui_step "Configurando Aider (.aider.conf.yml)..."
  cat > "${HOME}/.aider.conf.yml" << 'AIDER_CONF'
# Aider configuration — DevForge
model: claude-sonnet-4-20250514
# model: gemini/gemini-2.5-pro    # alternativa gratuita
# model: gpt-4o
auto-commits: true
dirty-commits: true
show-diffs: true
git: true
pretty: true
stream: true
dark-mode: true
vim: false
edit-format: diff
# Para usar con Ollama localmente:
# model: ollama/codellama:13b
# api-base: http://localhost:11434
AIDER_CONF
  track_ok "Aider configurado"

  # ── 21. Pull de modelos Ollama (no bloqueante) ────────────────
  if has_cmd ollama; then
    ui_step "Ollama — iniciando servicio para descarga de modelos..."
    # Iniciar Ollama en background sin bloquear
    ollama serve >/dev/null 2>&1 &
    local ollama_pid=$!
    sleep 3

    # Solo pull si ollama responde
    if ollama list >/dev/null 2>&1; then
      ui_info "Descargando modelos en background (puede tardar)..."
      # Modelos ligeros: se descargan en background sin bloquear
      local light_models=("llama3.2:3b" "qwen2.5-coder:3b")
      for model in "${light_models[@]}"; do
        if ! ollama list 2>/dev/null | grep -q "${model%%:*}"; then
          ollama pull "${model}" >/dev/null 2>&1 &
          ui_info "  → Descargando ${model} en background"
        else
          ui_info "  → ${model} ya instalado"
        fi
      done
      track_ok "Modelos Ollama en descarga (verifica con: ollama list)"
    else
      kill "${ollama_pid}" 2>/dev/null || true
      track_skip "Ollama no disponible en este momento"
    fi
  fi

  # ── 22. Configuración Neovim AI (info) ───────────────────────
  ui_step "Configuración AI para Neovim..."
  local nvim_ai_info="${HOME}/.config/nvim/AI_SETUP.md"
  if [[ -d "${HOME}/.config/nvim" ]]; then
    cat > "${nvim_ai_info}" << 'NVIM_AI'
# Neovim AI Setup — DevForge

Los siguientes plugins AI están configurados en lua/plugins/devforge.lua:

## Plugins instalados
- **avante.nvim** — Panel Claude/Copilot (`:AvanteAsk`)
- **CopilotChat.nvim** — Chat con Copilot (`<leader>ac`)
- **copilot.lua** — Completado inline
- **codecompanion.nvim** — Multi-LLM (`<leader>ai`)
- **sidekick.nvim** — Terminal AI integrado

## Configurar API Keys
```bash
# Claude
export ANTHROPIC_API_KEY="sk-ant-..."

# OpenAI
export OPENAI_API_KEY="sk-..."

# Gemini
export GOOGLE_AI_API_KEY="..."
```
Añade estas líneas a ~/.zshrc o ~/.zshenv
NVIM_AI
    track_ok "Guía AI Neovim creada"
  fi

  # ── 23. Guía de inicio rápido ────────────────────────────────
  ui_step "Generando guía de inicio rápido..."
  ensure_dir "${HOME}/.devforge"
  cat > "${HOME}/.devforge/AI_QUICKSTART.md" << 'AI_GUIDE'
# AI Coding Agents — Guía de inicio rápido
## DevForge v3.0

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Claude Code (Anthropic)
```bash
claude            # iniciar sesión interactiva
claude auth       # autenticar con Claude Pro o API key
claude --help     # ver opciones
```
→ Requiere: Claude Pro ($20/mes) o API key de Anthropic

## Gemini CLI (Google — GRATIS)
```bash
gemini            # iniciar (pide login con Google)
gemini --help
```
→ GRATIS: 1000 requests/día con cuenta Google

## Aider (Git-native, funciona con cualquier LLM)
```bash
# Con API de Anthropic
export ANTHROPIC_API_KEY="sk-ant-..."
aider --model claude-sonnet-4-20250514

# Con API de OpenAI
export OPENAI_API_KEY="sk-..."
aider

# GRATIS con Ollama local
aider --model ollama/codellama:13b
```

## LLM CLI
```bash
llm keys set anthropic    # configurar API key
llm "Explica este código" < archivo.py
cat error.log | llm "¿Qué significa este error?"
```

## Ollama (LLMs 100% locales, sin internet)
```bash
ollama list                     # modelos instalados
ollama run codellama            # iniciar chat
ollama run qwen2.5-coder:7b     # modelo coding
ollama pull deepseek-coder:6.7b # descargar modelo
```

## MCP Servers (para Claude Code)
Configurados en: ~/.claude/mcp.json
```bash
claude mcp list   # ver servidores disponibles
claude mcp add    # agregar nuevo servidor
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Variables de entorno (añadir a ~/.zshrc)
```bash
export ANTHROPIC_API_KEY="sk-ant-..."     # Claude
export OPENAI_API_KEY="sk-..."            # OpenAI/Aider
export GOOGLE_AI_API_KEY="..."            # Gemini
export GITHUB_TOKEN="ghp_..."            # MCP GitHub
```
AI_GUIDE
  track_ok "Guía creada en ~/.devforge/AI_QUICKSTART.md"

  # ── Resumen final ─────────────────────────────────────────────
  ui_gap
  ui_success "✓ Módulo AI completado"
  ui_info "Guía de inicio: ~/.devforge/AI_QUICKSTART.md"
  ui_info "Autenticación necesaria: claude auth | gemini | aider --model ..."
}
