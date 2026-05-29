# Changelog

All notable changes to DevForge are documented in this file.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) · Versioning: [SemVer](https://semver.org/)

---

## [4.1.0] — 2026-05-28

### Added

#### Core Infrastructure
- Xcode Command Line Tools auto-installer with 5-minute wait loop
- Rosetta 2 silent install on Apple Silicon
- Homebrew auto-installer with ARM/Intel path detection
- `state.json` progress tracking — skips already-installed tools on re-run
- Module loader with isolated error handling (`load_module()`)
- `--audit`, `--update`, `--modules`, `--help` CLI flags
- Log file at `~/.devforge/devforge.log` with timestamped entries

#### Modules
- **`core`** — Homebrew + 80+ foundational CLI tools (bat, eza, fd, ripgrep, fzf, zoxide, starship, chezmoi, stow, mackup, lazygit, delta, gh, gum, atuin, mods, gitmux, AeroSpace, yabai, skhd, etc.)
- **`languages`** — Node.js + pnpm + Bun + Deno, Python 3.11/3.12/3.13 + pyenv + uv + pipx, Rust + cargo tooling (nextest, sccache, watchexec, mold), Go, Ruby + rbenv, Java 17/21 + Maven + Gradle + Kotlin + Scala + Clojure, PHP + Composer, Swift toolchain, Dart + FVM
- **`frameworks`** — React 18, Next.js, Vue 3, Nuxt, Svelte, Astro, SolidJS, Qwik, Angular, Nest.js, Fastify, Hono, Express, Django, FastAPI, Flask, Laravel, Rails, Spring Boot, Actix, Axum
- **`editors`** — Neovim (nightly) + LazyVim config, VS Code + Cursor + Zed with Catppuccin theme + extensions bundle, Sublime Text 4, Fleet
- **`terminal`** — iTerm2 + Warp + Alacritty + WezTerm, tmux + tpm + Catppuccin theme, oh-my-zsh + Powerlevel10k, zsh-autosuggestions + zsh-syntax-highlighting, aerospace tiling config
- **`macos`** — System preferences (Dock, Mission Control, screenshots, key repeat), Finder defaults, Safari dev tools, macOS font smoothing, symlinks for global CLI access
- **`apps`** — 1Password, Raycast, Notion, Figma, Slack, Discord, Zoom, CleanMyMac, Proxyman, Paw/RapidAPI, TablePlus, Postico, MongoDB Compass, Redis Insight, Docker Desktop, OrbStack
- **`dotfiles`** — chezmoi init + apply, GNU stow for config trees, mackup backup/restore, XDG config dir setup
- **`ai`** — Claude Code CLI, Gemini CLI, Aider, Cursor rules config, MCP servers (filesystem, git, sequential-thinking), `~/.ai/` workspace scaffold
- **`ios`** — Xcode (App Store), CocoaPods, Fastlane, xcbeautify, iOS Simulator config, Instruments CLI, xcode-select paths
- **`android`** — Android Studio, Android SDK + NDK via sdkmanager, Flutter + FVM, Gradle daemon tuning, AVD creation, `ANDROID_HOME` env setup

#### Linux Support
- **`linux/core.sh`** — apt/dnf/pacman auto-detection, same 80+ tools via native package managers + Linuxbrew fallback
- Tested on Ubuntu 22.04/24.04, Debian 12, Fedora 40, Manjaro

#### Library (`lib/`)
- `ui.sh` — Progress bars, spinners, section headers, color theming (Catppuccin Macchiato)
- `lang.sh` — i18n EN/ES runtime switching (`DEVFORGE_LANG` env var)
- `utils.sh` — `brew_install`, `npm_global_install`, `cargo_install`, `has_cmd`, `require_macos`, `detect_system`, `track_ok/skip/fail`

#### GitHub Integration
- Issue templates: Bug Report, Feature Request, Module Request, Tool Request, Documentation
- Pull Request template with ShellCheck + idempotency checklist
- Contributing guide with module authoring patterns
- Security policy with responsible disclosure process
- Code of Conduct (Contributor Covenant v2.1)
- Release notes categories config

### Changed
- Version bumped from 3.0.0 → 4.1.0
- Unified Catppuccin Macchiato color palette across all terminal output
- All modules now source `lib/utils.sh` via relative path for portability
- `brew_install` now appends to log file instead of printing raw brew output

### Fixed
- `homebrew/cask-fonts` and `homebrew/cask-versions` taps removed (deprecated 2024)
- Rosetta 2 detection now uses `pgrep oahd` instead of checking binary path

---

## [3.0.0] — 2025-01-01

### Added
- Initial public release
- macOS-only support
- Core, languages, editors, terminal modules
- Homebrew-based installation

---

[4.1.0]: https://github.com/klosraf/devforge/compare/3.0.0...v4.1.0
[3.0.0]: https://github.com/klosraf/devforge/releases/tag/3.0.0
