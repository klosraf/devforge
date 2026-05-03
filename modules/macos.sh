#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────
#  Module: macos — DevForge macOS Setup v3.3
#  Defaults del sistema macOS, Dock, Finder, AeroSpace
#
#  CORRECCIONES v3.3:
#  - defaults: todos con || true — algunos defaults cambian entre versiones
#  - AeroSpace: tap corregido (nikitabobko/tap)
#  - dockutil: verificar disponibilidad antes de usar
#  - Separar defaults críticos de los opcionales
# ─────────────────────────────────────────────────────────────────

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

# Helper: set defaults sin abortar si falla
_set_default() {
  defaults write "$@" 2>/dev/null || true
}

module_macos() {
  ui_section "macOS SYSTEM DEFAULTS" "◈"
  detect_system

  # ── Cerrar System Preferences para evitar conflictos ─────────
  osascript -e 'quit app "System Preferences"' 2>/dev/null || true
  osascript -e 'quit app "System Settings"'    2>/dev/null || true

  # ── Apariencia ───────────────────────────────────────────────
  ui_step "Apariencia..."
  _set_default NSGlobalDomain AppleInterfaceStyle Dark
  _set_default NSGlobalDomain AppleAccentColor -int 4          # Azul
  _set_default NSGlobalDomain AppleHighlightColor "0.698039 0.843137 1.000000 Blue"
  _set_default NSGlobalDomain AppleShowScrollBars WhenScrolling
  _set_default NSGlobalDomain NSWindowResizeTime -float 0.001
  _set_default NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
  _set_default NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
  _set_default NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
  _set_default NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
  track_ok "Apariencia"

  # ── Teclado ───────────────────────────────────────────────────
  ui_step "Teclado..."
  _set_default NSGlobalDomain KeyRepeat -int 2
  _set_default NSGlobalDomain InitialKeyRepeat -int 15
  _set_default NSGlobalDomain ApplePressAndHoldEnabled -bool false
  _set_default NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
  _set_default NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
  _set_default NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
  _set_default NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
  _set_default NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
  _set_default NSGlobalDomain AppleKeyboardUIMode -int 3       # Tab en todos los controles
  track_ok "Teclado"

  # ── Trackpad ──────────────────────────────────────────────────
  ui_step "Trackpad..."
  _set_default com.apple.AppleMultitouchTrackpad Clicking -bool true
  _set_default com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  _set_default NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  _set_default com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
  _set_default com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true
  track_ok "Trackpad"

  # ── Dock ──────────────────────────────────────────────────────
  ui_step "Dock..."
  _set_default com.apple.dock tilesize -int 48
  _set_default com.apple.dock magnification -bool true
  _set_default com.apple.dock largesize -int 72
  _set_default com.apple.dock autohide -bool true
  _set_default com.apple.dock autohide-delay -float 0.0
  _set_default com.apple.dock autohide-time-modifier -float 0.25
  _set_default com.apple.dock show-recents -bool false
  _set_default com.apple.dock launchanim -bool false
  _set_default com.apple.dock mineffect -string scale
  _set_default com.apple.dock minimize-to-application -bool true
  _set_default com.apple.dock show-process-indicators -bool true
  _set_default com.apple.dock static-only -bool false
  _set_default com.apple.dock mru-spaces -bool false           # No reordenar spaces

  # Eliminar todos los iconos del Dock y limpiar (fresh start)
  if has_cmd dockutil; then
    ui_info "Limpiando Dock con dockutil..."
    dockutil --remove all --no-restart 2>/dev/null || true

    # ── Apps predefinidas para el Dock (orden exacto) ────────────────
    local -a dock_apps=(
      # "Apps" se añade como carpeta antes del bucle principal
      "/System/Applications/System Settings.app"      # macOS Ventura+
      "/System/Applications/System Preferences.app"   # macOS Monterey y anterior
      "/System/Applications/App Store.app"
      "/Applications/Brackets.app"
      "/Applications/Atom Beta.app"
      "/Applications/Zed.app"
      "/Applications/Visual Studio Code.app"
      "/Applications/Android Studio.app"
      "/Applications/Xcode.app"
      "/Applications/Sourcetree.app"
      "/Applications/Fork.app"
      "/Applications/Figma.app"
      "/Applications/OpenClaw.app"
      "/Applications/OpenCode.app"
      "/Applications/Claude.app"
      "/Applications/Tabby.app"
      "/Applications/Safari.app"
      "/Applications/Aloha Browser.app"
      "/Applications/IINA.app"
      "/Applications/Discord.app"
      "/Applications/Telegram.app"
      "/Applications/Slack.app"
    )

    # Añadir al Dock en orden exacto
    # 1. Carpeta /Applications como stack (posición 1 — "Apps")
    dockutil --add "/Applications" --view grid --display folder --no-restart 2>/dev/null || true

    # 2. Resto de apps en el orden definido (se salta las que no existen)
    local _app
    for _app in "${dock_apps[@]}"; do
      [[ -d "${_app}" ]] && dockutil --add "${_app}" --no-restart 2>/dev/null || true
    done

    # Carpeta Downloads siempre al final
    dockutil --add "${HOME}/Downloads" --view fan --display stack --no-restart 2>/dev/null || true

    killall Dock 2>/dev/null || true
    track_ok "Dock configurado con dockutil (${#dock_apps[@]} apps)"
  else
    killall Dock 2>/dev/null || true
    track_ok "Dock configurado (sin dockutil para apps)"
  fi

  # ── Finder ────────────────────────────────────────────────────
  ui_step "Finder..."
  _set_default com.apple.finder AppleShowAllFiles -bool true
  _set_default com.apple.finder ShowPathbar -bool true
  _set_default com.apple.finder ShowStatusBar -bool true
  _set_default com.apple.finder _FXShowPosixPathInTitle -bool true
  _set_default com.apple.finder _FXSortFoldersFirst -bool true
  _set_default com.apple.finder FXDefaultSearchScope SCcf         # buscar en carpeta actual
  _set_default com.apple.finder FXPreferredViewStyle Nlsv          # list view
  _set_default com.apple.finder FXEnableExtensionChangeWarning -bool false
  _set_default com.apple.finder ShowHardDrivesOnDesktop -bool false
  _set_default com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
  _set_default com.apple.finder ShowRemovableMediaOnDesktop -bool true
  _set_default com.apple.finder QLEnableTextSelection -bool true
  _set_default NSGlobalDomain com.apple.springing.enabled -bool true
  _set_default NSGlobalDomain com.apple.springing.delay -float 0
  # Evitar crear .DS_Store en volumes de red y USB
  _set_default com.apple.desktopservices DSDontWriteNetworkStores -bool true
  _set_default com.apple.desktopservices DSDontWriteUSBStores -bool true

  killall Finder 2>/dev/null || true
  track_ok "Finder"

  # ── Capturas de pantalla ──────────────────────────────────────
  ui_step "Capturas de pantalla..."
  mkdir -p "${HOME}/Desktop/Screenshots" 2>/dev/null || true
  _set_default com.apple.screencapture location "${HOME}/Desktop/Screenshots"
  _set_default com.apple.screencapture type png
  _set_default com.apple.screencapture disable-shadow -bool true
  _set_default com.apple.screencapture show-thumbnail -bool true
  track_ok "Screenshots → ~/Desktop/Screenshots"

  # ── Energía ───────────────────────────────────────────────────
  ui_step "Energía..."
  sudo pmset -a displaysleep 30 2>/dev/null || true
  sudo pmset -c sleep 0       2>/dev/null || true  # No dormir con cargador
  sudo pmset -b sleep 20      2>/dev/null || true  # 20 min en batería
  sudo pmset -a standby 0     2>/dev/null || true
  sudo pmset -a hibernatemode 0 2>/dev/null || true
  track_ok "Energía"

  # ── Seguridad ─────────────────────────────────────────────────
  ui_step "Seguridad..."
  # Quarantine: mostrar advertencia para apps de internet (seguridad)
  # No desactivamos Gatekeeper — es una protección importante
  _set_default com.apple.screensaver askForPassword -int 1
  _set_default com.apple.screensaver askForPasswordDelay -int 0
  track_ok "Seguridad"

  # ── Sonido ────────────────────────────────────────────────────
  _set_default NSGlobalDomain com.apple.sound.beep.feedback -int 0
  _set_default NSGlobalDomain com.apple.sound.uiaudio.enabled -int 0

  # ── Mission Control ───────────────────────────────────────────
  ui_step "Mission Control..."
  _set_default com.apple.dock expose-animation-duration -float 0.1
  _set_default com.apple.dock expose-group-by-app -bool false
  _set_default com.apple.dock wvous-tl-corner -int 0   # Esquina arriba izquierda
  _set_default com.apple.dock wvous-tr-corner -int 0
  _set_default com.apple.dock wvous-bl-corner -int 0
  _set_default com.apple.dock wvous-br-corner -int 0
  track_ok "Mission Control"

  # ── Menu bar ──────────────────────────────────────────────────
  ui_step "Menu bar..."
  _set_default NSGlobalDomain _HIHideMenuBar -bool false
  _set_default com.apple.menuextra.clock IsAnalog -bool false
  _set_default com.apple.menuextra.clock DateFormat "EEE d MMM  HH:mm"
  _set_default com.apple.menuextra.battery ShowPercent -string YES
  track_ok "Menu bar"

  # ── Activity Monitor ──────────────────────────────────────────
  _set_default com.apple.ActivityMonitor OpenMainWindow -bool true
  _set_default com.apple.ActivityMonitor IconType -int 5         # CPU usage en icono
  _set_default com.apple.ActivityMonitor ShowCategory -int 0     # Todos los procesos
  _set_default com.apple.ActivityMonitor SortColumn -string CPUUsage
  _set_default com.apple.ActivityMonitor SortDirection -int 0

  # ── TextEdit ──────────────────────────────────────────────────
  _set_default com.apple.TextEdit RichText -int 0               # Texto plano por defecto
  _set_default com.apple.TextEdit PlainTextEncoding -int 4       # UTF-8
  _set_default com.apple.TextEdit PlainTextEncodingForWrite -int 4

  # ── Crash Reporter ────────────────────────────────────────────
  _set_default com.apple.CrashReporter DialogType -string none

  # ── AeroSpace (window manager tipo i3) ───────────────────────
  ui_step "AeroSpace (window manager)..."
  brew tap "nikitabobko/tap" >> "${LOG_FILE}" 2>&1 || true
  brew_cask_install "aerospace" "AeroSpace"
  ensure_dir "${HOME}/.config/aerospace"
  _write_aerospace_config

  # ── Raycast ───────────────────────────────────────────────────
  ui_step "Raycast (launcher)..."
  brew_cask_install "raycast" "Raycast"

  # ── Rectangle ─────────────────────────────────────────────────
  ui_step "Rectangle (window snapping)..."
  brew_cask_install "rectangle" "Rectangle"
  _set_default com.knollsoft.Rectangle launchOnLogin -bool true

  # ── Aplicar todos los cambios ─────────────────────────────────
  ui_step "Aplicando cambios..."
  # Reiniciar procesos afectados
  for app in "Finder" "Dock" "SystemUIServer" "cfprefsd"; do
    killall "${app}" 2>/dev/null || true
  done
  sleep 1

  ui_success "macOS configurado ✓"
  ui_info "Algunos cambios requieren reiniciar el sistema para aplicarse completamente"
}

# ════════════════════════════════════════════════════════════════
#  AEROSPACE CONFIG
# ════════════════════════════════════════════════════════════════
_write_aerospace_config() {
  cat > "${HOME}/.config/aerospace/aerospace.toml" << 'AEROSPACE'
# DevForge — AeroSpace Config (estilo i3/yabai)
start-at-login = true
enable-normalization-flatten-containers = true
enable-normalization-opposite-orientation-for-nested-containers = true

[gaps]
inner.horizontal = 8
inner.vertical   = 8
outer.left       = 8
outer.right      = 8
outer.top        = 8
outer.bottom     = 8

[mode.main.binding]
# Foco (vim-style)
alt-h = 'focus left'
alt-j = 'focus down'
alt-k = 'focus up'
alt-l = 'focus right'

# Mover ventanas
alt-shift-h = 'move left'
alt-shift-j = 'move down'
alt-shift-k = 'move up'
alt-shift-l = 'move right'

# Redimensionar
alt-ctrl-h = ['resize width -50']
alt-ctrl-l = ['resize width +50']
alt-ctrl-j = ['resize height +50']
alt-ctrl-k = ['resize height -50']

# Layouts
alt-slash     = 'layout tiles horizontal vertical'
alt-comma     = 'layout accordion horizontal vertical'
alt-f         = 'fullscreen'
alt-shift-f   = 'layout floating tiling'

# Workspaces 1-9
alt-1 = 'workspace 1'
alt-2 = 'workspace 2'
alt-3 = 'workspace 3'
alt-4 = 'workspace 4'
alt-5 = 'workspace 5'
alt-6 = 'workspace 6'
alt-7 = 'workspace 7'
alt-8 = 'workspace 8'
alt-9 = 'workspace 9'

# Mover a workspace
alt-shift-1 = 'move-node-to-workspace 1'
alt-shift-2 = 'move-node-to-workspace 2'
alt-shift-3 = 'move-node-to-workspace 3'
alt-shift-4 = 'move-node-to-workspace 4'
alt-shift-5 = 'move-node-to-workspace 5'
alt-shift-6 = 'move-node-to-workspace 6'
alt-shift-7 = 'move-node-to-workspace 7'
alt-shift-8 = 'move-node-to-workspace 8'
alt-shift-9 = 'move-node-to-workspace 9'

# Misc
alt-shift-c = 'reload-config'
alt-shift-e = 'exec-and-forget open -a Finder'
AEROSPACE
  track_ok "AeroSpace configurado"
}
