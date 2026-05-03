#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────
#  Module: editors — DevForge macOS Setup v3.0
#  VS Code, Cursor, Zed, Neovim, Helix, JetBrains, Emacs
# ─────────────────────────────────────────────────────────────────

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

module_editors() {
  ui_section "EDITORS & IDEs" "◈"

  # ── VS Code ──────────────────────────────────────────────────────
  ui_step "Visual Studio Code..."
  brew_cask_install "visual-studio-code" "VS Code"
  _install_vscode_extensions
  _write_vscode_settings
  _write_vscode_keybindings

  # ── Cursor — AI-first editor ──────────────────────────────────
  ui_step "Cursor (AI-first VS Code fork)..."
  brew_cask_install "cursor" "Cursor"

  # ── Zed — next-gen collaborative editor ───────────────────────
  ui_step "Zed (Rust-powered modern editor)..."
  brew_cask_install "zed" "Zed"
  _write_zed_settings

  # ── Neovim + LazyVim ──────────────────────────────────────────
  ui_step "Neovim + LazyVim + plugins..."
  brew_install "neovim" "Neovim"
  _setup_neovim

  # ── Helix — modal editor with built-in LSP ────────────────────
  ui_step "Helix (batteries-included modal editor)..."
  brew_install "helix" "Helix"
  _write_helix_config

  # ── JetBrains Toolbox ─────────────────────────────────────────
  ui_step "JetBrains Toolbox (IDEs manager)..."
  brew_cask_install "jetbrains-toolbox" "JetBrains Toolbox"

  # ── Emacs (Doom) ──────────────────────────────────────────────
  ui_step "Emacs + Doom (optional power editor)..."
  brew_cask_install "emacs" "Emacs"  || true
  # NOTA: la condición correcta es comprobar el directorio del runtime
  # de Doom (~/.config/emacs), no ~/.config/doom (ese sólo se crea tras
  # ejecutar `doom install`).
  if [[ ! -d "${HOME}/.config/emacs" ]]; then
    run_task "Installing Doom Emacs" \
      git clone --depth=1 https://github.com/doomemacs/doomemacs "${HOME}/.config/emacs" || true
  fi

  # ── Vim (enhanced) ───────────────────────────────────────────
  ui_step "Vim (enhanced macOS version)..."
  brew_install "vim" "Vim"
  _write_vimrc

  # ── Code editor CLIs ─────────────────────────────────────────
  ui_step "Editor CLIs..."
  brew_install "nano"  "nano"
  brew_install "micro" "micro (modern nano)" || true

  ui_success "All editors installed and configured ✓"
}

# ═══════════════════════════════════════════════════════════════════
#  VS CODE
# ═══════════════════════════════════════════════════════════════════
_install_vscode_extensions() {
  if ! has_cmd code; then return; fi
  ui_step "Installing VS Code extensions..."

  local extensions=(
    # ── AI & Copilot ──────────────────────────────────────────
    "GitHub.copilot"                       # GitHub Copilot
    "GitHub.copilot-chat"                  # Copilot Chat
    "continue.continue"                    # Continue (open-source Copilot)
    "Codeium.codeium"                      # Codeium / Windsurf
    "saoudrizwan.claude-dev"               # Cline (AI agent)

    # ── Git ───────────────────────────────────────────────────
    "eamodio.gitlens"                      # GitLens (git supercharged)
    "mhutchie.git-graph"                   # Git Graph
    "donjayamanne.githistory"              # Git History
    "GitHub.vscode-pull-request-github"    # GitHub PRs
    "gitlab.gitlab-workflow"               # GitLab workflow
    "waderyan.gitblame"                    # Git blame
    "codezombiech.gitignore"               # .gitignore helper

    # ── Languages: JS/TS ──────────────────────────────────────
    "dbaeumer.vscode-eslint"               # ESLint
    "esbenp.prettier-vscode"               # Prettier
    "biomejs.biome"                        # Biome (lint+format)
    "ms-vscode.vscode-typescript-next"     # TS nightly
    "steoates.autoimport"                  # Auto import
    "formulahendry.auto-rename-tag"        # Auto rename tag
    "christian-kohler.path-intellisense"   # Path intellisense
    "wix.vscode-import-cost"               # Import cost
    "bradlc.vscode-tailwindcss"            # Tailwind CSS
    "Vue.volar"                            # Vue/Volar
    "svelte.svelte-vscode"                 # Svelte
    "angular.ng-template"                  # Angular
    "astro-build.astro-vscode"             # Astro
    "unifiedjs.vscode-mdx"                 # MDX

    # ── Languages: Python ─────────────────────────────────────
    "ms-python.python"                     # Python
    "ms-python.pylance"                    # Pylance
    "ms-python.black-formatter"            # Black formatter
    "ms-python.isort"                      # isort
    "ms-python.mypy-type-checker"          # mypy
    "charliermarsh.ruff"                   # Ruff
    "njpwerner.autodocstring"              # Python docstrings
    "kevinrose.vsc-python-indent"          # Python indent

    # ── Languages: Rust ───────────────────────────────────────
    "rust-lang.rust-analyzer"              # Rust Analyzer
    "tamasfe.even-better-toml"             # TOML
    "serayuzgur.crates"                    # Crates.io versions
    "dustypomerleau.rust-syntax"           # Rust syntax

    # ── Languages: Go ─────────────────────────────────────────
    "golang.go"                            # Go

    # ── Languages: Java/Kotlin ────────────────────────────────
    "redhat.java"                          # Java
    "vscjava.vscode-java-pack"             # Java Extension Pack
    "fwcd.kotlin"                          # Kotlin
    "scalameta.metals"                     # Scala Metals

    # ── Languages: Web ────────────────────────────────────────
    "ritwickdey.LiveServer"                # Live Server
    "ms-vscode.live-server"                # MS Live Preview
    "humao.rest-client"                    # REST Client
    "rangav.vscode-thunder-client"         # Thunder Client
    "42crunch.vscode-openapi"              # OpenAPI editor
    "Arjun.vscode-restclient"              # Rest Client alt

    # ── Languages: Other ──────────────────────────────────────
    "dart-code.dart-code"                  # Dart
    "dart-code.flutter"                    # Flutter
    "ms-vscode.cpptools"                   # C/C++
    "llvm-vs-code-extensions.vscode-clangd" # Clang
    # rebornix.ruby — extensión deprecated, reemplazada por shopify.ruby-lsp
    "shopify.ruby-lsp"                     # Ruby LSP (oficial de Shopify)
    "bbenoist.nix"                         # Nix
    "redhat.vscode-yaml"                   # YAML
    "ms-azuretools.vscode-docker"          # Docker
    "ms-kubernetes-tools.vscode-kubernetes-tools" # Kubernetes
    "hashicorp.terraform"                  # Terraform
    "hashicorp.hcl"                        # HCL
    "4ops.ansible"                         # Ansible
    "signageos.signageos-vscode-sops"      # SOPS

    # ── Databases ─────────────────────────────────────────────
    "cweijan.vscode-database-client2"      # Database client
    "ms-mssql.mssql"                       # SQL Server
    "cweijan.vscode-postgresql-client2"    # PostgreSQL
    "mongodb.mongodb-vscode"               # MongoDB
    "mtxr.sqltools"                        # SQLTools
    "mtxr.sqltools-driver-pg"              # SQLTools PostgreSQL
    "mtxr.sqltools-driver-mysql"           # SQLTools MySQL
    "mtxr.sqltools-driver-sqlite"          # SQLTools SQLite

    # ── Testing ───────────────────────────────────────────────
    "hbenl.vscode-test-explorer"           # Test Explorer
    "ms-playwright.playwright"             # Playwright
    "orta.vscode-jest"                     # Jest
    "firsttris.vscode-jest-runner"         # Jest Runner
    "ms-vscode.test-adapter-converter"     # Test adapter

    # ── DevOps & Cloud ────────────────────────────────────────
    "ms-azuretools.vscode-azureresourcegroups" # Azure
    "ms-vscode-remote.remote-ssh"          # Remote SSH
    "ms-vscode-remote.remote-containers"   # Dev Containers
    "ms-vscode-remote.remote-wsl"          # WSL
    "ms-vscode.remote-explorer"            # Remote Explorer
    "ms-vsliveshare.vsliveshare"           # Live Share

    # ── Productivity ──────────────────────────────────────────
    "alefragnani.project-manager"          # Project Manager
    "alefragnani.bookmarks"                # Bookmarks
    "gruntfuggly.todo-tree"                # Todo Tree
    "wayou.vscode-todo-highlight"          # TODO Highlight
    "aaron-bond.better-comments"           # Better Comments
    "streetsidesoftware.code-spell-checker" # Spell checker
    "mechatroner.rainbow-csv"              # Rainbow CSV
    "vincaslt.highlight-matching-tag"      # Matching tags
    "formulahendry.code-runner"            # Code Runner
    "ms-edgedevtools.vscode-edge-devtools" # Edge DevTools
    "WallabyJs.quokka-vscode"              # Quokka (live JS eval)
    "sleistner.vscode-fileutils"           # File Utils
    "usernamehw.errorlens"                 # Error Lens (inline errors)
    "kisstkondoros.vscode-gutter-preview"  # Gutter image preview
    "naumovs.color-highlight"              # Color highlight
    "oderwat.indent-rainbow"               # Indent rainbow
    # mechatroner.rainbow-csv — ya incluido arriba

    # ── Theme & UI ────────────────────────────────────────────
    "catppuccin.catppuccin-vsc"            # Catppuccin theme
    "catppuccin.catppuccin-vsc-icons"      # Catppuccin icons
    "PKief.material-icon-theme"            # Material Icons
    "antfu.icons-carbon"                   # Carbon icons
    "zhuangtongfa.material-theme"          # Material Theme
    "BeardedBear.beardedicons"             # Bearded icons

    # ── Markdown & Docs ───────────────────────────────────────
    "yzhang.markdown-all-in-one"           # Markdown All in One
    "davidanson.vscode-markdownlint"       # Markdownlint
    "shd101wyy.markdown-preview-enhanced"  # Markdown Preview
    "bierner.markdown-mermaid"             # Mermaid in Markdown
    "jebbs.plantuml"                       # PlantUML
    "hediet.vscode-drawio"                 # DrawIO

    # ── Formatting ────────────────────────────────────────────
    "EditorConfig.EditorConfig"            # EditorConfig
    "DotJoshJohnson.xml"                   # XML tools
    "redhat.vscode-xml"                    # XML Language Support
  )

  local total="${#extensions[@]}"
  local count=0
  for ext in "${extensions[@]}"; do
    ((count++)) || true
    [[ "$ext" == \#* ]] && continue
    code --install-extension "$ext" --force 2>/dev/null || true
  done
  track_ok "${total} VS Code extensions installed"
}

_write_vscode_settings() {
  local settings_dir="${HOME}/Library/Application Support/Code/User"
  ensure_dir "$settings_dir"
  cat > "${settings_dir}/settings.json" << 'VSCODE_SETTINGS'
{
  // ── Appearance ────────────────────────────────────────────────
  "workbench.colorTheme": "Catppuccin Macchiato",
  "workbench.iconTheme": "catppuccin-macchiato",
  "workbench.productIconTheme": "icons-carbon",
  "workbench.startupEditor": "none",
  "workbench.tree.indent": 16,
  "workbench.tree.renderIndentGuides": "always",
  "workbench.editor.tabSizing": "shrink",
  "workbench.editor.showTabs": "multiple",
  "workbench.editor.highlightModifiedTabs": true,
  "workbench.colorCustomizations": {
    "[Catppuccin Macchiato]": {
      "editorInlayHint.background": "#1e2030",
      "editorInlayHint.foreground": "#5b6078"
    }
  },
  "workbench.sideBar.location": "right",

  // ── Font & Editor ─────────────────────────────────────────────
  "editor.fontFamily": "'JetBrainsMono Nerd Font', 'Cascadia Code', 'Fira Code', monospace",
  "editor.fontSize": 14,
  "editor.lineHeight": 1.6,
  "editor.fontLigatures": true,
  "editor.fontWeight": "400",
  "editor.letterSpacing": 0.3,

  // ── Editor behavior ───────────────────────────────────────────
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "editor.detectIndentation": true,
  "editor.formatOnSave": true,
  "editor.formatOnPaste": true,
  "editor.formatOnType": false,
  "editor.codeActionsOnSave": {
    "source.organizeImports": "explicit",
    "source.fixAll.eslint": "explicit",
    "source.fixAll.biome": "explicit"
  },
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.wordWrap": "off",
  "editor.wordWrapColumn": 100,
  "editor.rulers": [80, 100, 120],
  "editor.renderWhitespace": "boundary",
  "editor.renderLineHighlight": "all",
  "editor.lineNumbers": "relative",
  "editor.cursorBlinking": "smooth",
  "editor.cursorSmoothCaretAnimation": "on",
  "editor.cursorStyle": "line",
  "editor.cursorWidth": 2,
  "editor.smoothScrolling": true,
  "editor.scrollBeyondLastLine": true,
  "editor.minimap.enabled": true,
  "editor.minimap.renderCharacters": false,
  "editor.minimap.scale": 1,
  "editor.minimap.showSlider": "always",
  "editor.minimap.side": "right",
  "editor.showFoldingControls": "mouseover",
  "editor.foldingImportsByDefault": true,
  "editor.bracketPairColorization.enabled": true,
  "editor.guides.bracketPairs": "active",
  "editor.guides.indentation": true,
  "editor.linkedEditing": true,
  "editor.snippetSuggestions": "top",
  "editor.suggestSelection": "first",
  "editor.acceptSuggestionOnCommitCharacter": false,
  "editor.quickSuggestionsDelay": 50,
  "editor.parameterHints.enabled": true,
  "editor.inlayHints.enabled": "onUnlessPressed",
  "editor.inlineSuggest.enabled": true,
  "editor.semanticHighlighting.enabled": true,
  "editor.occurrencesHighlight": "multiFile",
  "editor.selectionHighlight": true,
  "editor.tokenColorCustomizations": {},
  "editor.accessibilitySupport": "off",

  // ── Terminal ──────────────────────────────────────────────────
  "terminal.integrated.fontFamily": "'JetBrainsMono Nerd Font'",
  "terminal.integrated.fontSize": 13,
  "terminal.integrated.lineHeight": 1.2,
  "terminal.integrated.cursorBlinking": true,
  "terminal.integrated.cursorStyle": "line",
  "terminal.integrated.gpuAcceleration": "on",
  "terminal.integrated.smoothScrolling": true,
  "terminal.integrated.defaultProfile.osx": "zsh",
  "terminal.integrated.env.osx": {
    "TERM": "xterm-256color"
  },

  // ── Files ─────────────────────────────────────────────────────
  "files.autoSave": "onFocusChange",
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "files.trimFinalNewlines": true,
  "files.encoding": "utf8",
  "files.eol": "\n",
  "files.exclude": {
    "**/.git": true,
    "**/.DS_Store": true,
    "**/node_modules": true,
    "**/__pycache__": true,
    "**/.pytest_cache": true,
    "**/dist": false,
    "**/build": false
  },
  "files.watcherExclude": {
    "**/node_modules/**": true,
    "**/.git/objects/**": true,
    "**/dist/**": true,
    "**/target/**": true
  },
  "search.exclude": {
    "**/node_modules": true,
    "**/dist": true,
    "**/build": true,
    "**/.git": true,
    "**/target": true
  },

  // ── Explorer ──────────────────────────────────────────────────
  "explorer.confirmDragAndDrop": false,
  "explorer.confirmDelete": false,
  "explorer.sortOrder": "type",
  "explorer.compactFolders": false,
  "explorer.fileNesting.enabled": true,
  "explorer.fileNesting.patterns": {
    "*.ts": "${capture}.js, ${capture}.d.ts, ${capture}.js.map",
    "*.tsx": "${capture}.js, ${capture}.jsx",
    "package.json": "package-lock.json, yarn.lock, pnpm-lock.yaml, .npmrc, .nvmrc",
    "*.env": "*.env.*",
    "Dockerfile": "docker-compose*.yml, .dockerignore",
    "README.md": "LICENSE, CHANGELOG.md, CONTRIBUTING.md"
  },

  // ── Git ───────────────────────────────────────────────────────
  "git.enableSmartCommit": true,
  "git.autofetch": true,
  "git.confirmSync": false,
  "git.defaultCloneDirectory": "~/Developer",
  "git.openRepositoryInParentFolders": "always",
  "gitlens.mode.active": "zen",
  "gitlens.hovers.currentLine.over": "line",

  // ── Language-specific formatters ──────────────────────────────
  "[javascript]": { "editor.defaultFormatter": "biomejs.biome" },
  "[typescript]": { "editor.defaultFormatter": "biomejs.biome" },
  "[javascriptreact]": { "editor.defaultFormatter": "biomejs.biome" },
  "[typescriptreact]": { "editor.defaultFormatter": "biomejs.biome" },
  "[json]": { "editor.defaultFormatter": "esbenp.prettier-vscode" },
  "[jsonc]": { "editor.defaultFormatter": "esbenp.prettier-vscode" },
  "[html]": { "editor.defaultFormatter": "esbenp.prettier-vscode" },
  "[css]": { "editor.defaultFormatter": "esbenp.prettier-vscode" },
  "[scss]": { "editor.defaultFormatter": "esbenp.prettier-vscode" },
  "[markdown]": { "editor.defaultFormatter": "yzhang.markdown-all-in-one", "editor.wordWrap": "on" },
  "[python]": { "editor.defaultFormatter": "ms-python.black-formatter", "editor.tabSize": 4 },
  "[rust]": { "editor.defaultFormatter": "rust-lang.rust-analyzer" },
  "[go]": { "editor.defaultFormatter": "golang.go", "editor.tabSize": 4 },
  "[java]": { "editor.defaultFormatter": "redhat.java", "editor.tabSize": 4 },
  "[toml]": { "editor.defaultFormatter": "tamasfe.even-better-toml" },
  "[yaml]": { "editor.defaultFormatter": "redhat.vscode-yaml" },
  "[xml]": { "editor.defaultFormatter": "redhat.vscode-xml" },
  "[sh]": { "editor.defaultFormatter": "foxundermoon.shell-format" },
  "[shellscript]": { "editor.defaultFormatter": "foxundermoon.shell-format" },

  // ── Python ────────────────────────────────────────────────────
  "python.analysis.typeCheckingMode": "basic",
  "python.analysis.autoImportCompletions": true,
  "python.analysis.diagnosticMode": "workspace",
  "python.terminal.activateEnvironment": true,
  "[python]": {
    "editor.defaultFormatter": "ms-python.black-formatter",
    "editor.tabSize": 4
  },

  // ── Rust ──────────────────────────────────────────────────────
  "rust-analyzer.check.command": "clippy",
  "rust-analyzer.inlayHints.typeHints.enable": true,
  "rust-analyzer.inlayHints.parameterHints.enable": true,
  "rust-analyzer.cargo.allFeatures": true,
  "rust-analyzer.procMacro.enable": true,

  // ── Go ────────────────────────────────────────────────────────
  "go.useLanguageServer": true,
  "go.formatTool": "goimports",
  "go.lintTool": "golangci-lint",
  "go.testTimeout": "30s",

  // ── Error Lens ────────────────────────────────────────────────
  "errorLens.enabled": true,
  "errorLens.fontStyleItalic": true,
  "errorLens.messageBackgroundMode": "message",

  // ── Copilot ───────────────────────────────────────────────────
  "github.copilot.enable": { "*": true },
  "github.copilot.editor.enableAutoCompletions": true,

  // ── Prettier ──────────────────────────────────────────────────
  "prettier.singleQuote": true,
  "prettier.semi": false,
  "prettier.tabWidth": 2,
  "prettier.trailingComma": "es5",
  "prettier.printWidth": 100,
  "prettier.arrowParens": "avoid",

  // ── ESLint ────────────────────────────────────────────────────
  "eslint.validate": ["javascript", "javascriptreact", "typescript", "typescriptreact"],
  "eslint.codeActionsOnSave.mode": "problems",

  // ── Tailwind ──────────────────────────────────────────────────
  "tailwindCSS.experimental.classRegex": [
    ["cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]"],
    ["cn\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)"]
  ],

  // ── Markdown ──────────────────────────────────────────────────
  "markdown.preview.fontSize": 14,

  // ── Misc ──────────────────────────────────────────────────────
  "security.workspace.trust.untrustedFiles": "open",
  "telemetry.telemetryLevel": "off",
  "update.mode": "manual",
  "extensions.autoUpdate": false,
  "breadcrumbs.enabled": true,
  "problems.decorations.enabled": true,
  "window.zoomLevel": 0,
  "window.titleBarStyle": "custom",
  "window.title": "${rootName}${separator}${activeEditorShort}",
  "zenMode.hideLineNumbers": false,
  "zenMode.fullScreen": false,
  "zenMode.centerLayout": true,
  "diffEditor.ignoreTrimWhitespace": false,
  "diffEditor.renderSideBySide": true,
  "liveServer.settings.donotShowInfoMsg": true,
  "todo-tree.general.tags": ["TODO", "FIXME", "HACK", "BUG", "NOTE", "PERF"],
  "better-comments.tags": [
    { "tag": "!", "color": "#FF2D00", "strikethrough": false, "backgroundColor": "transparent" },
    { "tag": "?", "color": "#3498DB", "strikethrough": false, "backgroundColor": "transparent" },
    { "tag": "//", "color": "#474747", "strikethrough": true, "backgroundColor": "transparent" },
    { "tag": "todo", "color": "#FF8C00", "strikethrough": false, "backgroundColor": "transparent" },
    { "tag": "*", "color": "#98C379", "strikethrough": false, "backgroundColor": "transparent" }
  ]
}
VSCODE_SETTINGS
  track_ok "VS Code settings written"
}

_write_vscode_keybindings() {
  local settings_dir="${HOME}/Library/Application Support/Code/User"
  cat > "${settings_dir}/keybindings.json" << 'VSCODE_KEYS'
[
  // ── Navigation ────────────────────────────────────────────────
  { "key": "cmd+k cmd+s", "command": "workbench.action.openGlobalKeybindings" },
  { "key": "cmd+shift+e", "command": "workbench.view.explorer" },
  { "key": "cmd+shift+g", "command": "workbench.view.scm" },
  { "key": "cmd+shift+x", "command": "workbench.view.extensions" },
  { "key": "cmd+b", "command": "workbench.action.toggleSidebarVisibility" },
  { "key": "cmd+j", "command": "workbench.action.togglePanel" },

  // ── Editor ────────────────────────────────────────────────────
  { "key": "cmd+d", "command": "editor.action.addSelectionToNextFindMatch" },
  { "key": "cmd+shift+l", "command": "editor.action.selectHighlights" },
  { "key": "alt+up", "command": "editor.action.moveLinesUpAction" },
  { "key": "alt+down", "command": "editor.action.moveLinesDownAction" },
  { "key": "cmd+shift+d", "command": "editor.action.copyLinesDownAction" },
  { "key": "cmd+/", "command": "editor.action.commentLine" },
  { "key": "shift+alt+a", "command": "editor.action.blockComment" },
  { "key": "cmd+[", "command": "editor.action.outdentLines" },
  { "key": "cmd+]", "command": "editor.action.indentLines" },
  { "key": "cmd+k cmd+f", "command": "editor.action.formatSelection" },
  { "key": "alt+z", "command": "editor.action.toggleWordWrap" },
  { "key": "f12", "command": "editor.action.revealDefinition" },
  { "key": "alt+f12", "command": "editor.action.peekDefinition" },
  { "key": "shift+f12", "command": "editor.action.goToReferences" },
  { "key": "cmd+r", "command": "editor.action.rename" },
  { "key": "cmd+.", "command": "editor.action.quickFix" },

  // ── Splits ────────────────────────────────────────────────────
  { "key": "cmd+\\", "command": "workbench.action.splitEditor" },
  { "key": "cmd+k cmd+\\", "command": "workbench.action.splitEditorOrthogonal" },
  { "key": "cmd+k h", "command": "workbench.action.focusLeftGroup" },
  { "key": "cmd+k l", "command": "workbench.action.focusRightGroup" },
  { "key": "cmd+k j", "command": "workbench.action.focusBelowGroup" },
  { "key": "cmd+k k", "command": "workbench.action.focusAboveGroup" },

  // ── Terminal ──────────────────────────────────────────────────
  { "key": "ctrl+`", "command": "workbench.action.terminal.toggleTerminal" },
  { "key": "ctrl+shift+`", "command": "workbench.action.terminal.new" },
  { "key": "cmd+shift+5", "command": "workbench.action.terminal.split" },
  { "key": "ctrl+pageup", "command": "workbench.action.terminal.focusPreviousPane" },
  { "key": "ctrl+pagedown", "command": "workbench.action.terminal.focusNextPane" },

  // ── Tabs ──────────────────────────────────────────────────────
  { "key": "cmd+shift+[", "command": "workbench.action.previousEditor" },
  { "key": "cmd+shift+]", "command": "workbench.action.nextEditor" },
  { "key": "cmd+w", "command": "workbench.action.closeActiveEditor" },
  { "key": "cmd+shift+t", "command": "workbench.action.reopenClosedEditor" },

  // ── Search ────────────────────────────────────────────────────
  { "key": "cmd+shift+f", "command": "workbench.action.findInFiles" },
  { "key": "cmd+shift+h", "command": "workbench.action.replaceInFiles" },

  // ── Copilot ───────────────────────────────────────────────────
  { "key": "cmd+shift+i", "command": "github.copilot.openChat" },
  { "key": "ctrl+enter", "command": "github.copilot.generate" }
]
VSCODE_KEYS
  track_ok "VS Code keybindings written"
}

# ═══════════════════════════════════════════════════════════════════
#  ZED
# ═══════════════════════════════════════════════════════════════════
_write_zed_settings() {
  ensure_dir "${HOME}/.config/zed"
  cat > "${HOME}/.config/zed/settings.json" << 'ZED_SETTINGS'
{
  "theme": "Catppuccin Macchiato",
  "ui_font_family": "JetBrainsMono Nerd Font",
  "ui_font_size": 15,
  "buffer_font_family": "JetBrainsMono Nerd Font",
  "buffer_font_size": 14,
  "buffer_font_features": { "calt": true, "liga": true },
  "buffer_line_height": { "custom": 1.6 },
  "tab_size": 2,
  "soft_wrap": "none",
  "show_whitespaces": "boundary",
  "show_call_status_icon": true,
  "autosave": "on_focus_change",
  "format_on_save": "on",
  "relative_line_numbers": true,
  "cursor_blink": true,
  "vim_mode": false,
  "git": {
    "enabled": true,
    "git_gutter": "tracked_files",
    "inline_blame": { "enabled": true, "delay_ms": 600 }
  },
  "inline_completions": { "disabled_globs": [".env"] },
  "inlay_hints": {
    "enabled": true,
    "show_type_hints": true,
    "show_parameter_hints": true
  },
  "terminal": {
    "font_family": "JetBrainsMono Nerd Font",
    "font_size": 13,
    "line_height": { "custom": 1.2 },
    "blinking": "on"
  },
  "assistant": {
    "default_model": {
      "provider": "anthropic",
      "model": "claude-sonnet-4-20250514"
    },
    "version": "2"
  },
  "collaboration_panel": { "button": false },
  "notification_panel": { "button": false },
  "chat_panel": { "button": false },
  "project_panel": { "dock": "right" },
  "outline_panel": { "dock": "left" },
  "toolbar": { "breadcrumbs": true },
  "show_completions_on_input": true,
  "show_completion_documentation": true,
  "use_autoclose": true,
  "use_auto_surround": true,
  "file_finder": { "modal_max_width": "large" },
  "search": { "whole_word": false, "case_sensitive": false },
  "lsp": {
    "rust-analyzer": {
      "check": { "command": "clippy" },
      "inlayHints": { "parameterHints": { "enable": true } }
    },
    "pyright": { "settings": { "python": { "pythonPath": ".venv/bin/python" } } }
  },
  "languages": {
    "Python": { "tab_size": 4, "format_on_save": "on", "formatter": { "language_server": { "name": "ruff" } } },
    "Rust": { "tab_size": 4, "format_on_save": "on" },
    "Go": { "tab_size": 4, "format_on_save": "on" },
    "Java": { "tab_size": 4 },
    "Markdown": { "soft_wrap": "editor_width" }
  }
}
ZED_SETTINGS

  # Zed keymap
  cat > "${HOME}/.config/zed/keymap.json" << 'ZED_KEYS'
[
  { "context": "Editor", "bindings": {
    "cmd-d": "editor::SelectNext",
    "cmd-shift-l": "editor::SelectAll",
    "cmd-/": "editor::ToggleComments",
    "cmd-shift-d": "editor::DuplicateLineDown",
    "cmd-r": "editor::Rename",
    "cmd-.": "editor::ToggleCodeActions",
    "f12": "editor::GoToDefinition",
    "alt-f12": "editor::GoToDefinitionSplit",
    "cmd-k cmd-f": "editor::Format"
  }},
  { "context": "Workspace", "bindings": {
    "cmd-b": "workspace::ToggleLeftDock",
    "cmd-j": "workspace::ToggleBottomDock",
    "cmd-shift-e": "pane::RevealInProjectPanel",
    "ctrl-`": "workspace::ToggleTerminalPanel"
  }}
]
ZED_KEYS
  track_ok "Zed configured"
}

# ═══════════════════════════════════════════════════════════════════
#  NEOVIM + LAZYVIM
# ═══════════════════════════════════════════════════════════════════
_setup_neovim() {
  local nvim_config="${HOME}/.config/nvim"

  if [[ -d "${nvim_config}" && -f "${nvim_config}/init.lua" ]]; then
    track_skip "Neovim (already configured)"
    return
  fi

  # Install LazyVim starter
  run_task "Cloning LazyVim starter" \
    git clone --depth=1 https://github.com/LazyVim/starter "${nvim_config}" 2>/dev/null || true

  # Remove git so user can make it their own
  rm -rf "${nvim_config}/.git" 2>/dev/null || true

  # Write comprehensive plugins extras
  ensure_dir "${nvim_config}/lua/plugins"
  cat > "${nvim_config}/lua/plugins/devforge.lua" << 'NVIM_PLUGINS'
-- DevForge Neovim Configuration v3.0
-- LazyVim extras + custom plugins

-- ── LazyVim Extras ─────────────────────────────────────────────────
vim.g.lazyvim_extras = {
  -- Colorscheme
  "lazyvim.plugins.extras.ui.catppuccin",
  -- Coding
  "lazyvim.plugins.extras.coding.copilot",
  "lazyvim.plugins.extras.coding.copilot-chat",
  "lazyvim.plugins.extras.coding.cmp",
  "lazyvim.plugins.extras.coding.blink",
  "lazyvim.plugins.extras.coding.mini-surround",
  -- Editor
  "lazyvim.plugins.extras.editor.aerial",
  "lazyvim.plugins.extras.editor.fzf",
  "lazyvim.plugins.extras.editor.harpoon2",
  "lazyvim.plugins.extras.editor.illuminate",
  "lazyvim.plugins.extras.editor.mini-files",
  "lazyvim.plugins.extras.editor.navic",
  "lazyvim.plugins.extras.editor.overseer",
  "lazyvim.plugins.extras.editor.refactoring",
  -- UI
  "lazyvim.plugins.extras.ui.mini-animate",
  "lazyvim.plugins.extras.ui.edgy",
  "lazyvim.plugins.extras.ui.treesitter-context",
  -- Languages
  "lazyvim.plugins.extras.lang.typescript",
  "lazyvim.plugins.extras.lang.python",
  "lazyvim.plugins.extras.lang.rust",
  "lazyvim.plugins.extras.lang.go",
  "lazyvim.plugins.extras.lang.java",
  "lazyvim.plugins.extras.lang.docker",
  "lazyvim.plugins.extras.lang.terraform",
  "lazyvim.plugins.extras.lang.ansible",
  "lazyvim.plugins.extras.lang.markdown",
  "lazyvim.plugins.extras.lang.json",
  "lazyvim.plugins.extras.lang.yaml",
  "lazyvim.plugins.extras.lang.toml",
  "lazyvim.plugins.extras.lang.sql",
  "lazyvim.plugins.extras.lang.css",
  "lazyvim.plugins.extras.lang.svelte",
  "lazyvim.plugins.extras.lang.vue",
  "lazyvim.plugins.extras.lang.angular",
  "lazyvim.plugins.extras.lang.ruby",
  "lazyvim.plugins.extras.lang.php",
  "lazyvim.plugins.extras.lang.elixir",
  "lazyvim.plugins.extras.lang.dart",
  -- DAP
  "lazyvim.plugins.extras.dap.core",
  "lazyvim.plugins.extras.dap.nlua",
  -- Test
  "lazyvim.plugins.extras.test.core",
  -- Formatting
  "lazyvim.plugins.extras.formatting.prettier",
  "lazyvim.plugins.extras.formatting.black",
  -- Linting
  "lazyvim.plugins.extras.linting.eslint",
}

return {
  -- ── Catppuccin ────────────────────────────────────────────────────
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "macchiato",
      transparent_background = false,
      show_end_of_buffer = false,
      term_colors = true,
      dim_inactive = { enabled = true, shade = "dark", percentage = 0.15 },
      integrations = {
        aerial = true, cmp = true, dap = true, dap_ui = true,
        fzf = true, gitsigns = true, harpoon = true, indent_blankline = { enabled = true },
        lsp_trouble = true, mason = true, mini = true, native_lsp = { enabled = true },
        neogit = true, neotest = true, noice = true, notify = true,
        nvim_surround = true, nvimtree = false, oil = true,
        telescope = { enabled = true }, treesitter = true, which_key = true,
      },
    },
  },

  -- ── Oil.nvim (file manager) ───────────────────────────────────────
  {
    "stevearc/oil.nvim",
    opts = {
      default_file_explorer = true,
      delete_to_trash = true,
      view_options = { show_hidden = true },
      float = { padding = 4, max_width = 80, max_height = 30 },
      keymaps = {
        ["<C-h>"] = false, ["<C-l>"] = false,
        ["<C-s>"] = { "actions.select", opts = { vertical = true } },
        ["<C-v>"] = { "actions.select", opts = { horizontal = true } },
        ["`"] = "actions.cd",
      },
    },
    keys = {
      { "-", "<cmd>Oil<cr>",        desc = "Open parent directory" },
      { "<leader>-", "<cmd>Oil --float<cr>", desc = "Open file manager (float)" },
    },
  },

  -- ── Harpoon 2 (quick file navigation) ────────────────────────────
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    opts = { menu = { width = vim.api.nvim_win_get_width(0) - 4 } },
    keys = {
      { "<leader>H",  function() require("harpoon"):list():add() end, desc = "Harpoon Add" },
      { "<C-e>",      function() local h = require("harpoon"); h.ui:toggle_quick_menu(h:list()) end, desc = "Harpoon List" },
      { "<C-h>",      function() require("harpoon"):list():select(1) end },
      { "<C-j>",      function() require("harpoon"):list():select(2) end },
      { "<C-k>",      function() require("harpoon"):list():select(3) end },
      { "<C-l>",      function() require("harpoon"):list():select(4) end },
    },
  },

  -- ── Flash.nvim (fast navigation) ─────────────────────────────────
  {
    "folke/flash.nvim",
    opts = { modes = { search = { enabled = true } } },
    keys = {
      { "s",     function() require("flash").jump() end,       desc = "Flash jump",            mode = {"n","x","o"} },
      { "S",     function() require("flash").treesitter() end, desc = "Flash treesitter",      mode = {"n","x","o"} },
      { "r",     function() require("flash").remote() end,     desc = "Flash remote",          mode = "o" },
      { "<c-s>", function() require("flash").toggle() end,     desc = "Toggle Flash in Search",mode = {"c"} },
    },
  },

  -- ── Noice.nvim (beautiful UI) ─────────────────────────────────────
  {
    "folke/noice.nvim",
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true,
        lsp_doc_border = true,
      },
    },
  },

  -- ── Trouble.nvim (diagnostics panel) ─────────────────────────────
  {
    "folke/trouble.nvim",
    opts = { use_diagnostic_signs = true },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",                        desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",           desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>",                desc = "Symbols (Trouble)" },
      { "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP Definitions (Trouble)" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>",                            desc = "Location List (Trouble)" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>",                             desc = "Quickfix List (Trouble)" },
    },
  },

  -- ── GitHub Copilot ────────────────────────────────────────────────
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = { enabled = false }, -- use copilot-cmp instead
      panel = { enabled = false },
    },
  },
  {
    "zbirenbaum/copilot-cmp",
    dependencies = "zbirenbaum/copilot.lua",
    config = function() require("copilot_cmp").setup() end,
  },

  -- ── CopilotChat ───────────────────────────────────────────────────
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    opts = {
      model = "claude-sonnet-4",
      window = { layout = "float", width = 0.8, height = 0.8 },
    },
    keys = {
      { "<leader>ac", "<cmd>CopilotChat<cr>",         desc = "Copilot Chat",         mode = { "n", "v" } },
      { "<leader>ae", "<cmd>CopilotChatExplain<cr>",  desc = "Copilot Explain",      mode = "v" },
      { "<leader>ar", "<cmd>CopilotChatReview<cr>",   desc = "Copilot Review",       mode = "v" },
      { "<leader>af", "<cmd>CopilotChatFix<cr>",      desc = "Copilot Fix",          mode = "v" },
      { "<leader>at", "<cmd>CopilotChatTests<cr>",    desc = "Copilot Tests",        mode = "v" },
      { "<leader>ao", "<cmd>CopilotChatOptimize<cr>", desc = "Copilot Optimize",     mode = "v" },
      { "<leader>ad", "<cmd>CopilotChatDocs<cr>",     desc = "Copilot Docs",         mode = "v" },
    },
  },

  -- ── Avante.nvim (Claude/AI panel) ────────────────────────────────
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false,
    opts = {
      provider = "claude",
      claude = {
        endpoint = "https://api.anthropic.com",
        model = "claude-sonnet-4-20250514",
        max_tokens = 8096,
      },
      hints = { enabled = true },
      windows = { wrap = true, width = 35, sidebar_header = { rounded = true } },
    },
    build = "make",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      { "zbirenbaum/copilot.lua" },
      { "HakonHarnes/img-clip.nvim", opts = { default = { embed_image_as_base64 = false, prompt_for_file_name = false } } },
      { "MeanderingProgrammer/render-markdown.nvim", opts = { file_types = { "markdown", "Avante" } }, ft = { "markdown", "Avante" } },
    },
    keys = {
      { "<leader>aa", "<cmd>AvanteAsk<cr>",    desc = "Avante Ask",    mode = { "n", "v" } },
      { "<leader>ai", "<cmd>AvanteChat<cr>",   desc = "Avante Chat" },
      { "<leader>ab", "<cmd>AvanteBuild<cr>",  desc = "Avante Build" },
    },
  },

  -- ── CodeCompanion (multi-LLM) ─────────────────────────────────────
  {
    "olimorris/codecompanion.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
    opts = {
      adapters = {
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            schema = { model = { default = "claude-sonnet-4-20250514" } },
          })
        end,
      },
      strategies = { chat = { adapter = "anthropic" }, inline = { adapter = "anthropic" } },
    },
    keys = {
      { "<leader>ai", "<cmd>CodeCompanionChat Toggle<cr>",   desc = "CodeCompanion Chat" },
      { "<leader>aI", "<cmd>CodeCompanionActions<cr>",       desc = "CodeCompanion Actions" },
      { "<leader>aA", "<cmd>CodeCompanionChat Add<cr>",      desc = "Add to Chat", mode = "v" },
    },
  },

  -- ── Neogit (Magit for Neovim) ─────────────────────────────────────
  {
    "NeogitOrg/neogit",
    dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim", "nvim-telescope/telescope.nvim" },
    opts = {
      kind = "split",
      commit_editor = { kind = "split" },
      signs = { hunk = { "", "" }, item = { ">", "v" }, section = { ">", "v" } },
    },
    keys = {
      { "<leader>gg", "<cmd>Neogit<cr>",       desc = "Neogit" },
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview" },
    },
  },

  -- ── Sidekick (Copilot NES) ────────────────────────────────────────
  {
    "folke/sidekick.nvim",
    opts = {
      cli = {
        mux = { backend = "zellij", enabled = false },
        tools = {
          claude = { cmd = { "claude" } },
          aider  = { cmd = { "aider" } },
          gemini = { cmd = { "gemini" } },
        },
      },
    },
    keys = {
      { "<leader>as", function() require("sidekick.cli").toggle() end, desc = "Sidekick Toggle" },
    },
  },

  -- ── Aerial (code outline) ─────────────────────────────────────────
  {
    "stevearc/aerial.nvim",
    opts = {
      attach_mode = "global",
      backends = { "lsp", "treesitter", "markdown", "man" },
      layout = { min_width = 28 },
      show_guides = true,
    },
    keys = {
      { "<leader>cs", "<cmd>AerialToggle<cr>", desc = "Code Outline" },
    },
  },

  -- ── TODO Comments ─────────────────────────────────────────────────
  {
    "folke/todo-comments.nvim",
    opts = {
      keywords = {
        FIX  = { icon = " ", color = "error" },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning" },
        PERF = { icon = " " },
        NOTE = { icon = " ", color = "hint" },
      },
    },
    keys = {
      { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Todo comments" },
      { "<leader>sT", "<cmd>TodoTrouble<cr>",   desc = "Todo (Trouble)" },
    },
  },

  -- ── Telescope Extensions ──────────────────────────────────────────
  {
    "nvim-telescope/telescope.nvim",
    -- `build` debe ir al nivel del plugin (no dentro de dependencies).
    -- Se aplica a telescope-fzf-native.nvim que sí necesita compilarse.
    dependencies = {
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-file-browser.nvim",
      "nvim-telescope/telescope-project.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
      "nvim-telescope/telescope-frecency.nvim",
    },
    opts = {
      pickers = {
        find_files = { hidden = true, follow = true },
        live_grep  = { additional_args = { "--hidden" } },
      },
    },
    keys = {
      { "<leader>fp", "<cmd>Telescope project<cr>",      desc = "Projects" },
      { "<leader>fr", "<cmd>Telescope frecency<cr>",     desc = "Recent files" },
      { "<leader>fe", "<cmd>Telescope file_browser<cr>", desc = "File browser" },
    },
  },

  -- ── Which-key extensions ──────────────────────────────────────────
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>a", group = "AI / Copilot" },
        { "<leader>g", group = "Git" },
      },
    },
  },
}
NVIM_PLUGINS

  # LazyVim config overrides
  cat > "${nvim_config}/lua/config/options.lua" << 'NVIM_OPTIONS'
-- DevForge Neovim Options
local opt = vim.opt

-- Display
opt.number         = true
opt.relativenumber = true
opt.cursorline     = true
opt.scrolloff      = 8
opt.sidescrolloff  = 8
opt.signcolumn     = "yes"
opt.showmode       = false
opt.ruler          = false
opt.laststatus     = 3  -- global statusline

-- Indentation
opt.tabstop     = 2
opt.shiftwidth  = 2
opt.expandtab   = true
opt.smartindent = true
opt.autoindent  = true

-- Search
opt.ignorecase = true
opt.smartcase  = true
opt.hlsearch   = true
opt.incsearch  = true

-- Files
opt.undofile    = true
opt.backup      = false
opt.writebackup = false
opt.swapfile    = false

-- Performance
opt.lazyredraw     = false
opt.updatetime     = 100
opt.timeoutlen     = 300
opt.redrawtime     = 1500

-- Splits
opt.splitbelow = true
opt.splitright = true

-- Misc
opt.clipboard  = "unnamedplus"
opt.mouse      = "a"
opt.conceallevel = 0
opt.wrap       = false
opt.breakindent = true
opt.linebreak  = true
opt.pumheight  = 10
opt.cmdheight  = 0

-- Folds
opt.foldmethod = "expr"
opt.foldexpr   = "nvim_treesitter#foldexpr()"
opt.foldenable = false
opt.foldlevel  = 99

-- Font (for GUIs)
opt.guifont = "JetBrainsMono Nerd Font:h14"
NVIM_OPTIONS

  track_ok "Neovim configured with LazyVim + AI plugins"
}

# ═══════════════════════════════════════════════════════════════════
#  HELIX
# ═══════════════════════════════════════════════════════════════════
_write_helix_config() {
  ensure_dir "${HOME}/.config/helix"
  cat > "${HOME}/.config/helix/config.toml" << 'HELIX_CONFIG'
theme = "catppuccin_macchiato"

[editor]
line-number = "relative"
mouse = true
middle-click-paste = false
auto-pairs = true
auto-save = true
rulers = [80, 100]
color-modes = true
bufferline = "multiple"
popup-border = "all"

[editor.cursor-shape]
insert = "bar"
normal = "block"
select = "underline"

[editor.file-picker]
hidden = false
follow-symlinks = true

[editor.search]
smart-case = true

[editor.lsp]
display-messages = true
display-inlay-hints = true
snippets = true

[editor.statusline]
mode-separator = ""
separator = "│"
left   = ["mode", "spinner", "version-control", "file-name", "file-modification-indicator"]
center = []
right  = ["diagnostics", "selections", "register", "position", "file-encoding", "file-type"]

[editor.soft-wrap]
enable = false

[keys.normal]
"space" = "file_picker"
"A-." = "code_action"
"C-s" = ":write"
"C-q" = ":quit"
g = { a = "code_action", r = "rename_symbol" }

[keys.insert]
"C-s" = ["normal_mode", ":write"]
"j"   = { j = "normal_mode" }
HELIX_CONFIG
  track_ok "Helix configured"
}

# ═══════════════════════════════════════════════════════════════════
#  VIM (minimal)
# ═══════════════════════════════════════════════════════════════════
_write_vimrc() {
  cat > "${HOME}/.vimrc" << 'VIMRC'
" DevForge minimal .vimrc
set nocompatible
set number relativenumber
set tabstop=2 shiftwidth=2 expandtab
set ignorecase smartcase
set incsearch hlsearch
set clipboard=unnamed
set mouse=a
set undofile
syntax on
filetype plugin indent on
" Leader
let mapleader = " "
" Basic keymaps
nnoremap <leader>w :write<CR>
nnoremap <leader>q :quit<CR>
nnoremap <Esc> :nohlsearch<CR>
VIMRC
  track_ok "Vim configured"
}
