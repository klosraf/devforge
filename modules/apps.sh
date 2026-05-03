#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────
#  Module: apps — DevForge macOS Setup v3.3
#  Apps: navegadores, DB GUIs, diseño, seguridad, utilidades
#
#  CORRECCIONES v3.3:
#  - Todos los cask con nombres verificados en 2025/2026
#  - || true en todas las instalaciones opcionales
#  - mas: solo apps gratuitas sin ID obsoleto
# ─────────────────────────────────────────────────────────────────

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

module_apps() {
  ui_section "APPLICATIONS" "◈"

  # ── Navegadores ──────────────────────────────────────────────
  ui_step "Navegadores..."
  brew_cask_install "arc"           "Arc Browser"
  brew_cask_install "firefox"       "Firefox"
  brew_cask_install "brave-browser" "Brave Browser"
  brew_cask_install "google-chrome" "Google Chrome"

  # ── API & HTTP ────────────────────────────────────────────────
  ui_step "API & HTTP tools..."
  brew_cask_install "insomnia"      "Insomnia"
  brew_cask_install "postman"       "Postman"
  brew_cask_install "proxyman"      "Proxyman"
  brew_cask_install "rapidapi"      "RapidAPI"
  brew_cask_install "charles"       "Charles Proxy"

  # ── Base de datos ─────────────────────────────────────────────
  ui_step "Database GUI clients..."
  brew_cask_install "tableplus"           "TablePlus"
  brew_cask_install "dbeaver-community"   "DBeaver Community"
  brew_cask_install "mongodb-compass"     "MongoDB Compass"
  brew_cask_install "redisinsight"        "RedisInsight"
  brew_cask_install "beekeeper-studio"    "Beekeeper Studio"

  # ── Git GUIs ─────────────────────────────────────────────────
  ui_step "Git GUI clients..."
  brew_cask_install "fork"           "Fork"
  brew_cask_install "sourcetree"     "SourceTree"
  brew_cask_install "github"         "GitHub Desktop"

  # ── Diseño ────────────────────────────────────────────────────
  ui_step "Design tools..."
  brew_cask_install "figma"          "Figma"
  brew_cask_install "imageoptim"     "ImageOptim"
  brew_cask_install "inkscape"       "Inkscape (Illustrator open-source)"

  # ── Comunicación ─────────────────────────────────────────────
  ui_step "Communication..."
  brew_cask_install "slack"          "Slack"
  brew_cask_install "discord"        "Discord"
  brew_cask_install "zoom"           "Zoom"
  brew_cask_install "telegram"       "Telegram"

  # ── Notas & conocimiento ─────────────────────────────────────
  ui_step "Notes & knowledge..."
  brew_cask_install "obsidian"       "Obsidian"
  brew_cask_install "notion"         "Notion"
  brew_cask_install "logseq"         "Logseq"

  # ── Productividad ─────────────────────────────────────────────
  ui_step "Productivity..."
  brew_cask_install "raycast"        "Raycast"
  brew_cask_install "maccy"          "Maccy (clipboard manager)"
  brew_cask_install "rectangle"      "Rectangle (window management)"

  # ── Utilidades sistema ────────────────────────────────────────
  ui_step "System utilities..."
  brew_cask_install "appcleaner"     "AppCleaner"
  brew_cask_install "the-unarchiver" "The Unarchiver"
  brew_cask_install "stats"          "Stats (menu bar)"
  brew_cask_install "coconutbattery" "CoconutBattery"

  # ── Monitoreo & performance ───────────────────────────────────
  ui_step "Performance monitoring..."
  # iStat Menus es una app de pago — intentar cask, fallback a URL de descarga
  # (stats ya está instalado como alternativa gratuita)
  if ! brew list --cask istatmenus &>/dev/null 2>&1; then
    if brew install --cask istatmenus --no-quarantine >> "${LOG_FILE}" 2>&1; then
      track_ok "iStat Menus"
    else
      track_skip "iStat Menus (app de pago — descarga en: bjango.com/mac/istatmenus)"
      ui_info "  → iStat Menus: https://bjango.com/mac/istatmenus/ (alternativa gratuita: stats ✓ ya instalado)"
    fi
  else
    track_skip "iStat Menus (ya instalado)"
  fi

  # ── Contenedores ─────────────────────────────────────────────
  ui_step "Containers & VMs..."
  brew_cask_install "orbstack"       "OrbStack (Docker + VMs)"
  brew_cask_install "utm"            "UTM (máquinas virtuales)"

  # ── Seguridad — Objective-See suite ──────────────────────────
  ui_step "Security apps (Objective-See)..."
  brew_cask_install "lulu"           "LuLu (firewall open-source)"
  brew_cask_install "oversight"      "OverSight (webcam/mic monitor)"
  brew_cask_install "blockblock"     "BlockBlock (persistencia)"
  brew_cask_install "knockknock"     "KnockKnock (scanner)"

  # Password managers
  brew_cask_install "bitwarden"      "Bitwarden (password manager)"
  brew_cask_install "1password"      "1Password"

  # ── Media & Creatividad ───────────────────────────────────────
  ui_step "Media..."
  brew_cask_install "vlc"            "VLC"
  brew_cask_install "obs"            "OBS Studio"
  brew_cask_install "iina"           "IINA (media player)"
  brew_cask_install "handbrake"      "HandBrake"

  # ── Dev UX ────────────────────────────────────────────────────
  ui_step "Dev UX utilities..."
  brew_cask_install "keycastr"       "KeyCastr (mostrar pulsaciones)"

  # ── QuickLook plugins ─────────────────────────────────────────
  ui_step "QuickLook plugins..."
  brew_cask_install "qlcolorcode"         "QL Color Code"
  brew_cask_install "qlstephen"           "QL Stephen"
  brew_cask_install "qlmarkdown"          "QL Markdown"
  # quicklook-json — deprecado (deshabilitado en Homebrew, usar extensión nativa macOS Sonoma+)
  brew_cask_install "quicklook-csv"       "QL CSV"
  brew_cask_install "syntax-highlight"    "QL Syntax Highlight"
  brew_cask_install "suspicious-package"  "Suspicious Package"
  brew_cask_install "apparency"           "Apparency"
  # qlimagesize — no disponible en Homebrew (alternativa: extensión nativa macOS)

  # ── Fuentes (verificadas en homebrew-cask) ────────────────────
  ui_step "Nerd Fonts (verificadas)..."
  local fonts=(
    "font-jetbrains-mono-nerd-font"
    "font-fira-code-nerd-font"
    "font-cascadia-code-nerd-font"
    "font-geist-mono-nerd-font"
    "font-monaspace-nerd-font"
    "font-victor-mono-nerd-font"
    "font-iosevka-nerd-font"
    "font-symbols-only-nerd-font"
    "font-commit-mono-nerd-font"
    "font-hack-nerd-font"
    "font-source-code-pro-nerd-font"
    "font-inter"
    "font-recursive"
    "font-maple-mono-nerd-font"
  )
  for font in "${fonts[@]}"; do
    brew install --cask "${font}" >> "${LOG_FILE}" 2>&1 || true
  done
  track_ok "Fuentes instaladas"

  # ── Mac App Store ─────────────────────────────────────────────
  ui_step "Mac App Store apps..."
  if has_cmd mas; then
    # IDs verificados y activos en 2025/2026
    local mas_apps=(
      "497799835:Xcode"
      "1451685025:WireGuard"
      "937984704:Amphetamine"
      "409201541:Pages"
      "409203825:Numbers"
      "409183694:Keynote"
      "1518425043:Boop (text tool)"
      "1507890049:Creativit Mind Map"
    )
    for entry in "${mas_apps[@]}"; do
      local app_id="${entry%%:*}"
      local app_name="${entry##*:}"
      mas install "${app_id}" >> "${LOG_FILE}" 2>&1 && \
        track_ok "${app_name}" || track_fail "${app_name}"
    done
  else
    track_skip "mas (Mac App Store CLI no disponible)"
    ui_info "Instala mas con: brew install mas"
  fi

  ui_success "Aplicaciones instaladas ✓"
}
