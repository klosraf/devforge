<div align="center">

<a href="README.md"><img src="https://img.shields.io/badge/%F0%9F%87%BA%F0%9F%87%B8%20English-current-0078D4?style=flat-square" /></a>
&nbsp;·&nbsp;
<a href="README.es.md"><img src="https://img.shields.io/badge/%F0%9F%87%AA%F0%9F%87%B8%20Espa%C3%B1ol-ver-C60B1E?style=flat-square" /></a>

<br /><br />

```
██████╗ ███████╗██╗   ██╗███████╗ ██████╗ ██████╗  ██████╗ ███████╗
██╔══██╗██╔════╝██║   ██║██╔════╝██╔═══██╗██╔══██╗██╔════╝ ██╔════╝
██║  ██║█████╗  ██║   ██║█████╗  ██║   ██║██████╔╝██║  ███╗█████╗
██║  ██║██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║   ██║██╔══██╗██║   ██║██╔══╝
██████╔╝███████╗ ╚████╔╝ ██║     ╚██████╔╝██║  ██║╚██████╔╝███████╗
╚═════╝ ╚══════╝  ╚═══╝  ╚═╝      ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝
```

### The Ultimate Developer Environment Forge

*Automated setup for macOS & Linux — 200+ tools, 20+ languages, AI-first*

<br />

[![CI](https://github.com/klosraf/devforge/actions/workflows/ci.yml/badge.svg)](https://github.com/klosraf/devforge/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/klosraf/devforge?color=brightgreen&logo=github)](https://github.com/klosraf/devforge/releases/latest)
[![License](https://img.shields.io/badge/license-MIT-blue)](LICENSE)
[![Shell](https://img.shields.io/badge/shell-bash-4EAA25?logo=gnubash&logoColor=white)](install.sh)
[![macOS](https://img.shields.io/badge/macOS-13%2B-000000?logo=apple&logoColor=white)](https://www.apple.com/macos)
[![Linux](https://img.shields.io/badge/Linux-Ubuntu%20%7C%20Debian%20%7C%20Fedora%20%7C%20Manjaro-FCC624?logo=linux&logoColor=black)](modules/linux)
[![Package](https://img.shields.io/badge/package-ghcr.io-0db7ed?logo=docker&logoColor=white)](https://github.com/klosraf/devforge/pkgs/container/devforge)

<br />

[⚡ Quick Install](#-quick-install) &nbsp;·&nbsp;
[📦 Modules](#-modules) &nbsp;·&nbsp;
[🐛 Report Bug](https://github.com/klosraf/devforge/issues/new?template=bug_report.yml) &nbsp;·&nbsp;
[✨ Request Feature](https://github.com/klosraf/devforge/issues/new?template=feature_request.yml) &nbsp;·&nbsp;
[💬 Discussions](https://github.com/klosraf/devforge/discussions)

</div>

---

## 📋 Table of Contents

- [What is DevForge?](#-what-is-devforge)
- [Quick Install](#-quick-install)
- [Features](#-features)
- [Modules](#-modules)
- [Architecture](#-architecture)
- [Requirements](#-requirements)
- [Usage](#-usage)
- [Configuration](#-configuration)
- [Keyboard Shortcuts](#-keyboard-shortcuts)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🔥 What is DevForge?

**DevForge** is a single-command macOS & Linux developer environment installer. Run it once — get a fully configured, professional development machine in minutes.

> Stop configuring. Start building.

### Why DevForge?

| Without DevForge | With DevForge |
|---|---|
| Days setting up a new machine | ~30 min for a full environment |
| Manually installing 200+ tools | One command, everything automated |
| Inconsistent config across machines | Idempotent, reproducible, version-controlled |
| Generic editor setup | Catppuccin-themed everything, AI-first by default |
| No dotfiles management | chezmoi + stow + mackup included |
| AI tools scattered everywhere | Claude Code, Gemini CLI, Aider, MCP servers configured |

---

## ⚡ Quick Install

```bash
# Full install (interactive module selector)
curl -fsSL https://raw.githubusercontent.com/klosraf/devforge/main/install.sh | bash

# Clone and run locally
git clone https://github.com/klosraf/devforge.git && cd devforge
./install.sh

# Specific modules
./install.sh --modules core,languages,ai
./install.sh --modules editors,terminal

# Utilities
./install.sh --audit      # Audit installed tools
./install.sh --update     # Update everything
./install.sh --help       # Show all options
```

> **Safe to re-run** — DevForge is idempotent. Already-installed tools are skipped automatically.

---

## ✨ Features

<table>
<tr>
<td width="50%">

### 🎨 Unified Catppuccin Theme
Every tool configured with **Catppuccin Macchiato** — Ghostty, WezTerm, Tabby, Neovim, VS Code, Zed, Starship, tmux, Zellij, bat, and 30+ more tools. One aesthetic, everywhere.

</td>
<td width="50%">

### 🤖 AI-First Development
**Claude Code**, Gemini CLI, Aider, GitHub Copilot CLI, and 8 more AI coding agents pre-configured. MCP servers for filesystem, GitHub, PostgreSQL, SQLite, and Puppeteer ready to go.

</td>
</tr>
<tr>
<td width="50%">

### 🔄 Fully Idempotent
Safe to run multiple times. DevForge checks what's already installed and skips it. Perfect for updates, new machines, and CI environments.

</td>
<td width="50%">

### 📦 Truly Modular
9 independent modules. Run only what you need. Each module is a standalone Bash script that can be executed individually without dependencies on other modules.

</td>
</tr>
<tr>
<td width="50%">

### 🚀 Modern Unix Toolchain
Rust/Go rewrites of classic Unix tools: `eza` (ls), `bat` (cat), `ripgrep` (grep), `fd` (find), `zoxide` (cd), `dust` (du), `bottom` (top), `procs` (ps). Faster, smarter, prettier.

</td>
<td width="50%">

### 🔒 Security Suite
Objective-See's LuLu, OverSight, and BlockBlock pre-installed. Secrets managed with `sops` + `age`. Vulnerability scanning with `trivy` and `grype`. API keys stay in keyrings, not env files.

</td>
</tr>
<tr>
<td width="50%">

### 🌍 Multi-Platform
macOS 13+ (Apple Silicon & Intel), Ubuntu, Debian, Fedora, Manjaro. Linux-specific module handles platform differences automatically.

</td>
<td width="50%">

### 📁 Dotfiles Management
`chezmoi`, GNU Stow, and `mackup` configured with a professional `~/.dotfiles` structure. Cross-machine sync with iCloud and secrets templating via chezmoi.

</td>
</tr>
</table>

---

## 📦 Modules

### `core` — Foundation *(80+ tools)*

| Category | Tools |
|---|---|
| Package Manager | Homebrew + 10 taps |
| Shell | Zsh, Oh My Zsh, 8 plugins, Powerlevel10k |
| Version Control | Git, LazyGit, GitUI, `gh`, `glab`, tig |
| **Modern Replacements** | `eza`, `bat`, `ripgrep`, `fd`, `fzf`, `zoxide`, `dust`, `duf`, `bottom`, `procs` |
| Text Processing | `sd`, `jq`, `yq`, `gron`, `jless`, `fx`, `jo`, `miller`, `htmlq` |
| Shell Enhancement | `starship`, `atuin`, `mcfly`, `navi`, `tldr`, `thefuck`, `direnv` |
| Task Runners | `just`, `make`, `cmake`, `ninja` |
| TUI Tools | `gum`, `lolcat`, `figlet`, `pastel` |
| Code Analysis | `tokei`, `cloc`, `onefetch`, `grex` |
| Network | `curl`, `wget`, `httpie`, `xh`, `curlie` |
| Multiplexers | `tmux`, `zellij`, `mprocs` |
| Security | `age`, `sops` |

### `languages` — 20+ Programming Languages

| Language | Tools |
|---|---|
| **Node.js** | mise, n, pnpm, bun, deno, TypeScript |
| **Python** | pyenv, uv, rye, pipx · Python 3.11 / 3.12 / 3.13 |
| **Rust** | rustup, wasm targets, clippy, rustfmt, cargo-watch |
| **Go** | gopls, dlv, golangci-lint |
| **Ruby** | rbenv, bundler |
| **Java** | OpenJDK 17 + 21, Maven, Gradle |
| **Swift** | SwiftLint, SwiftFormat, XcodeGen |
| **Dart/Flutter** | Flutter SDK |
| **Elixir** | Erlang, Phoenix |
| **C/C++** | LLVM, GCC, Conan |
| **Haskell** | GHC, Stack, HLS |
| **Zig** | ZLS |
| **WebAssembly** | wasmtime, wasm-pack |
| + Kotlin, PHP, Lua, R, Julia, Scala, Clojure | via SDKMAN, Homebrew |

### `frameworks` — Libraries & DevOps

| Area | Tools |
|---|---|
| **JS/TS** | Vite, Turbo, Nx, Next.js, Remix, Vue, Svelte, Angular, Astro, Qwik |
| **Testing** | Jest, Vitest, Playwright, Cypress |
| **Tooling** | ESLint, Prettier, Biome, Prisma, Drizzle, Storybook |
| **Python** | FastAPI, Django, Flask, NumPy, Pandas, PyTorch, LangChain |
| **DevOps** | Docker, Colima, kubectl, Helm, k9s, k3d, kind |
| **Cloud** | AWS CLI, Azure CLI, gcloud, doctl, flyctl, Vercel |
| **Databases** | PostgreSQL, MySQL, Redis, MongoDB, SQLite, InfluxDB |
| **Security** | nmap, trivy, grype, trufflehog, semgrep |
| **API** | gRPC, protobuf, buf, GraphQL |

### `editors` — Code Editors

| Editor | Configuration |
|---|---|
| **VS Code** | 80+ extensions · Catppuccin · full `settings.json` + `keybindings.json` |
| **Cursor** | AI-first VS Code fork · all VS Code extensions |
| **Zed** | Catppuccin · JetBrainsMono · Claude assistant · full settings |
| **Neovim** | LazyVim + 30+ plugins: Copilot, Avante/Claude, CopilotChat, CodeCompanion, Harpoon2, Flash, Oil, Neogit, Trouble, Aerial, Telescope |
| **Helix** | Catppuccin · relative lines · custom keybinds · LSP |
| **JetBrains** | Toolbox installed |
| **Emacs** | Doom Emacs |

**VS Code extensions:** AI (6) · Git (7) · JS/TS (15) · Python (8) · Rust (4) · Database (8) · Testing (5) · DevOps (8) · Productivity (15) · Theme (6)

### `terminal` — Shell Environment

| Tool | Configuration |
|---|---|
| **Ghostty** | Catppuccin Macchiato · blur 20 · JetBrainsMono 14 |
| **WezTerm** | Lua config · Catppuccin · custom tab bar |
| **Tabby** | Catppuccin · vibrancy · SSH agent |
| **Starship** | Full Catppuccin palette · 15+ segments |
| **tmux** | Catppuccin status · TPM plugins · vim navigation |
| **Zellij** | Catppuccin · rounded corners |
| **Fonts** | 17 Nerd Fonts: JetBrainsMono, Geist, Monaspace, Cascadia, Maple Mono, Victor Mono + more |
| **.zshrc** | 20 Oh My Zsh plugins · 80+ aliases · custom functions |

### `macos` — System Defaults

- Dark mode · accent colors · trackpad acceleration
- Dock: autohide · custom apps · no recent apps
- Finder: show all files · path bar · list view
- Screenshots → `~/Desktop/Screenshots`
- **AeroSpace** window manager: `alt+hjkl` · workspaces 1–9
- Raycast · Rectangle Pro

### `apps` — Applications *(80+)*

| Category | Apps |
|---|---|
| Browsers | Arc, Firefox, Brave, Chrome |
| API Tools | HTTPie Desktop, Insomnia, Postman, Proxyman, Charles |
| Database GUIs | TablePlus, DBeaver, MongoDB Compass, RedisInsight, Beekeeper Studio |
| Git GUIs | Fork, SourceTree, GitKraken, GitHub Desktop |
| Design | Figma, Sketch, ImageOptim |
| Notes | Obsidian, Notion, Logseq, Bear |
| Productivity | Raycast, Maccy, Alfred, PopClip |
| Security | LuLu, OverSight, BlockBlock, Bitwarden, 1Password |
| AI Desktop | Ollama, LM Studio, Jan, AnythingLLM |
| Media | VLC, OBS, IINA, HandBrake |

### `ai` — AI Coding Agents ⭐ *v3.0+*

| Tool | Description |
|---|---|
| **Claude Code** | Anthropic's agentic terminal coder |
| **Gemini CLI** | Google's free AI terminal (1,000 req/day) |
| **Aider** | Git-native AI pair programmer (30+ LLMs) |
| **GitHub Copilot CLI** | Copilot in your terminal |
| **Continue** | Open-source AI coding assistant |
| **OpenCode** | Open-source terminal AI agent |
| **LLM CLI** | Simon Willison's 100+ LLM tool |
| **Ollama models** | codellama, llama3.2, mistral, deepseek-coder, qwen2.5-coder |
| **MCP Servers** | filesystem, github, gitlab, postgres, sqlite, puppeteer, brave-search |

### `dotfiles` — Dotfiles Management ⭐ *v3.0+*

| Tool | Purpose |
|---|---|
| **chezmoi** | Cross-machine dotfiles with templates & secrets |
| **GNU Stow** | Symlink farm manager |
| **Mackup** | Backup & restore app settings (iCloud sync) |
| **YADM** | Git-based dotfiles manager |
| **Dockutil** | macOS Dock management from CLI |

### `ios` & `android` — Mobile Development

- **iOS:** Xcode, CocoaPods, xcbeautify, xclogparser, fastlane, Swift Package Manager
- **Android:** Android Studio, SDK tools, Gradle, ADB, fastlane

---

## 🏗️ Architecture

```
devforge/
├── install.sh              # Main TUI entry point (v4.1.0)
├── lib/
│   ├── ui.sh               # TUI library — colors, spinners, menus, progress bars
│   ├── lang.sh             # i18n — English & Spanish strings
│   └── utils.sh            # Helpers — brew_install, run_task, OS detection
├── modules/
│   ├── core.sh             # Foundation: Homebrew, 80+ CLI tools, Git, Zsh
│   ├── languages.sh        # 20+ languages + version managers
│   ├── frameworks.sh       # Frameworks, DevOps, databases, cloud
│   ├── editors.sh          # VS Code, Neovim, Zed, Cursor, Helix, JetBrains
│   ├── terminal.sh         # Ghostty, WezTerm, Tabby, tmux, Starship, shell
│   ├── macos.sh            # macOS system defaults & AeroSpace
│   ├── apps.sh             # 80+ open-source applications
│   ├── ai.sh               # AI coding agents & MCP servers
│   ├── dotfiles.sh         # chezmoi, stow, mackup
│   ├── ios.sh              # Xcode, fastlane, iOS toolchain
│   ├── android.sh          # Android SDK, Studio, fastlane
│   └── linux/              # Linux-specific overrides
├── config/
│   ├── Brewfile            # 200+ Homebrew packages
│   ├── vscode/             # settings.json + keybindings.json
│   ├── neovim/             # LazyVim config + AI plugins
│   ├── dotfiles/           # Template dotfiles
│   ├── fonts/              # 17 Nerd Fonts
│   └── claude/             # Claude Code configuration
└── devforge/               # Project docs
```

---

## 🖥️ Requirements

| Requirement | Minimum | Notes |
|---|---|---|
| **macOS** | 13 Ventura | Apple Silicon + Intel supported |
| **Linux** | Ubuntu 20.04 / Debian 11 / Fedora 36 / Manjaro | via `modules/linux/` |
| **Disk space** | ~10 GB (minimal) | ~25 GB for full install |
| **RAM** | 8 GB | 16 GB recommended for all modules |
| **Internet** | Required | Homebrew + npm + cargo downloads |

---

## 🔧 Usage

```bash
# Interactive module selector (recommended)
./install.sh

# Install all modules at once
./install.sh --all

# Install specific modules
./install.sh --modules core,languages
./install.sh --modules editors,terminal,ai

# System utilities
./install.sh --audit        # Check what's installed vs. missing
./install.sh --update       # Update all installed tools
./install.sh --uninstall    # Remove DevForge-managed tools (interactive)
./install.sh --dry-run      # Preview what would be installed
./install.sh --verbose      # Detailed output
./install.sh --help         # Full help text
```

### Running individual modules

```bash
# Run any module directly
bash modules/core.sh
bash modules/languages.sh
bash modules/ai.sh
```

---

## ⚙️ Configuration

Customize before running by editing files in `config/`:

| File | Purpose |
|---|---|
| `config/Brewfile` | Add/remove Homebrew packages |
| `config/vscode/settings.json` | VS Code preferences |
| `config/vscode/extensions.txt` | Extension list |
| `config/neovim/lua/plugins/devforge.lua` | Neovim plugin config |
| `config/dotfiles/.zshrc` | Shell aliases and functions |

---

## ⌨️ Keyboard Shortcuts

### AeroSpace (Window Manager)

| Shortcut | Action |
|---|---|
| `Alt + H/J/K/L` | Focus window (vim-style) |
| `Alt + Shift + H/J/K/L` | Move window |
| `Alt + 1–9` | Switch workspace |
| `Alt + Shift + 1–9` | Move window to workspace |
| `Alt + F` | Toggle fullscreen |
| `Alt + ,` | Split horizontal |
| `Alt + .` | Split vertical |
| `Alt + D` | Flatten layout |

### tmux *(Prefix: `Ctrl+A`)*

| Shortcut | Action |
|---|---|
| `Prefix + \|` | Split pane vertical |
| `Prefix + -` | Split pane horizontal |
| `Prefix + h/j/k/l` | Navigate panes |
| `Prefix + d` | Detach session |
| `Prefix + [` | Enter copy mode |
| `Prefix + r` | Reload config |

### Neovim *(Leader: `Space`)*

| Shortcut | Action |
|---|---|
| `<leader>ff` | Find files (Telescope) |
| `<leader>fg` | Live grep |
| `<leader>ca` | Code action |
| `<leader>e` | File explorer (Oil) |
| `<leader>gg` | Open Neogit |
| `<C-a>` | Open Avante AI (Claude) |
| `<leader>m` | Harpoon mark |
| `<leader>h` | Harpoon list |

---

## 🤝 Contributing

Contributions are welcome! Read [CONTRIBUTING.md](.github/CONTRIBUTING.md) first.

```bash
# Fork → clone
git clone https://github.com/YOUR_USERNAME/devforge.git

# Create branch
git checkout -b feat/add-tool-name

# Make changes, validate
shellcheck modules/*.sh lib/*.sh

# Commit (Conventional Commits)
git commit -m "feat(ai): add Windsurf AI editor"

# Push & open PR
git push origin feat/add-tool-name
```

See [open issues](https://github.com/klosraf/devforge/issues) for good first contributions.

---

## 📜 License

[MIT](LICENSE) © 2026 DevForge

---

<div align="center">

Made with ❤️ for developers who care about their environment

*Inspired by the dotfiles community: [mathiasbynens](https://github.com/mathiasbynens/dotfiles), [webpro](https://github.com/webpro/dotfiles), [driesvints](https://github.com/driesvints/dotfiles), and countless others*

[![GitHub stars](https://img.shields.io/github/stars/klosraf/devforge?style=social)](https://github.com/klosraf/devforge/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/klosraf/devforge?style=social)](https://github.com/klosraf/devforge/network/members)

</div>
