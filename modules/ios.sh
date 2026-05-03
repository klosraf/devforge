#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────
#  Module: ios — DevForge macOS Setup v3.4
#  iOS / Apple Platform Development
#
#  Cubre TODO el ciclo de vida de desarrollo iOS/macOS/tvOS/watchOS:
#  ─ Xcode & herramientas del sistema
#  ─ Gestores de dependencias (CocoaPods, Carthage, Mint, SPM)
#  ─ Generadores de proyectos (XcodeGen, Tuist)
#  ─ Linting, formatting y análisis de código Swift
#  ─ Build, automatización y CI/CD (Fastlane, Bitrise)
#  ─ Firma de código y distribución (Match, Notarización)
#  ─ Comunicación con dispositivos físicos
#  ─ Testing (Maestro UI, Bluepill, Slather coverage)
#  ─ Debugging y profiling
#  ─ App Store & TestFlight
#  ─ Servicios backend (Firebase, Sentry, AppCenter)
# ─────────────────────────────────────────────────────────────────

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

module_ios() {
  ui_section "iOS / APPLE PLATFORM DEVELOPMENT" "◈"
  detect_system

  # ── Verificar que estamos en macOS ───────────────────────────
  require_macos

  # ── 1. Xcode completo (requerido para todo lo demás) ─────────
  ui_step "Xcode (IDE completo — necesario para simuladores y firmar apps)..."
  if [[ ! -d "/Applications/Xcode.app" ]]; then
    if has_cmd mas; then
      ui_info "Instalando Xcode desde App Store (puede tardar 30-60 min)..."
      mas install 497799835 >> "${LOG_FILE}" 2>&1 && \
        track_ok "Xcode" || \
        track_fail "Xcode — instala manualmente desde https://developer.apple.com/xcode/"
    else
      brew_install "mas" "mas (Mac App Store CLI)"
      mas install 497799835 >> "${LOG_FILE}" 2>&1 && \
        track_ok "Xcode" || \
        track_fail "Xcode — instala manualmente desde https://developer.apple.com/xcode/"
    fi
  else
    track_skip "Xcode (ya instalado)"
  fi

  # Aceptar licencia de Xcode (necesario para builds)
  if [[ -d "/Applications/Xcode.app" ]]; then
    sudo xcodebuild -license accept >> "${LOG_FILE}" 2>&1 || true
    # Seleccionar Xcode como herramienta de desarrollo activa
    sudo xcode-select -s /Applications/Xcode.app/Contents/Developer 2>/dev/null || true
    track_ok "Xcode license aceptada"

    # Instalar componentes adicionales de Xcode (simuladores, etc.)
    ui_step "Componentes de Xcode (simuladores)..."
    xcodebuild -runFirstLaunch >> "${LOG_FILE}" 2>&1 || true
    track_ok "Xcode primera ejecución"
  fi

  # ── 2. Swift toolchain & herramientas del sistema ─────────────
  ui_step "Swift toolchain tools..."
  brew_install "swiftlint"      "SwiftLint (linter oficial de Swift)"
  brew_install "swiftformat"    "SwiftFormat (formatter de código Swift)"
  brew_install "swiftgen"       "SwiftGen (generador de código para assets)"
  brew_install "sourcery"       "Sourcery (meta-programación en Swift)"

  # swift-format (herramienta oficial de Apple)
  brew_install "swift-format"   "swift-format (formatter oficial de Apple)" || true

  # SourceKit-LSP — ya viene integrado en Xcode 11.4+, no requiere brew

  # Periphery: encontrar código Swift no utilizado
  brew tap "peripheryapp/periphery" >> "${LOG_FILE}" 2>&1 || true
  brew_install "peripheryapp/periphery/periphery" "Periphery (dead code scanner)"

  # Needle: inyección de dependencias para Swift
  brew_install "needle"         "Needle (DI para Swift)" || true

  # ── 3. Gestores de dependencias ───────────────────────────────
  ui_step "Dependency managers (CocoaPods, Carthage, Mint, SPM)..."

  # CocoaPods — el más usado (aunque SPM lo está reemplazando)
  brew_install "cocoapods"      "CocoaPods"
  # Alternativa: gem install (si brew falla)
  if ! has_cmd pod; then
    if has_cmd gem; then
      gem install cocoapods --no-document >> "${LOG_FILE}" 2>&1 && \
        track_ok "CocoaPods (via gem)" || track_fail "CocoaPods"
    fi
  fi

  # Carthage — dependency manager descentralizado
  brew_install "carthage"       "Carthage"

  # Mint — manager de herramientas Swift instaladas via SPM
  brew_install "mint"           "Mint (SPM tool manager)"

  # Rome — obsoleto (deprecated en favor de altre herramientas Carthage)

  # ── 4. Generadores y gestores de proyectos Xcode ─────────────
  ui_step "Project generators (XcodeGen, Tuist)..."

  # XcodeGen — generar .xcodeproj desde YAML
  brew_install "xcodegen"       "XcodeGen"

  # Tuist — gestión moderna de proyectos Xcode a escala
  brew tap "tuist/tuist" >> "${LOG_FILE}" 2>&1 || true
  brew_install "tuist/tuist/tuist" "Tuist"

  # xcodeproj — librería Ruby para modificar proyectos Xcode
  if has_cmd gem; then
    gem install xcodeproj --no-document >> "${LOG_FILE}" 2>&1 && \
      track_ok "xcodeproj gem" || true
  fi

  # ── 5. Build tools y formateo de output ───────────────────────
  ui_step "Build tools (xcbeautify, xcpretty, xclogparser)..."

  # xcbeautify — formatear output de xcodebuild (más moderno)
  brew_install "xcbeautify"     "xcbeautify (pretty xcodebuild output)"

  # xcpretty — alternativa clásica via gem
  if has_cmd gem; then
    gem install xcpretty    --no-document >> "${LOG_FILE}" 2>&1 && \
      track_ok "xcpretty (gem)" || true
    gem install xcpretty-travis-formatter --no-document >> "${LOG_FILE}" 2>&1 || true
  fi

  # xclogparser — analizar logs de build de Xcode
  brew_install "xclogparser"    "XCLogParser (análisis de build logs)" || true

  # xchammer — Bazel para proyectos Xcode (empresas grandes)
  # brew_install "xchammer" "XCHammer" || true  # Solo si usas Bazel

  # ── 6. FASTLANE — automatización completa ────────────────────
  ui_step "Fastlane (automatización iOS/macOS)..."

  # Instalar via brew (más estable que gem en macOS moderno)
  brew_install "fastlane"       "Fastlane"

  if has_cmd fastlane; then
    track_ok "Fastlane instalado"
    ui_info "Fastlane actions disponibles:"
    ui_info "  scan    — ejecutar tests"
    ui_info "  gym     — compilar .ipa"
    ui_info "  deliver — subir al App Store"
    ui_info "  pilot   — gestionar TestFlight"
    ui_info "  match   — gestión de certificados y perfiles"
    ui_info "  snapshot — capturas automáticas"
    ui_info "  sigh    — descargar provisioning profiles"
    ui_info "  produce — crear App IDs en App Store Connect"
  fi

  # ── 7. Firma de código y certificados ─────────────────────────
  ui_step "Code signing tools..."

  # ios-signer-service y herramientas de firma
  # La firma se gestiona principalmente con Fastlane Match
  # pero estas herramientas complementan el proceso:

  # Codesign utilities (ya en macOS, reforzar con esto)
  if has_cmd gem; then
    gem install sigh --no-document >> "${LOG_FILE}" 2>&1 || true  # provisioning profiles
    gem install cert --no-document >> "${LOG_FILE}" 2>&1 || true  # certificados
    gem install pem  --no-document >> "${LOG_FILE}" 2>&1 || true  # push certs
    track_ok "Fastlane code signing gems (sigh, cert, pem)"
  fi

  # Keychain utilities
  brew_install "oath-toolkit"   "oath-toolkit (OTP para 2FA)" || true

  # ── 8. Comunicación con dispositivos físicos ──────────────────
  ui_step "Device communication tools..."

  # libimobiledevice — librería para comunicarse con iOS devices via USB
  brew_install "libimobiledevice"    "libimobiledevice (comunicación USB con iOS)"
  brew_install "ideviceinstaller"    "ideviceinstaller (instalar .ipa en dispositivo)"
  brew_install "libplist"            "libplist (leer plists de iOS)"
  brew_install "libusbmuxd"          "libusbmuxd (multiplexer USB-TCP)"
  # ifuse — no disponible en Homebrew (alternativa: Finder via Finder Sync Extensions o usbmuxd)

  # ios-deploy — desplegar apps en dispositivos sin Xcode GUI
  brew_install "ios-deploy"          "ios-deploy (deploy en dispositivo real)"

  # ios-sim — controlar simuladores desde CLI
  brew_install "ios-sim"             "ios-sim (control de simuladores)" || true

  # idb — Facebook's iOS Development Bridge
  brew tap "facebook/fb" >> "${LOG_FILE}" 2>&1 || true
  brew_install "facebook/fb/idb-companion" "idb-companion (Facebook IDB)" || true
  pip3 install --break-system-packages fb-idb >> "${LOG_FILE}" 2>&1 || true

  # Apple Configurator CLI
  if [[ -d "/Applications/Apple Configurator 2.app" ]]; then
    # cfgutil está dentro de Apple Configurator
    local cfgutil_path="/Applications/Apple Configurator 2.app/Contents/MacOS"
    if [[ -f "${cfgutil_path}/cfgutil" ]]; then
      sudo ln -sf "${cfgutil_path}/cfgutil" /usr/local/bin/cfgutil 2>/dev/null || true
      track_ok "cfgutil (Apple Configurator)"
    fi
  fi

  # ── 9. Simuladores ────────────────────────────────────────────
  ui_step "Simulator tools..."

  # simctl — ya viene con Xcode, pero documentamos sus usos clave
  if has_cmd xcrun; then
    ui_info "simctl disponible: xcrun simctl list devices"
    ui_info "Comandos útiles:"
    ui_info "  xcrun simctl list devices available"
    ui_info "  xcrun simctl boot <UUID>"
    ui_info "  xcrun simctl install booted <app.app>"
    ui_info "  xcrun simctl launch booted <bundle-id>"
    ui_info "  xcrun simctl screenshot booted screenshot.png"
    ui_info "  xcrun simctl video record booted recording.mov"
    track_ok "simctl (xcrun simctl)"
  fi

  # ControlRoom — no disponible en Homebrew (alternativa: simctl via Xcode)

  # RocketSim — no disponible en Homebrew (alternativa: Xcode Simulator)

  # ── 10. Testing ───────────────────────────────────────────────
  ui_step "Testing tools (Maestro, Bluepill, Slather)..."

  # Maestro — framework de UI testing moderno (mobile-first)
  if ! has_cmd maestro; then
    ui_info "Instalando Maestro (UI testing framework)..."
    # Bug previo: redirigir el curl a LOG_FILE antes del pipe a bash dejaba
    # el pipe vacío. Solo redirigimos stderr y mandamos el script al pipe.
    if curl -fsSL "https://get.maestro.mobile.dev" 2>>"${LOG_FILE}" \
         | bash >> "${LOG_FILE}" 2>&1; then
      track_ok "Maestro"
    else
      track_fail "Maestro (ver: maestro.mobile.dev)"
    fi
  else
    track_skip "Maestro (ya instalado)"
  fi

  # Bluepill — ejecutar tests de XCTest en paralelo (LinkedIn)
  brew_install "bluepill"            "Bluepill (parallel XCTest runner)" || true

  # Slather — reportes de code coverage
  if has_cmd gem; then
    gem install slather --no-document >> "${LOG_FILE}" 2>&1 && \
      track_ok "Slather (coverage reports)" || true
  fi

  # XCTestHTMLReport — reportes HTML de resultados de test
  brew tap "XCTestHTMLReport/XCTestHTMLReport" >> "${LOG_FILE}" 2>&1 || true
  brew_install "xchtmlreport"        "XCTestHTMLReport" || true

  # Cuckoo — mocking framework para Swift (via SPM, documentar)
  ui_info "Swift testing frameworks (instalar via SPM en tu proyecto):"
  ui_info "  Quick/Nimble — BDD testing"
  ui_info "  Cuckoo — mocking"
  ui_info "  OHHTTPStubs — HTTP stubbing"
  ui_info "  SnapshotTesting (pointfreeco) — snapshot tests"

  # Detox — E2E testing para React Native iOS
  npm_global_install "detox-cli"     "Detox CLI (React Native E2E)"

  # ── 11. Debugging y profiling ─────────────────────────────────
  ui_step "Debugging & profiling tools..."

  # Proxyman — interceptar tráfico HTTP/HTTPS (ya en apps.sh)
  # Charles — proxy (ya en apps.sh)

  # Reveal — inspeccionar UI de apps iOS en runtime
  brew_cask_install "reveal"         "Reveal (UI inspector)" || true

  # FLEX — in-app debugging (via SPM, documentar)
  ui_info "FLEX (Flipboard Explorer) — añade via SPM para debugging en-app"

  # Flipper — debugging para React Native
  brew_cask_install "flipper"        "Flipper (RN debugging)" || true

  # Wireshark — análisis de red a bajo nivel
  brew_cask_install "wireshark"      "Wireshark" || true

  # xctrace — grabar trazas de Instruments desde CLI
  if has_cmd xctrace; then
    track_ok "xctrace (grabar trazas Instruments)"
    ui_info "xctrace record --template 'Time Profiler' --output trace.xctrace"
  fi

  # Instruments templates (ya en Xcode)
  ui_info "Instruments templates disponibles con Xcode:"
  ui_info "  Time Profiler, Allocations, Leaks, Network, Energy Log"

  # ── 12. CI/CD ────────────────────────────────────────────────
  ui_step "CI/CD (Bitrise, GitHub Actions, Xcode Cloud)..."

  # Bitrise CLI — ejecutar pipelines Bitrise localmente
  brew_install "bitrise"             "Bitrise CLI"

  # AppCenter CLI — Microsoft App Center (distribución y analytics)
  npm_global_install "appcenter-cli" "AppCenter CLI"

  # GitHub Actions (ya tenemos 'act' en frameworks)
  # Xcode Cloud — nativo en Xcode, no requiere CLI

  # Danger — code review automation
  if has_cmd gem; then
    gem install danger --no-document >> "${LOG_FILE}" 2>&1 && \
      track_ok "Danger (PR automation)" || true
    gem install danger-swiftlint --no-document >> "${LOG_FILE}" 2>&1 || true
  fi

  # ── 13. App Store & TestFlight ────────────────────────────────
  ui_step "App Store Connect & TestFlight tools..."

  # Transporter — subir builds al App Store (App Store)
  if has_cmd mas; then
    mas install 1450874784 >> "${LOG_FILE}" 2>&1 && \
      track_ok "Transporter (App Store)" || true
  fi

  # AltTool (ya en Xcode): xcrun altool (legacy)
  # NotaryTool (ya en Xcode): xcrun notarytool (moderno)
  ui_info "Herramientas de notarización (incluidas en Xcode):"
  ui_info "  xcrun notarytool submit app.pkg --apple-id ... --team-id ..."
  ui_info "  xcrun notarytool history --apple-id ..."

  # App Store Connect API — generar claves
  ui_info "App Store Connect API key: descarga desde appstoreconnect.apple.com"
  ui_info "  Authkey_XXXXXXXX.p8 → guarda en ~/.private_keys/"
  ensure_dir "${HOME}/.private_keys"
  track_ok "~/.private_keys/ creado para API keys"

  # ── 14. Firebase & servicios backend ─────────────────────────
  ui_step "Firebase & backend services..."

  # Firebase CLI — deploy, emuladores, funciones
  npm_global_install "firebase-tools" "Firebase CLI"

  # Google Cloud SDK (para Firebase backend)
  # Ya instalado en frameworks.sh (google-cloud-sdk)

  # ── 15. Error tracking & analytics ───────────────────────────
  ui_step "Error tracking & crash reporting..."

  # Sentry CLI — upload dSYMs, source maps
  brew_install "sentry-cli"          "Sentry CLI"

  # Datadog CI — upload dSYMs a Datadog
  npm_global_install "@datadog/datadog-ci" "Datadog CI CLI"

  # ── 16. App size & performance analysis ──────────────────────
  ui_step "App size & performance analysis..."

  # Emerge Tools CLI — herramienta de pago para análisis de tamaño de binarios iOS/Android
  # @emerge-tools/emerge-cli no existe en npm (404) y no hay cask público.
  # Instalación manual: https://docs.emergetools.com/docs/cli-setup (requiere cuenta)
  track_skip "Emerge CLI (instalación manual — ver docs.emergetools.com)"

  # bloaty — analizar qué contribuye al tamaño del binario
  brew_install "bloaty"              "Bloaty (binary size profiler)" || true

  # ── 17. Generación de assets y recursos ──────────────────────
  ui_step "Asset generation tools..."

  # ImageMagick (ya en core) — redimensionar iconos
  # Sketch CLI — no disponible en Homebrew (alternativa: npm install -g sketch-cli)

  # Lottie — animaciones (via SPM en el proyecto)
  ui_info "Lottie — añade via SPM: github.com/airbnb/lottie-ios"

  # R.swift — acceder a recursos de forma type-safe (via SPM/Mint)
  if has_cmd mint; then
    mint install nicklockwood/SwiftFormat >> "${LOG_FILE}" 2>&1 || true
    mint install mac-cain13/R.swift       >> "${LOG_FILE}" 2>&1 || true
    track_ok "R.swift via Mint"
  fi

  # ── 18. Localización ─────────────────────────────────────────
  ui_step "Localization tools..."

  # BartyCrouch — mantener archivos de localización sincronizados
  brew_install "bartycrouch"         "BartyCrouch (localización)"
  # Fallback a Mint si brew no lo tiene (brew_install siempre devuelve 0)
  if ! has_cmd bartycrouch 2>/dev/null && has_cmd mint; then
    mint install Flinesoft/BartyCrouch >> "${LOG_FILE}" 2>&1 || true
    track_ok "BartyCrouch via Mint"
  fi

  # L10nLint — no disponible en Homebrew

  # ── 19. Documentación ─────────────────────────────────────────
  ui_step "Documentation tools..."

  # Jazzy — generar documentación desde Swift/ObjC
  if has_cmd gem; then
    gem install jazzy --no-document >> "${LOG_FILE}" 2>&1 && \
      track_ok "Jazzy (Swift docs)" || true
  fi

  # DocC (integrado en Xcode desde Xcode 13)
  ui_info "DocC integrado en Xcode — Product > Build Documentation"

  # ── 20. Configuración del entorno de desarrollo ───────────────
  ui_step "Configurando entorno de desarrollo iOS..."

  # Crear estructura de directorios para proyectos iOS
  ensure_dir "${HOME}/Developer/iOS"
  ensure_dir "${HOME}/Developer/macOS"
  ensure_dir "${HOME}/.private_keys"           # App Store Connect keys
  ensure_dir "${HOME}/.fastlane"               # Fastlane config
  ensure_dir "${HOME}/.fastlane/spaceship"     # Spaceship sessions

  # Escribir Fastfile base
  _write_fastlane_template

  # Escribir guía de inicio rápido iOS
  _write_ios_quickstart

  # Variables de entorno recomendadas
  local env_line="# iOS Development"
  if ! grep -q "# iOS Development" "${HOME}/.zshrc" 2>/dev/null; then
    cat >> "${HOME}/.zshrc" << 'IOS_ENV'

# iOS Development
export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
export XCODE_DEVELOPER_DIR_PATH="$DEVELOPER_DIR"
# App Store Connect API (descarga la key desde appstoreconnect.apple.com)
# export APP_STORE_CONNECT_API_KEY_ID="XXXXXXXXXX"
# export APP_STORE_CONNECT_API_ISSUER_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
# export APP_STORE_CONNECT_API_KEY_PATH="~/.private_keys/AuthKey_XXXXXXXXXX.p8"
IOS_ENV
    track_ok "Variables de entorno iOS añadidas a .zshrc"
  fi

  ui_success "iOS / Apple Platform Development configurado ✓"
  ui_info "Guía de inicio: ~/.devforge/IOS_QUICKSTART.md"
}

# ════════════════════════════════════════════════════════════════
#  FASTLANE TEMPLATE
# ════════════════════════════════════════════════════════════════
_write_fastlane_template() {
  ensure_dir "${HOME}/.fastlane"
  cat > "${HOME}/.fastlane/README.md" << 'FASTLANE_README'
# Fastlane — DevForge iOS Setup

## Crear Fastlane en tu proyecto
```bash
cd tu-proyecto-ios
fastlane init
```

## Fastfile típico para un proyecto iOS

```ruby
# fastlane/Fastfile
default_platform(:ios)

platform :ios do

  desc "Ejecutar tests"
  lane :test do
    scan(
      scheme: "MyApp",
      devices: ["iPhone 15 Pro"],
      clean: true
    )
  end

  desc "Build y subir a TestFlight"
  lane :beta do
    ensure_git_status_clean
    increment_build_number
    build_app(
      scheme: "MyApp",
      export_method: "app-store"
    )
    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )
  end

  desc "Build y subir al App Store"
  lane :release do
    ensure_git_status_clean
    increment_version_number
    increment_build_number
    build_app(scheme: "MyApp")
    upload_to_app_store(
      submit_for_review: false,
      automatic_release: false
    )
  end

  desc "Sync certificados y profiles (Match)"
  lane :certs do
    match(type: "development")
    match(type: "appstore")
  end

  desc "Capturas de pantalla automáticas"
  lane :screenshots do
    snapshot
    frameit(white: true)
    deliver(screenshots_path: "./fastlane/screenshots")
  end

end
```

## Comandos útiles
```bash
fastlane test              # Ejecutar tests
fastlane beta              # Subir a TestFlight
fastlane release           # Subir al App Store
fastlane certs             # Sincronizar certificados
fastlane screenshots       # Capturar screenshots
fastlane match development # Certificados de desarrollo
fastlane match appstore    # Certificados de distribución
```
FASTLANE_README
  track_ok "Fastlane template escrito"
}

# ════════════════════════════════════════════════════════════════
#  IOS QUICKSTART GUIDE
# ════════════════════════════════════════════════════════════════
_write_ios_quickstart() {
  ensure_dir "${HOME}/.devforge"
  cat > "${HOME}/.devforge/IOS_QUICKSTART.md" << 'QUICKSTART'
# iOS Development — Guía de inicio rápido
## DevForge v3.4

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## CICLO DE VIDA COMPLETO

### 1. Crear nuevo proyecto
```bash
# Con Xcode GUI (recomendado para empezar)
open -a Xcode

# Con XcodeGen (proyectos reproducibles en CI)
mkdir MiApp && cd MiApp
cat > project.yml << EOF
name: MiApp
targets:
  MiApp:
    type: application
    platform: iOS
    deploymentTarget: "16.0"
    sources: [Sources]
    settings:
      PRODUCT_BUNDLE_IDENTIFIER: com.empresa.miapp
EOF
xcodegen generate

# Con Tuist (proyectos a escala)
tuist init --platform ios --name MiApp
```

### 2. Gestión de dependencias
```bash
# Swift Package Manager (recomendado, integrado en Xcode)
# Xcode → File → Add Package Dependencies

# CocoaPods
pod init
vim Podfile          # añade tus pods
pod install
open MiApp.xcworkspace   # SIEMPRE abrir .xcworkspace, no .xcodeproj

# Carthage
vim Cartfile         # github "Alamofire/Alamofire" ~> 5.0
carthage update --use-xcframeworks --platform iOS

# Mint (herramientas de desarrollo via SPM)
mint install nicklockwood/SwiftFormat
mint install realm/SwiftLint
```

### 3. Linting y formato
```bash
swiftlint                    # lint del proyecto actual
swiftlint --fix              # corregir automáticamente
swiftformat .                # formatear código
periphery scan               # encontrar código no usado
sourcery                     # generar código con templates
```

### 4. Build desde línea de comandos
```bash
# Build básico
xcodebuild -scheme MiApp -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Build con xcbeautify (output bonito)
xcodebuild -scheme MiApp -destination '...' | xcbeautify

# Crear .ipa
xcodebuild archive \
  -scheme MiApp \
  -archivePath MiApp.xcarchive
xcodebuild -exportArchive \
  -archivePath MiApp.xcarchive \
  -exportPath ./build \
  -exportOptionsPlist ExportOptions.plist
```

### 5. Testing
```bash
# XCTest en simulador
xcodebuild test \
  -scheme MiApp \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  | xcbeautify

# Parallel testing con Bluepill
bluepill -a MiApp.app -s MiApp.xctest -o results/

# Maestro UI testing
maestro test flow.yaml

# Coverage con Slather
slather coverage --html --scheme MiApp MiApp.xcodeproj
```

### 6. Simuladores
```bash
# Listar simuladores disponibles
xcrun simctl list devices available

# Iniciar simulador
xcrun simctl boot "iPhone 15 Pro"
open -a Simulator

# Instalar app en simulador
xcrun simctl install booted MiApp.app

# Lanzar app
xcrun simctl launch booted com.empresa.miapp

# Captura de pantalla
xcrun simctl io booted screenshot pantalla.png

# Grabar video
xcrun simctl io booted recordVideo video.mov

# Simular push notification
xcrun simctl push booted com.empresa.miapp notification.json

# ControlRoom (GUI)
open -a ControlRoom
```

### 7. Dispositivos físicos
```bash
# Listar dispositivos conectados
idevice_id -l
ideviceinfo

# Instalar .ipa en dispositivo
ideviceinstaller -i MiApp.ipa

# Con ios-deploy (más rápido)
ios-deploy --bundle MiApp.app

# Logs en tiempo real
idevicesyslog | grep MiApp

# Facebook IDB (alternativa potente)
idb connect localhost
idb install MiApp.app
idb launch com.empresa.miapp
```

### 8. Firma de código con Fastlane Match
```bash
# Configurar Match (solo la primera vez)
fastlane match init
# → elige: git (repositorio privado para certificados)
# → introduce el URL del repo privado

# Generar/sincronizar certificados
fastlane match development    # para desarrollo
fastlane match appstore       # para distribución

# Actualizar certificados expirados
fastlane match development --force
```

### 9. Distribución y TestFlight
```bash
# Subir a TestFlight con Fastlane
fastlane beta

# Con altool (legacy)
xcrun altool --upload-app -f MiApp.ipa \
  --type ios --apple-id TU_APPLE_ID --password "@keychain:Application Loader: TU_APPLE_ID"

# Con notarytool (moderno — para macOS apps)
xcrun notarytool submit MiApp.pkg \
  --key ~/.private_keys/AuthKey_XXXXXXXXXX.p8 \
  --key-id XXXXXXXXXX \
  --issuer xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

# Ver historial de notarización
xcrun notarytool history \
  --key ~/.private_keys/AuthKey_XXXXXXXXXX.p8 \
  --key-id XXXXXXXXXX \
  --issuer xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

### 10. Debugging y profiling
```bash
# Instruments desde CLI
xctrace record --template 'Time Profiler' \
  --attach com.empresa.miapp \
  --output profile.xctrace

# Abrir en Instruments
open profile.xctrace

# Ver logs del dispositivo en tiempo real
xcrun devicectl device syslog \
  --device <UUID> \
  --predicate 'subsystem == "com.empresa.miapp"'

# LLDB desde CLI
lldb MiApp.app
(lldb) run
(lldb) bt    # backtrace
(lldb) po variable  # print object
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## HERRAMIENTAS INSTALADAS

| Herramienta | Propósito | Comando |
|---|---|---|
| swiftlint | Linter Swift | `swiftlint` |
| swiftformat | Formatter Swift | `swiftformat .` |
| swiftgen | Generar código para assets | `swiftgen` |
| sourcery | Meta-programación | `sourcery` |
| periphery | Dead code finder | `periphery scan` |
| cocoapods | Dependency manager | `pod install` |
| carthage | Dependency manager | `carthage update` |
| mint | SPM tool manager | `mint install` |
| xcodegen | Generar proyectos Xcode | `xcodegen generate` |
| tuist | Gestión proyectos a escala | `tuist generate` |
| xcbeautify | Pretty xcodebuild | `\| xcbeautify` |
| xcpretty | Pretty xcodebuild (alt) | `\| xcpretty` |
| fastlane | Automatización completa | `fastlane <lane>` |
| libimobiledevice | Comunicación USB-iOS | `ideviceinfo` |
| ideviceinstaller | Instalar .ipa en device | `ideviceinstaller -i` |
| ios-deploy | Deploy a device real | `ios-deploy --bundle` |
| maestro | UI testing moderno | `maestro test` |
| slather | Code coverage HTML | `slather coverage` |
| sentry-cli | Upload dSYMs | `sentry-cli upload-dif` |
| bitrise | CI/CD local | `bitrise run` |
| firebase-tools | Firebase backend | `firebase deploy` |
| appcenter-cli | MS App Center | `appcenter apps list` |
| danger | PR automation | `danger` |
| jazzy | Generador de docs | `jazzy` |
| bartycrouch | Localización | `bartycrouch update` |

## RECURSOS
- Fastlane docs: https://docs.fastlane.tools
- Maestro: https://maestro.mobile.dev
- Tuist: https://tuist.io
- XcodeGen: https://github.com/yonaskolb/XcodeGen
- Periphery: https://github.com/peripheryapp/periphery
- Apple Developer docs: https://developer.apple.com/documentation
QUICKSTART
  track_ok "Guía iOS creada en ~/.devforge/IOS_QUICKSTART.md"
}
