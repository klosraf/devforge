#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────
#  lang.sh — Sistema de idiomas DevForge
#  Soporta: English (en) | Español (es)
#
#  Uso:
#    source lib/lang.sh
#    lang_set "es"           # establecer idioma
#    lang_set "en"
#    lang_load               # recargar el idioma activo
#    echo "${L_INSTALLING}"  # usar string
# ─────────────────────────────────────────────────────────────────

# ── Config file ───────────────────────────────────────────────────
DEVFORGE_CONFIG_DIR="${HOME}/.devforge"
DEVFORGE_CONFIG_FILE="${DEVFORGE_CONFIG_DIR}/config.sh"
DEVFORGE_LANG="${DEVFORGE_LANG:-en}"

# ── Guardar / cargar preferencia ─────────────────────────────────
lang_save() {
  mkdir -p "${DEVFORGE_CONFIG_DIR}" 2>/dev/null || true
  echo "DEVFORGE_LANG=\"${DEVFORGE_LANG}\"" > "${DEVFORGE_CONFIG_FILE}"
}

lang_load_saved() {
  if [[ -f "${DEVFORGE_CONFIG_FILE}" ]]; then
    source "${DEVFORGE_CONFIG_FILE}" 2>/dev/null || true
  fi
}

# ── Establecer idioma y cargar strings ───────────────────────────
lang_set() {
  DEVFORGE_LANG="${1:-en}"
  lang_save
  lang_load
}

lang_load() {
  case "${DEVFORGE_LANG}" in
    es) _load_es ;;
    *)  _load_en ;;
  esac
}

# ════════════════════════════════════════════════════════════════
#  ENGLISH
# ════════════════════════════════════════════════════════════════
_load_en() {
  # ── Language meta ────────────────────────────────────────────
  L_LANG_NAME="English"
  L_LANG_CODE="en"

  # ── Selector de idioma ───────────────────────────────────────
  L_SELECT_LANG="Select language / Selecciona idioma"
  L_LANG_ENGLISH="English"
  L_LANG_SPANISH="Español"
  L_LANG_SELECTED="Language set to"
  L_LANG_HINT="You can change it anytime from the main menu"

  # ── Splash ───────────────────────────────────────────────────
  L_SPLASH_SUBTITLE="macOS Developer Environment Forge"
  L_SPLASH_SYSTEM="System"
  L_SPLASH_USER="User"
  L_SPLASH_BREW="Brew"
  L_SPLASH_LOG="Log"
  L_SPLASH_LANG="Language"

  # ── Menú principal ────────────────────────────────────────────
  L_MENU_TITLE="SELECT INSTALLATION PROFILE"
  L_MENU_1="Full Install"
  L_MENU_1_DESC="Everything — all modules (complete setup)"
  L_MENU_2="Core + Languages"
  L_MENU_2_DESC="Homebrew, 80+ CLI tools, all languages"
  L_MENU_3="Editors & Terminal"
  L_MENU_3_DESC="VS Code, Neovim+AI, Zed, Ghostty, fonts, shell"
  L_MENU_4="DevOps & Cloud"
  L_MENU_4_DESC="Docker, Kubernetes, Terraform, AWS/GCP/Azure"
  L_MENU_5="macOS Defaults"
  L_MENU_5_DESC="System prefs, Dock, Finder, AeroSpace"
  L_MENU_6="Applications"
  L_MENU_6_DESC="Browsers, DB GUIs, design tools, fonts"
  L_MENU_7="AI Coding Agents"
  L_MENU_7_DESC="Claude Code, Gemini CLI, Aider, MCP servers"
  L_MENU_8="Dotfiles Setup"
  L_MENU_8_DESC="chezmoi, GNU stow, mackup, dotfiles structure"
  L_MENU_9="iOS / Apple Dev"
  L_MENU_9_DESC="Fastlane, XcodeGen, CocoaPods, simulators, signing"
  L_MENU_A="Android Dev"
  L_MENU_A_DESC="SDK, ADB, Gradle, Maestro, Fastlane, Play Store"
  L_MENU_M="Mobile (iOS + Android)"
  L_MENU_M_DESC="Full mobile development stack"
  L_MENU_C="Custom Selection"
  L_MENU_C_DESC="Choose individual modules to install"
  L_MENU_U="Update Everything"
  L_MENU_U_DESC="Update all installed packages and tools"
  L_MENU_T="Change Language"
  L_MENU_T_DESC="Switch between English and Español"
  L_MENU_X="System Audit"
  L_MENU_X_DESC="Scan and report what's installed and versions"
  L_MENU_0="Exit"

  # ── Módulos ───────────────────────────────────────────────────
  L_MOD_TITLE="SELECT MODULES"
  L_MOD_HINT="Enter module numbers (space-separated), or 'all'"
  L_MOD_CORE="Core Foundation  (Homebrew, 80+ CLI tools, Zsh, Git)"
  L_MOD_LANGUAGES="Programming Languages  (Node, Python, Rust, Go, Java, 20+ langs)"
  L_MOD_FRAMEWORKS="Frameworks & Libraries  (React, Django, Docker, DevOps)"
  L_MOD_EDITORS="Code Editors  (VS Code 80+ext, Neovim+AI, Zed, Cursor, Helix)"
  L_MOD_TERMINAL="Terminal & Shell  (Ghostty, Tabby, WezTerm, 17 fonts, tmux)"
  L_MOD_MACOS="macOS Defaults  (Dock, Finder, security, AeroSpace)"
  L_MOD_APPS="Applications  (browsers, DB GUIs, design tools, fonts)"
  L_MOD_AI="AI Coding Agents  (Claude Code, Gemini CLI, Aider, MCP)"
  L_MOD_IOS="iOS / Apple Dev  (Fastlane, XcodeGen, CocoaPods, signing)"
  L_MOD_ANDROID="Android Dev  (SDK, ADB, Gradle, Maestro, Play Store)"
  L_MOD_DOTFILES="Dotfiles Management  (chezmoi, stow, mackup)"

  # ── Pre-flight ────────────────────────────────────────────────
  L_PREFLIGHT="Running pre-flight checks..."
  L_CHECK_MACOS="Checking macOS version"
  L_CHECK_INTERNET="Checking internet connection"
  L_CHECK_ROOT="Checking user privileges"
  L_CHECK_DISK="Checking disk space"
  L_NO_INTERNET="No internet connection detected"
  L_IS_ROOT="Do not run as root. Run as your normal user."
  L_LOW_DISK="Low disk space"
  L_LOW_DISK_WARN="GB free. Recommend 20GB+ for full install."
  L_CONTINUE_ANYWAY="Continue anyway?"

  # ── Confirmación ──────────────────────────────────────────────
  L_READY="Ready to forge your development environment."
  L_CONTINUE="Continue with installation?"
  L_CANCELLED="Installation cancelled"
  L_SUDO_NEEDED="Administrator access required for some installations"

  # ── Estados de instalación ────────────────────────────────────
  L_INSTALLING="Installing"
  L_CONFIGURING="Configuring"
  L_UPDATING="Updating"
  L_DOWNLOADING="Downloading"
  L_SETTING_UP="Setting up"
  L_CHECKING="Checking"
  L_CLONING="Cloning"
  L_COMPILING="Compiling"
  L_ALREADY_INSTALLED="Already installed"
  L_DONE="Done"
  L_FAILED="Failed"
  L_SKIPPED="Skipped"
  L_NOT_AVAILABLE="not available"
  L_NOT_FOUND="not found"
  L_SEE_LOG="(see log)"

  # ── Summary ───────────────────────────────────────────────────
  L_SUMMARY_TITLE="INSTALLATION SUMMARY"
  L_SUMMARY_INSTALLED="Installed"
  L_SUMMARY_SKIPPED="Skipped"
  L_SUMMARY_FAILED="Failed"
  L_SUMMARY_LOG="Log file"
  L_SUMMARY_PACKAGES="packages"
  L_SUMMARY_ALREADY="already present"
  L_SUMMARY_FAILURES="Packages with errors (see log):"

  # ── Audit ─────────────────────────────────────────────────────
  L_AUDIT_TITLE="SYSTEM AUDIT"
  L_AUDIT_SYSTEM="SYSTEM INFO"
  L_AUDIT_LANGUAGES="LANGUAGES"
  L_AUDIT_EDITORS="EDITORS"
  L_AUDIT_DEVOPS="DEVOPS"
  L_AUDIT_SHELL="SHELL TOOLS"
  L_AUDIT_AI="AI TOOLS"
  L_AUDIT_IOS="iOS / APPLE DEV"
  L_AUDIT_ANDROID="ANDROID DEV"
  L_AUDIT_DOTFILES="DOTFILES"
  L_AUDIT_VERSION="Version"
  L_AUDIT_ARCH="Architecture"
  L_AUDIT_RAM="RAM"
  L_AUDIT_STORAGE="Storage"

  # ── Update ────────────────────────────────────────────────────
  L_UPDATE_TITLE="UPDATING ALL PACKAGES"
  L_UPDATE_BREW="Updating Homebrew packages"
  L_UPDATE_BREW_UPGRADE="Upgrading Homebrew packages"
  L_UPDATE_BREW_CLEAN="Cleaning Homebrew cache"
  L_UPDATE_NPM="Updating npm globals"
  L_UPDATE_PIP="Updating pip packages"
  L_UPDATE_RUST="Updating Rust toolchain"
  L_UPDATE_GO="Updating Go tools"
  L_UPDATE_GEM="Updating Ruby gems"
  L_UPDATE_DONE="All packages updated ✓"

  # ── Post-install ──────────────────────────────────────────────
  L_COMPLETE_TITLE="INSTALLATION COMPLETE"
  L_COMPLETE_MSG="Your macOS development environment is ready!"
  L_NEXT_STEPS="Next steps:"
  L_STEP_RELOAD="Restart your terminal or run"
  L_STEP_NVIM="Open nvim to trigger LazyVim plugin installation"
  L_STEP_AUDIT="Run to verify your environment"
  L_STEP_LOG="View the full log at"

  # ── Bye ───────────────────────────────────────────────────────
  L_GOODBYE="Goodbye! Happy coding! 🚀"
  L_INVALID="Invalid choice."
}

# ════════════════════════════════════════════════════════════════
#  ESPAÑOL
# ════════════════════════════════════════════════════════════════
_load_es() {
  # ── Language meta ────────────────────────────────────────────
  L_LANG_NAME="Español"
  L_LANG_CODE="es"

  # ── Selector de idioma ───────────────────────────────────────
  L_SELECT_LANG="Select language / Selecciona idioma"
  L_LANG_ENGLISH="English"
  L_LANG_SPANISH="Español"
  L_LANG_SELECTED="Idioma establecido a"
  L_LANG_HINT="Puedes cambiarlo en cualquier momento desde el menú principal"

  # ── Splash ───────────────────────────────────────────────────
  L_SPLASH_SUBTITLE="Forja de Entorno de Desarrollo macOS"
  L_SPLASH_SYSTEM="Sistema"
  L_SPLASH_USER="Usuario"
  L_SPLASH_BREW="Brew"
  L_SPLASH_LOG="Log"
  L_SPLASH_LANG="Idioma"

  # ── Menú principal ────────────────────────────────────────────
  L_MENU_TITLE="SELECCIONA EL PERFIL DE INSTALACIÓN"
  L_MENU_1="Instalación Completa"
  L_MENU_1_DESC="Todo — todos los módulos (configuración completa)"
  L_MENU_2="Core + Lenguajes"
  L_MENU_2_DESC="Homebrew, 80+ herramientas CLI, todos los lenguajes"
  L_MENU_3="Editores & Terminal"
  L_MENU_3_DESC="VS Code, Neovim+AI, Zed, Ghostty, fuentes, shell"
  L_MENU_4="DevOps & Cloud"
  L_MENU_4_DESC="Docker, Kubernetes, Terraform, AWS/GCP/Azure"
  L_MENU_5="Defaults de macOS"
  L_MENU_5_DESC="Prefs del sistema, Dock, Finder, AeroSpace"
  L_MENU_6="Aplicaciones"
  L_MENU_6_DESC="Navegadores, GUIs de BD, herramientas de diseño"
  L_MENU_7="Agentes AI"
  L_MENU_7_DESC="Claude Code, Gemini CLI, Aider, servidores MCP"
  L_MENU_8="Dotfiles"
  L_MENU_8_DESC="chezmoi, GNU stow, mackup, estructura dotfiles"
  L_MENU_9="iOS / Apple Dev"
  L_MENU_9_DESC="Fastlane, XcodeGen, CocoaPods, simuladores, firma"
  L_MENU_A="Android Dev"
  L_MENU_A_DESC="SDK, ADB, Gradle, Maestro, Fastlane, Play Store"
  L_MENU_M="Mobile (iOS + Android)"
  L_MENU_M_DESC="Stack completo de desarrollo móvil"
  L_MENU_C="Selección Personalizada"
  L_MENU_C_DESC="Elegir módulos individuales a instalar"
  L_MENU_U="Actualizar Todo"
  L_MENU_U_DESC="Actualizar todos los paquetes y herramientas"
  L_MENU_T="Cambiar Idioma"
  L_MENU_T_DESC="Cambiar entre English y Español"
  L_MENU_X="Auditoría del Sistema"
  L_MENU_X_DESC="Escanear y reportar lo instalado y versiones"
  L_MENU_0="Salir"

  # ── Módulos ───────────────────────────────────────────────────
  L_MOD_TITLE="SELECCIONAR MÓDULOS"
  L_MOD_HINT="Ingresa números de módulos (separados por espacio), o 'all'"
  L_MOD_CORE="Núcleo  (Homebrew, 80+ herramientas CLI, Zsh, Git)"
  L_MOD_LANGUAGES="Lenguajes de Programación  (Node, Python, Rust, Go, Java, 20+ lenguajes)"
  L_MOD_FRAMEWORKS="Frameworks y Bibliotecas  (React, Django, Docker, DevOps)"
  L_MOD_EDITORS="Editores de Código  (VS Code 80+ext, Neovim+AI, Zed, Cursor, Helix)"
  L_MOD_TERMINAL="Terminal y Shell  (Ghostty, Tabby, WezTerm, 17 fuentes, tmux)"
  L_MOD_MACOS="Defaults de macOS  (Dock, Finder, seguridad, AeroSpace)"
  L_MOD_APPS="Aplicaciones  (navegadores, GUIs de BD, diseño, fuentes)"
  L_MOD_AI="Agentes AI  (Claude Code, Gemini CLI, Aider, MCP)"
  L_MOD_IOS="iOS / Apple Dev  (Fastlane, XcodeGen, CocoaPods, firma)"
  L_MOD_ANDROID="Android Dev  (SDK, ADB, Gradle, Maestro, Play Store)"
  L_MOD_DOTFILES="Gestión de Dotfiles  (chezmoi, stow, mackup)"

  # ── Pre-flight ────────────────────────────────────────────────
  L_PREFLIGHT="Ejecutando verificaciones previas..."
  L_CHECK_MACOS="Verificando versión de macOS"
  L_CHECK_INTERNET="Verificando conexión a internet"
  L_CHECK_ROOT="Verificando privilegios de usuario"
  L_CHECK_DISK="Verificando espacio en disco"
  L_NO_INTERNET="No se detectó conexión a internet"
  L_IS_ROOT="No ejecutes como root. Usa tu usuario normal."
  L_LOW_DISK="Poco espacio en disco"
  L_LOW_DISK_WARN="GB libres. Se recomiendan 20GB+ para instalación completa."
  L_CONTINUE_ANYWAY="¿Continuar de todas formas?"

  # ── Confirmación ──────────────────────────────────────────────
  L_READY="Listo para forjar tu entorno de desarrollo."
  L_CONTINUE="¿Continuar con la instalación?"
  L_CANCELLED="Instalación cancelada"
  L_SUDO_NEEDED="Se requiere acceso de administrador para algunas instalaciones"

  # ── Estados de instalación ────────────────────────────────────
  L_INSTALLING="Instalando"
  L_CONFIGURING="Configurando"
  L_UPDATING="Actualizando"
  L_DOWNLOADING="Descargando"
  L_SETTING_UP="Configurando"
  L_CHECKING="Verificando"
  L_CLONING="Clonando"
  L_COMPILING="Compilando"
  L_ALREADY_INSTALLED="Ya instalado"
  L_DONE="Listo"
  L_FAILED="Falló"
  L_SKIPPED="Omitido"
  L_NOT_AVAILABLE="no disponible"
  L_NOT_FOUND="no encontrado"
  L_SEE_LOG="(ver log)"

  # ── Summary ───────────────────────────────────────────────────
  L_SUMMARY_TITLE="RESUMEN DE INSTALACIÓN"
  L_SUMMARY_INSTALLED="Instalados"
  L_SUMMARY_SKIPPED="Omitidos"
  L_SUMMARY_FAILED="Fallidos"
  L_SUMMARY_LOG="Archivo de log"
  L_SUMMARY_PACKAGES="paquetes"
  L_SUMMARY_ALREADY="ya presentes"
  L_SUMMARY_FAILURES="Paquetes con errores (ver log):"

  # ── Audit ─────────────────────────────────────────────────────
  L_AUDIT_TITLE="AUDITORÍA DEL SISTEMA"
  L_AUDIT_SYSTEM="INFO DEL SISTEMA"
  L_AUDIT_LANGUAGES="LENGUAJES"
  L_AUDIT_EDITORS="EDITORES"
  L_AUDIT_DEVOPS="DEVOPS"
  L_AUDIT_SHELL="HERRAMIENTAS SHELL"
  L_AUDIT_AI="HERRAMIENTAS AI"
  L_AUDIT_IOS="iOS / APPLE DEV"
  L_AUDIT_ANDROID="ANDROID DEV"
  L_AUDIT_DOTFILES="DOTFILES"
  L_AUDIT_VERSION="Versión"
  L_AUDIT_ARCH="Arquitectura"
  L_AUDIT_RAM="RAM"
  L_AUDIT_STORAGE="Almacenamiento"

  # ── Update ────────────────────────────────────────────────────
  L_UPDATE_TITLE="ACTUALIZANDO TODOS LOS PAQUETES"
  L_UPDATE_BREW="Actualizando Homebrew"
  L_UPDATE_BREW_UPGRADE="Actualizando paquetes Homebrew"
  L_UPDATE_BREW_CLEAN="Limpiando caché de Homebrew"
  L_UPDATE_NPM="Actualizando globales de npm"
  L_UPDATE_PIP="Actualizando paquetes pip"
  L_UPDATE_RUST="Actualizando toolchain de Rust"
  L_UPDATE_GO="Actualizando herramientas de Go"
  L_UPDATE_GEM="Actualizando gems de Ruby"
  L_UPDATE_DONE="Todos los paquetes actualizados ✓"

  # ── Post-install ──────────────────────────────────────────────
  L_COMPLETE_TITLE="INSTALACIÓN COMPLETA"
  L_COMPLETE_MSG="¡Tu entorno de desarrollo macOS está listo!"
  L_NEXT_STEPS="Próximos pasos:"
  L_STEP_RELOAD="Reinicia la terminal o ejecuta"
  L_STEP_NVIM="Abre nvim para instalar los plugins de LazyVim"
  L_STEP_AUDIT="Ejecuta para verificar tu entorno"
  L_STEP_LOG="Ver el log completo en"

  # ── Bye ───────────────────────────────────────────────────────
  L_GOODBYE="¡Hasta luego! ¡Feliz código! 🚀"
  L_INVALID="Opción no válida."
}

# ── Inicializar con el idioma guardado o el default ──────────────
lang_load_saved
lang_load
