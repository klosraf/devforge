<div align="center">

```
██████╗ ███████╗██╗   ██╗███████╗ ██████╗ ██████╗  ██████╗ ███████╗
██╔══██╗██╔════╝██║   ██║██╔════╝██╔═══██╗██╔══██╗██╔════╝ ██╔════╝
██║  ██║█████╗  ██║   ██║█████╗  ██║   ██║██████╔╝██║  ███╗█████╗
██║  ██║██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║   ██║██╔══██╗██║   ██║██╔══╝
██████╔╝███████╗ ╚████╔╝ ██║     ╚██████╔╝██║  ██║╚██████╔╝███████╗
╚═════╝ ╚══════╝  ╚═══╝  ╚═╝      ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝
```

**macOS Developer Environment Forge** · v3.0.0

*Automated setup for programming, design, compilation and testing on macOS*

</div>

---

## What is DevForge?

DevForge is a comprehensive, idempotent macOS developer environment installer with a beautiful TUI. Run it once and get a fully configured, professional development machine in minutes.

## Quick Start

```bash
# Clone and run
git clone https://github.com/your-org/devforge.git && cd devforge
./install.sh

# Or specific modules
./install.sh --modules core,languages,ai
./install.sh --audit      # Audit your system
./install.sh --update     # Update everything
./install.sh --help
```

## Architecture

```
macos-dev-setup/
├── install.sh              # Main TUI entry point
├── README.md               # This file
├── config/
│   ├── Brewfile            # 200+ Homebrew packages
│   ├── vscode/
│   │   ├── settings.json   # 120+ VS Code settings
│   │   └── keybindings.json
│   └── neovim/
│       └── lua/plugins/
│           └── devforge.lua # LazyVim + AI plugins
├── modules/
│   ├── core.sh             # Foundation: Homebrew, 80+ CLI tools, Git, Zsh
│   ├── languages.sh        # 20+ languages + version managers
│   ├── frameworks.sh       # Frameworks, libraries, DevOps, databases
│   ├── editors.sh          # VS Code, Neovim, Zed, Cursor, Helix, JetBrains
│   ├── terminal.sh         # Ghostty, Tabby, WezTerm, tmux, Starship, shell
│   ├── macos.sh            # macOS system defaults & AeroSpace
│   ├── apps.sh             # 80+ open-source applications
│   ├── ai.sh               # AI coding agents & MCP servers  ← NEW v3.0
│   └── dotfiles.sh         # chezmoi, stow, mackup           ← NEW v3.0
└── lib/
    ├── ui.sh               # TUI library (colors, spinners, menus)
    └── utils.sh            # Helpers (brew_install, run_task, etc.)
```

---

## Modules

### `core` — Foundation (80+ tools)

| Category | Tools |
|----------|-------|
| Package Manager | Homebrew + 10 taps |
| Shell | Zsh, Oh My Zsh, 8 plugins, Powerlevel10k |
| Version Control | Git, LazyGit, GitUI, gh, glab, tig |
| **Modern Replacements** | eza, bat, ripgrep, fd, fzf, zoxide, dust, duf, bottom, procs |
| Text Processing | sd, jq, yq, gron, jless, fx, jo, miller, htmlq |
| File Ops | ouch, p7zip, unar |
| Shell Enhancement | starship, atuin, mcfly, navi, tldr, tealdeer, thefuck, direnv |
| Task Runners | just, make, cmake, ninja |
| TUI Tools | gum, lolcat, figlet, pastel |
| Code Analysis | tokei, cloc, onefetch, grex |
| HTTP | curl, wget, httpie, xh, curlie |
| Multiplexers | tmux, zellij, mprocs |
| Security | age, sops |
| Utilities | parallel, imagemagick, ffmpeg, pandoc |

### `languages` — 20+ Programming Languages

| Language | Tools Installed |
|----------|----------------|
| Node.js | mise, n, pnpm, bun, deno, TypeScript |
| Python | pyenv, uv, rye, pipx, 3.11/3.12/3.13 |
| Rust | rustup, wasm targets, clippy, rustfmt |
| Go | gopls, dlv, golangci-lint |
| Ruby | rbenv, bundler, gems |
| Java | OpenJDK 17 + 21, Maven, Gradle |
| Kotlin | via SDKMAN |
| Swift | SwiftLint, SwiftFormat, XcodeGen |
| Dart/Flutter | Flutter SDK |
| Elixir | Erlang, Phoenix |
| PHP | Composer |
| C/C++ | LLVM, GCC, Conan |
| Haskell | GHC, Stack, HLS |
| Zig | ZLS |
| Lua | LuaRocks |
| R | Rscript |
| Julia | REPL |
| Scala | sbt |
| Clojure | Leiningen |
| WebAssembly | wasmtime, wasm-pack |

### `frameworks` — Libraries & DevOps

| Area | Included |
|------|---------|
| JS/TS | vite, turbo, nx, next, remix, vue, svelte, angular, astro, qwik |
| Testing | jest, vitest, playwright, cypress |
| Tooling | eslint, prettier, biome, prisma, drizzle, storybook |
| Python | fastapi, django, flask, numpy, pandas, pytorch, langchain |
| DevOps | docker, colima, kubectl, helm, k9s, k3d, kind |
| Cloud | awscli, azure-cli, gcloud, doctl, flyctl, vercel |
| Databases | PostgreSQL, MySQL, Redis, MongoDB, SQLite, InfluxDB |
| Security | nmap, trivy, grype, trufflehog, semgrep |
| API | grpc, protobuf, buf, graphql |
| Load Testing | k6, vegeta, wrk |

### `editors` — Code Editors

| Editor | Config |
|--------|--------|
| **VS Code** | 80+ extensions, Catppuccin theme, full settings.json + keybindings |
| **Cursor** | AI-first VS Code fork |
| **Zed** | Catppuccin, JetBrainsMono, Claude assistant, full settings |
| **Neovim** | LazyVim + 30+ plugins: Copilot, Avante/Claude, CopilotChat, CodeCompanion, Sidekick, Harpoon2, Flash, Oil, Neogit, Trouble, Aerial, Telescope |
| **Helix** | Catppuccin, relative lines, custom keybinds, LSP |
| **JetBrains** | Toolbox installed |
| **Emacs** | Doom Emacs |
| **Vim** | Minimal .vimrc |

**VS Code extension categories:** AI (6), Git (7), JS/TS (15), Python (8), Rust (4), Go (1), Database (8), Testing (5), DevOps/Cloud (8), Productivity (15), Theme (6), Markdown (6), Remote (5)

**Neovim AI plugins:** `avante.nvim` (Claude), `CopilotChat.nvim`, `copilot.lua`, `codecompanion.nvim`, `sidekick.nvim`

### `terminal` — Shell Environment

| Tool | Config |
|------|--------|
| **Ghostty** | Catppuccin Macchiato, blur 20, JetBrainsMono 14 |
| **Tabby** | Catppuccin, vibrancy, SSH agent |
| **WezTerm** | Lua config, Catppuccin, custom tab bar |
| **Starship** | Full Catppuccin palette, 15+ segments |
| **tmux** | Catppuccin status, TPM plugins, vim nav |
| **Zellij** | Catppuccin, rounded corners |
| **Fonts** | 17 Nerd Fonts including JetBrainsMono, Geist, Monaspace, Cascadia, Victor Mono, Commit Mono, Maple Mono |
| **.zshrc** | 20 Oh My Zsh plugins, 80+ aliases, custom functions |
| **.zsh_functions** | mkcd, up, extract, fcd, fkill, ghclone, serve, new-project |

### `macos` — System Defaults

- Dark mode, accent colors, trackpad optimization
- Dock: autohide, custom apps, no recent apps
- Finder: show all files, path bar, list view
- Screenshots → `~/Desktop/Screenshots`
- AeroSpace window manager: alt+hjkl, workspaces 1-9
- Raycast, Rectangle pro

### `apps` — Applications (80+)

| Category | Apps |
|----------|------|
| Browsers | Arc, Firefox, Brave, Chrome |
| API Tools | HTTPie Desktop, Insomnia, Postman, Proxyman, Charles |
| Database | TablePlus, DBeaver, MongoDB Compass, RedisInsight, Beekeeper Studio |
| Git GUIs | Fork, SourceTree, GitKraken, GitHub Desktop |
| Design | Figma, Sketch, ImageOptim |
| Notes | Obsidian, Notion, Logseq, Bear |
| Productivity | Raycast, Maccy, Alfred, PopClip |
| Window Mgmt | Rectangle, Amethyst |
| Security | LuLu, OverSight, BlockBlock, Bitwarden, 1Password |
| AI | Ollama, LM Studio, Jan, AnythingLLM |
| Media | VLC, OBS, IINA, HandBrake |
| QuickLook | 9 plugins including QL Color Code, Syntax Highlight |
| Fonts | 17 Nerd Fonts + Inter, Source Code Pro |
| App Store | Xcode, Swift Playgrounds, WireGuard, Amphetamine |

### `ai` — AI Coding Agents ⭐ NEW v3.0

| Tool | Description |
|------|-------------|
| **Claude Code** | Anthropic's agentic terminal coder |
| **Gemini CLI** | Google's free AI terminal (1000 req/day) |
| **Aider** | Git-native AI pair programmer (30+ LLMs) |
| **GitHub Copilot CLI** | Copilot in terminal |
| **Continue** | Open-source AI coding assistant |
| **OpenCode** | Open-source terminal AI agent |
| **Qodo Gen CLI** | Test-focused AI coding agent |
| **LLM CLI** | Simon Willison's 100+ LLM tool |
| **Ollama models** | codellama, llama3.2, mistral, deepseek-coder, qwen2.5-coder |
| **MCP Servers** | filesystem, github, gitlab, postgres, sqlite, puppeteer, brave-search |
| **VS Code AI ext** | Continue, Copilot, Codeium, Cline, Claude Code |
| **Neovim AI** | Avante, CopilotChat, Sidekick, CodeCompanion |

### `dotfiles` — Dotfiles Management ⭐ NEW v3.0

| Tool | Purpose |
|------|---------|
| **chezmoi** | Cross-machine dotfiles with templates & secrets |
| **GNU Stow** | Symlink farm manager |
| **Mackup** | Backup & restore app settings (iCloud sync) |
| **YADM** | Git-based dotfiles manager |
| **Dockutil** | macOS Dock management from CLI |
| Structure | `~/.dotfiles/{zsh,git,nvim,tmux,ghostty,starship,scripts,bin}` |

---

## Design Principles

- **🎨 Unified theme**: Catppuccin Macchiato across ALL tools
- **🔄 Idempotent**: Safe to re-run, skips already-installed tools
- **📦 Modular**: Each module is standalone and independently runnable
- **🚀 Modern**: Rust/Go replacements for Unix classics (eza, bat, rg, fd...)
- **🤖 AI-first**: Claude Code, Gemini CLI, Aider, MCP, AI editor plugins
- **🔒 Secure**: Objective-See suite, secrets management (sops, age)
- **📁 Organized**: Professional directory structure

## Keyboard Shortcuts Reference

### AeroSpace (Window Manager)
| Key | Action |
|-----|--------|
| `Alt+H/J/K/L` | Focus window (vim-style) |
| `Alt+Shift+H/J/K/L` | Move window |
| `Alt+1..9` | Switch workspace |
| `Alt+Shift+1..9` | Move to workspace |
| `Alt+F` | Toggle fullscreen |
| `Alt+Comma` | Horizontal split |
| `Alt+Period` | Vertical split |

### tmux (Prefix: `Ctrl+A`)
| Key | Action |
|-----|--------|
| `Prefix + \|` | Split vertical |
| `Prefix + -` | Split horizontal |
| `Prefix + h/j/k/l` | Navigate panes |
| `Prefix + d` | Detach |
| `Prefix + [` | Copy mode |

---

## Requirements

- macOS 13 (Ventura) or later
- Apple Silicon or Intel
- ~25 GB free disk space for full install
- Internet connection

## Contributing

This project is modular by design. To add a new tool:
1. Find the relevant module in `modules/`
2. Add a `brew_install` or `npm_global_install` call
3. Test with `./install.sh --modules <module_name>`

---

<div align="center">

Made with ❤️ for developers who care about their environment

*Inspired by the dotfiles community: mathiasbynens, webpro, driesvints, and countless others*

</div>
