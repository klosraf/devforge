<div align="center">

<a href="README.md"><img src="https://img.shields.io/badge/%F0%9F%87%BA%F0%9F%87%B8%20English-ver-0078D4?style=flat-square" /></a>
&nbsp;·&nbsp;
<a href="README.es.md"><img src="https://img.shields.io/badge/%F0%9F%87%AA%F0%9F%87%B8%20Espa%C3%B1ol-actual-C60B1E?style=flat-square" /></a>

<br /><br />

```
██████╗ ███████╗██╗   ██╗███████╗ ██████╗ ██████╗  ██████╗ ███████╗
██╔══██╗██╔════╝██║   ██║██╔════╝██╔═══██╗██╔══██╗██╔════╝ ██╔════╝
██║  ██║█████╗  ██║   ██║█████╗  ██║   ██║██████╔╝██║  ███╗█████╗
██║  ██║██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║   ██║██╔══██╗██║   ██║██╔══╝
██████╔╝███████╗ ╚████╔╝ ██║     ╚██████╔╝██║  ██║╚██████╔╝███████╗
╚═════╝ ╚══════╝  ╚═══╝  ╚═╝      ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝
```

### La Forja Definitiva de Entornos de Desarrollo

*Configuración automatizada para macOS y Linux — 200+ herramientas, 20+ lenguajes, IA integrada*

<br />

[![CI](https://github.com/klosraf/devforge/actions/workflows/ci.yml/badge.svg)](https://github.com/klosraf/devforge/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/klosraf/devforge?color=brightgreen&logo=github)](https://github.com/klosraf/devforge/releases/latest)
[![License](https://img.shields.io/badge/licencia-MIT-blue)](LICENSE)
[![Shell](https://img.shields.io/badge/shell-bash-4EAA25?logo=gnubash&logoColor=white)](install.sh)
[![macOS](https://img.shields.io/badge/macOS-13%2B-000000?logo=apple&logoColor=white)](https://www.apple.com/macos)
[![Linux](https://img.shields.io/badge/Linux-Ubuntu%20%7C%20Debian%20%7C%20Fedora%20%7C%20Manjaro-FCC624?logo=linux&logoColor=black)](modules/linux)
[![Paquete](https://img.shields.io/badge/package-ghcr.io-0db7ed?logo=docker&logoColor=white)](https://github.com/klosraf/devforge/pkgs/container/devforge)

<br />

[⚡ Instalación rápida](#-instalación-rápida) &nbsp;·&nbsp;
[📦 Módulos](#-módulos) &nbsp;·&nbsp;
[🐛 Reportar bug](https://github.com/klosraf/devforge/issues/new?template=bug_report.yml) &nbsp;·&nbsp;
[✨ Solicitar función](https://github.com/klosraf/devforge/issues/new?template=feature_request.yml) &nbsp;·&nbsp;
[💬 Discusiones](https://github.com/klosraf/devforge/discussions)

</div>

---

## 📋 Tabla de contenidos

- [¿Qué es DevForge?](#-qué-es-devforge)
- [Instalación rápida](#-instalación-rápida)
- [Características](#-características)
- [Módulos](#-módulos)
- [Arquitectura](#-arquitectura)
- [Requisitos](#-requisitos)
- [Uso](#-uso)
- [Configuración](#-configuración)
- [Atajos de teclado](#-atajos-de-teclado)
- [Contribuir](#-contribuir)
- [Licencia](#-licencia)

---

## 🔥 ¿Qué es DevForge?

**DevForge** es un instalador de entorno de desarrollo para macOS y Linux con un solo comando. Ejecútalo una vez y obtén una máquina de desarrollo completamente configurada y profesional en minutos.

> Deja de configurar. Empieza a construir.

### ¿Por qué DevForge?

| Sin DevForge | Con DevForge |
|---|---|
| Días configurando una máquina nueva | ~30 min para un entorno completo |
| Instalar manualmente 200+ herramientas | Un comando, todo automatizado |
| Configuración inconsistente entre máquinas | Idempotente, reproducible, versionado |
| Editores genéricos | Todo con tema Catppuccin, IA integrada por defecto |
| Sin gestión de dotfiles | chezmoi + stow + mackup incluidos |
| Herramientas de IA dispersas | Claude Code, Gemini CLI, Aider, servidores MCP configurados |

---

## ⚡ Instalación rápida

```bash
# Instalación completa (selector de módulos interactivo)
curl -fsSL https://raw.githubusercontent.com/klosraf/devforge/main/install.sh | bash

# Clonar y ejecutar localmente
git clone https://github.com/klosraf/devforge.git && cd devforge
./install.sh

# Módulos específicos
./install.sh --modules core,languages,ai
./install.sh --modules editors,terminal

# Utilidades
./install.sh --audit      # Auditar herramientas instaladas
./install.sh --update     # Actualizar todo
./install.sh --help       # Mostrar todas las opciones
```

> **Seguro de re-ejecutar** — DevForge es idempotente. Las herramientas ya instaladas se omiten automáticamente.

---

## ✨ Características

<table>
<tr>
<td width="50%">

### 🎨 Tema Catppuccin Unificado
Cada herramienta configurada con **Catppuccin Macchiato** — Ghostty, WezTerm, Tabby, Neovim, VS Code, Zed, Starship, tmux, Zellij, bat y 30+ más. Una estética, en todas partes.

</td>
<td width="50%">

### 🤖 Desarrollo con IA Integrada
**Claude Code**, Gemini CLI, Aider, GitHub Copilot CLI y 8 agentes de codificación IA más preconfigurados. Servidores MCP para filesystem, GitHub, PostgreSQL, SQLite y Puppeteer listos para usar.

</td>
</tr>
<tr>
<td width="50%">

### 🔄 Totalmente Idempotente
Seguro de ejecutar múltiples veces. DevForge comprueba qué está ya instalado y lo omite. Perfecto para actualizaciones, máquinas nuevas y entornos CI.

</td>
<td width="50%">

### 📦 Verdaderamente Modular
9 módulos independientes. Ejecuta solo lo que necesitas. Cada módulo es un script Bash independiente que se puede ejecutar de forma individual.

</td>
</tr>
<tr>
<td width="50%">

### 🚀 Cadena de Herramientas Unix Modernas
Reemplazos en Rust/Go de herramientas Unix clásicas: `eza` (ls), `bat` (cat), `ripgrep` (grep), `fd` (find), `zoxide` (cd), `dust` (du), `bottom` (top), `procs` (ps). Más rápidas, inteligentes y bonitas.

</td>
<td width="50%">

### 🔒 Suite de Seguridad
LuLu, OverSight y BlockBlock de Objective-See preinstalados. Secretos gestionados con `sops` + `age`. Escaneo de vulnerabilidades con `trivy` y `grype`.

</td>
</tr>
<tr>
<td width="50%">

### 🌍 Multi-Plataforma
macOS 13+ (Apple Silicon e Intel), Ubuntu, Debian, Fedora, Manjaro. El módulo Linux maneja las diferencias de plataforma automáticamente.

</td>
<td width="50%">

### 📁 Gestión de Dotfiles
`chezmoi`, GNU Stow y `mackup` configurados con una estructura profesional `~/.dotfiles`. Sincronización entre máquinas con iCloud y plantillas de secretos vía chezmoi.

</td>
</tr>
</table>

---

## 📦 Módulos

### `core` — Fundación *(80+ herramientas)*

| Categoría | Herramientas |
|---|---|
| Gestor de paquetes | Homebrew + 10 taps |
| Shell | Zsh, Oh My Zsh, 8 plugins, Powerlevel10k |
| Control de versiones | Git, LazyGit, GitUI, `gh`, `glab`, tig |
| **Reemplazos modernos** | `eza`, `bat`, `ripgrep`, `fd`, `fzf`, `zoxide`, `dust`, `duf`, `bottom`, `procs` |
| Procesamiento de texto | `sd`, `jq`, `yq`, `gron`, `jless`, `fx`, `jo`, `miller`, `htmlq` |
| Mejora de shell | `starship`, `atuin`, `mcfly`, `navi`, `tldr`, `thefuck`, `direnv` |
| Ejecutores de tareas | `just`, `make`, `cmake`, `ninja` |
| Herramientas TUI | `gum`, `lolcat`, `figlet`, `pastel` |
| Análisis de código | `tokei`, `cloc`, `onefetch`, `grex` |
| Red | `curl`, `wget`, `httpie`, `xh`, `curlie` |
| Multiplexores | `tmux`, `zellij`, `mprocs` |
| Seguridad | `age`, `sops` |

### `languages` — 20+ Lenguajes de Programación

| Lenguaje | Herramientas |
|---|---|
| **Node.js** | mise, n, pnpm, bun, deno, TypeScript |
| **Python** | pyenv, uv, rye, pipx · Python 3.11 / 3.12 / 3.13 |
| **Rust** | rustup, targets wasm, clippy, rustfmt, cargo-watch |
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

### `frameworks` — Librerías y DevOps

| Área | Herramientas |
|---|---|
| **JS/TS** | Vite, Turbo, Nx, Next.js, Remix, Vue, Svelte, Angular, Astro, Qwik |
| **Testing** | Jest, Vitest, Playwright, Cypress |
| **Tooling** | ESLint, Prettier, Biome, Prisma, Drizzle, Storybook |
| **Python** | FastAPI, Django, Flask, NumPy, Pandas, PyTorch, LangChain |
| **DevOps** | Docker, Colima, kubectl, Helm, k9s, k3d, kind |
| **Cloud** | AWS CLI, Azure CLI, gcloud, doctl, flyctl, Vercel |
| **Bases de datos** | PostgreSQL, MySQL, Redis, MongoDB, SQLite, InfluxDB |
| **Seguridad** | nmap, trivy, grype, trufflehog, semgrep |
| **API** | gRPC, protobuf, buf, GraphQL |

### `editors` — Editores de Código

| Editor | Configuración |
|---|---|
| **VS Code** | 80+ extensiones · Catppuccin · `settings.json` + `keybindings.json` completos |
| **Cursor** | Fork VS Code con IA · todas las extensiones de VS Code |
| **Zed** | Catppuccin · JetBrainsMono · asistente Claude · configuración completa |
| **Neovim** | LazyVim + 30+ plugins: Copilot, Avante/Claude, CopilotChat, CodeCompanion, Harpoon2, Flash, Oil, Neogit, Trouble, Aerial, Telescope |
| **Helix** | Catppuccin · líneas relativas · atajos personalizados · LSP |
| **JetBrains** | Toolbox instalado |
| **Emacs** | Doom Emacs |

### `terminal` — Entorno de Shell

| Herramienta | Configuración |
|---|---|
| **Ghostty** | Catppuccin Macchiato · blur 20 · JetBrainsMono 14 |
| **WezTerm** | Configuración Lua · Catppuccin · barra de pestañas personalizada |
| **Tabby** | Catppuccin · vibrancy · agente SSH |
| **Starship** | Paleta Catppuccin completa · 15+ segmentos |
| **tmux** | Estado Catppuccin · plugins TPM · navegación vim |
| **Zellij** | Catppuccin · esquinas redondeadas |
| **Fuentes** | 17 Nerd Fonts: JetBrainsMono, Geist, Monaspace, Cascadia, Maple Mono, Victor Mono + más |
| **.zshrc** | 20 plugins Oh My Zsh · 80+ aliases · funciones personalizadas |

### `macos` — Configuración del Sistema

- Modo oscuro · colores de énfasis · optimización del trackpad
- Dock: autoocultamiento · apps personalizadas · sin apps recientes
- Finder: mostrar todos los archivos · barra de rutas · vista de lista
- Capturas de pantalla → `~/Desktop/Screenshots`
- Gestor de ventanas **AeroSpace**: `alt+hjkl` · espacios de trabajo 1–9
- Raycast · Rectangle Pro

### `apps` — Aplicaciones *(80+)*

| Categoría | Apps |
|---|---|
| Navegadores | Arc, Firefox, Brave, Chrome |
| Herramientas API | HTTPie Desktop, Insomnia, Postman, Proxyman, Charles |
| GUIs de BD | TablePlus, DBeaver, MongoDB Compass, RedisInsight, Beekeeper Studio |
| GUIs de Git | Fork, SourceTree, GitKraken, GitHub Desktop |
| Diseño | Figma, Sketch, ImageOptim |
| Notas | Obsidian, Notion, Logseq, Bear |
| Productividad | Raycast, Maccy, Alfred, PopClip |
| Seguridad | LuLu, OverSight, BlockBlock, Bitwarden, 1Password |
| IA de escritorio | Ollama, LM Studio, Jan, AnythingLLM |
| Multimedia | VLC, OBS, IINA, HandBrake |

### `ai` — Agentes de Codificación IA ⭐ *v3.0+*

| Herramienta | Descripción |
|---|---|
| **Claude Code** | Codificador terminal agéntico de Anthropic |
| **Gemini CLI** | Terminal IA gratuito de Google (1.000 solicitudes/día) |
| **Aider** | Programador en pareja IA nativo de Git (30+ LLMs) |
| **GitHub Copilot CLI** | Copilot en tu terminal |
| **Continue** | Asistente de codificación IA de código abierto |
| **OpenCode** | Agente IA terminal de código abierto |
| **LLM CLI** | Herramienta de 100+ LLMs de Simon Willison |
| **Modelos Ollama** | codellama, llama3.2, mistral, deepseek-coder, qwen2.5-coder |
| **Servidores MCP** | filesystem, github, gitlab, postgres, sqlite, puppeteer, brave-search |

### `dotfiles` — Gestión de Dotfiles ⭐ *v3.0+*

| Herramienta | Propósito |
|---|---|
| **chezmoi** | Dotfiles entre máquinas con plantillas y secretos |
| **GNU Stow** | Gestor de granja de enlaces simbólicos |
| **Mackup** | Backup y restauración de configuraciones de apps (sincronización iCloud) |
| **YADM** | Gestor de dotfiles basado en Git |
| **Dockutil** | Gestión del Dock de macOS desde CLI |

### `ios` y `android` — Desarrollo Móvil

- **iOS:** Xcode, CocoaPods, xcbeautify, xclogparser, fastlane, Swift Package Manager
- **Android:** Android Studio, herramientas SDK, Gradle, ADB, fastlane

---

## 🏗️ Arquitectura

```
devforge/
├── install.sh              # Punto de entrada TUI principal (v4.1.0)
├── lib/
│   ├── ui.sh               # Librería TUI — colores, spinners, menús, barras de progreso
│   ├── lang.sh             # i18n — strings en inglés y español
│   └── utils.sh            # Helpers — brew_install, run_task, detección de SO
├── modules/
│   ├── core.sh             # Fundación: Homebrew, 80+ herramientas CLI, Git, Zsh
│   ├── languages.sh        # 20+ lenguajes + gestores de versiones
│   ├── frameworks.sh       # Frameworks, DevOps, bases de datos, cloud
│   ├── editors.sh          # VS Code, Neovim, Zed, Cursor, Helix, JetBrains
│   ├── terminal.sh         # Ghostty, WezTerm, Tabby, tmux, Starship, shell
│   ├── macos.sh            # Configuración del sistema macOS y AeroSpace
│   ├── apps.sh             # 80+ aplicaciones de código abierto
│   ├── ai.sh               # Agentes de codificación IA y servidores MCP
│   ├── dotfiles.sh         # chezmoi, stow, mackup
│   ├── ios.sh              # Xcode, fastlane, cadena de herramientas iOS
│   ├── android.sh          # SDK Android, Studio, fastlane
│   └── linux/              # Overrides específicos de Linux
├── config/
│   ├── Brewfile            # 200+ paquetes Homebrew
│   ├── vscode/             # settings.json + keybindings.json
│   ├── neovim/             # Configuración LazyVim + plugins IA
│   ├── dotfiles/           # Plantillas de dotfiles
│   ├── fonts/              # 17 Nerd Fonts
│   └── claude/             # Configuración de Claude Code
└── devforge/               # Documentación del proyecto
```

---

## 🖥️ Requisitos

| Requisito | Mínimo | Notas |
|---|---|---|
| **macOS** | 13 Ventura | Apple Silicon + Intel soportados |
| **Linux** | Ubuntu 20.04 / Debian 11 / Fedora 36 / Manjaro | via `modules/linux/` |
| **Espacio en disco** | ~10 GB (mínimo) | ~25 GB para instalación completa |
| **RAM** | 8 GB | 16 GB recomendados para todos los módulos |
| **Internet** | Requerido | Descargas de Homebrew + npm + cargo |

---

## 🔧 Uso

```bash
# Selector de módulos interactivo (recomendado)
./install.sh

# Instalar todos los módulos a la vez
./install.sh --all

# Instalar módulos específicos
./install.sh --modules core,languages
./install.sh --modules editors,terminal,ai

# Utilidades del sistema
./install.sh --audit        # Comprobar qué está instalado vs. faltante
./install.sh --update       # Actualizar todas las herramientas instaladas
./install.sh --uninstall    # Eliminar herramientas gestionadas por DevForge (interactivo)
./install.sh --dry-run      # Previsualizar qué se instalaría
./install.sh --verbose      # Salida detallada
./install.sh --help         # Texto de ayuda completo
```

### Ejecutar módulos individuales

```bash
# Ejecutar cualquier módulo directamente
bash modules/core.sh
bash modules/languages.sh
bash modules/ai.sh
```

---

## ⚙️ Configuración

Personaliza antes de ejecutar editando los archivos en `config/`:

| Archivo | Propósito |
|---|---|
| `config/Brewfile` | Añadir/eliminar paquetes Homebrew |
| `config/vscode/settings.json` | Preferencias de VS Code |
| `config/vscode/extensions.txt` | Lista de extensiones |
| `config/neovim/lua/plugins/devforge.lua` | Configuración de plugins Neovim |
| `config/dotfiles/.zshrc` | Aliases y funciones de shell |

---

## ⌨️ Atajos de Teclado

### AeroSpace (Gestor de Ventanas)

| Atajo | Acción |
|---|---|
| `Alt + H/J/K/L` | Enfocar ventana (estilo vim) |
| `Alt + Shift + H/J/K/L` | Mover ventana |
| `Alt + 1–9` | Cambiar espacio de trabajo |
| `Alt + Shift + 1–9` | Mover ventana al espacio de trabajo |
| `Alt + F` | Alternar pantalla completa |
| `Alt + ,` | División horizontal |
| `Alt + .` | División vertical |
| `Alt + D` | Aplanar diseño |

### tmux *(Prefijo: `Ctrl+A`)*

| Atajo | Acción |
|---|---|
| `Prefijo + \|` | Dividir panel vertical |
| `Prefijo + -` | Dividir panel horizontal |
| `Prefijo + h/j/k/l` | Navegar paneles |
| `Prefijo + d` | Desconectar sesión |
| `Prefijo + [` | Modo de copia |
| `Prefijo + r` | Recargar configuración |

### Neovim *(Líder: `Espacio`)*

| Atajo | Acción |
|---|---|
| `<líder>ff` | Buscar archivos (Telescope) |
| `<líder>fg` | Búsqueda en vivo |
| `<líder>ca` | Acción de código |
| `<líder>e` | Explorador de archivos (Oil) |
| `<líder>gg` | Abrir Neogit |
| `<C-a>` | Abrir IA Avante (Claude) |
| `<líder>m` | Marcar con Harpoon |
| `<líder>h` | Lista de Harpoon |

---

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Lee [CONTRIBUTING.md](.github/CONTRIBUTING.md) primero.

```bash
# Fork → clonar
git clone https://github.com/TU_USUARIO/devforge.git

# Crear rama
git checkout -b feat/nombre-herramienta

# Realizar cambios, validar
shellcheck modules/*.sh lib/*.sh

# Commit (Conventional Commits)
git commit -m "feat(ai): añadir editor IA Windsurf"

# Push y abrir PR
git push origin feat/nombre-herramienta
```

Consulta los [issues abiertos](https://github.com/klosraf/devforge/issues) para primeras contribuciones.

---

## 📜 Licencia

[MIT](LICENSE) © 2026 DevForge

---

<div align="center">

Hecho con ❤️ para desarrolladores que cuidan su entorno

*Inspirado en la comunidad de dotfiles: [mathiasbynens](https://github.com/mathiasbynens/dotfiles), [webpro](https://github.com/webpro/dotfiles), [driesvints](https://github.com/driesvints/dotfiles), y muchos otros*

[![GitHub stars](https://img.shields.io/github/stars/klosraf/devforge?style=social)](https://github.com/klosraf/devforge/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/klosraf/devforge?style=social)](https://github.com/klosraf/devforge/network/members)

</div>
