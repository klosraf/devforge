#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────
#  Module: android — DevForge macOS Setup v3.4
#  Android Platform Development
#
#  Cubre TODO el ciclo de vida de desarrollo Android:
#  ─ Android Studio & SDK
#  ─ Command Line Tools (sdkmanager, avdmanager, adb, fastboot)
#  ─ Build tools (Gradle, Kotlin, AGP)
#  ─ Linting y análisis estático (ktlint, detekt, lint)
#  ─ Gestores de dependencias y versiones
#  ─ Emuladores y dispositivos virtuales (AVD, Genymotion)
#  ─ Comunicación con dispositivos físicos (ADB, scrcpy)
#  ─ Testing (Espresso, UIAutomator, Robolectric, Maestro, Appium)
#  ─ Build & CI/CD (Fastlane, Bitrise, GitHub Actions)
#  ─ Firma y distribución (APK signing, Play Store, Firebase)
#  ─ Análisis de binarios (bundletool, apktool, jadx)
#  ─ Performance y profiling
#  ─ Seguridad (MobSF, apktool)
# ─────────────────────────────────────────────────────────────────

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

# ── Constantes de rutas Android ──────────────────────────────────
ANDROID_HOME_DIR="${HOME}/Library/Android/sdk"
ANDROID_CMDTOOLS_DIR="${ANDROID_HOME_DIR}/cmdline-tools/latest"

module_android() {
  ui_section "ANDROID PLATFORM DEVELOPMENT" "◈"
  detect_system
  require_macos

  # ── 1. Java (requerido por todo el toolchain Android) ─────────
  ui_step "Java — requerido por el toolchain Android..."
  # OpenJDK 17 es el recomendado para Android en 2024/2025
  brew_install "openjdk@17"     "OpenJDK 17 (requerido por Android Gradle)"

  # Symlink para que macOS encuentre Java
  local jdk17="${HOMEBREW_PREFIX}/opt/openjdk@17"
  if [[ -d "${jdk17}" ]]; then
    sudo ln -sfn "${jdk17}/libexec/openjdk.jdk" \
      /Library/Java/JavaVirtualMachines/openjdk-17.jdk 2>/dev/null || true
    export JAVA_HOME="${jdk17}"
    export PATH="${JAVA_HOME}/bin:${PATH}"
    track_ok "Java 17 symlink configurado"
  fi

  # ── 2. Android Studio ─────────────────────────────────────────
  ui_step "Android Studio (IDE oficial)..."
  brew_cask_install "android-studio" "Android Studio"

  # ── 3. Android Command Line Tools ─────────────────────────────
  ui_step "Android Command Line Tools (SDK manager)..."

  # android-commandlinetools instala sdkmanager, avdmanager, etc.
  brew_cask_install "android-commandlinetools" "Android Command Line Tools"

  # Configurar ANDROID_HOME en el path del SDK
  ensure_dir "${ANDROID_HOME_DIR}"
  ensure_dir "${ANDROID_HOME_DIR}/cmdline-tools"

  # Si el cask instaló las tools, moverlas al lugar correcto
  local brew_cmdtools="${HOMEBREW_PREFIX}/share/android-commandlinetools"
  if [[ -d "${brew_cmdtools}" && ! -d "${ANDROID_CMDTOOLS_DIR}" ]]; then
    mkdir -p "${ANDROID_HOME_DIR}/cmdline-tools" 2>/dev/null || true
    ln -sf "${brew_cmdtools}" "${ANDROID_CMDTOOLS_DIR}" 2>/dev/null || true
    track_ok "Android cmdline-tools enlazadas a ${ANDROID_CMDTOOLS_DIR}"
  fi

  # Configurar variables de entorno temporalmente para los siguientes pasos
  export ANDROID_HOME="${ANDROID_HOME_DIR}"
  export ANDROID_SDK_ROOT="${ANDROID_HOME_DIR}"
  export PATH="${ANDROID_HOME}/cmdline-tools/latest/bin:${PATH}"
  export PATH="${ANDROID_HOME}/platform-tools:${PATH}"
  export PATH="${ANDROID_HOME}/emulator:${PATH}"
  export PATH="${ANDROID_HOME}/build-tools/34.0.0:${PATH}"

  # ── 4. SDK Components via sdkmanager ─────────────────────────
  ui_step "Android SDK components (plataforma, build-tools, emulador)..."

  if has_cmd sdkmanager; then
    # Aceptar todas las licencias (necesario para automatización)
    yes | sdkmanager --licenses >> "${LOG_FILE}" 2>&1 || true

    # Platform Tools: adb, fastboot (esencial)
    run_task "SDK: platform-tools (adb, fastboot)" \
      sdkmanager "platform-tools" || true

    # Android 14 (API 34) — última versión estable
    run_task "SDK: Android 14 (API 34)" \
      sdkmanager "platforms;android-34" || true

    # Android 13 (API 33) — amplio soporte
    run_task "SDK: Android 13 (API 33)" \
      sdkmanager "platforms;android-33" || true

    # Build Tools — versión 34.0.0
    run_task "SDK: Build Tools 34.0.0" \
      sdkmanager "build-tools;34.0.0" || true

    # Build Tools — versión 33.0.2 (compatible con muchos proyectos)
    run_task "SDK: Build Tools 33.0.2" \
      sdkmanager "build-tools;33.0.2" || true

    # Android Emulator
    run_task "SDK: Android Emulator" \
      sdkmanager "emulator" || true

    # System images para emuladores
    # Apple Silicon usa arm64-v8a; Intel usa x86_64
    if [[ "$IS_APPLE_SILICON" == true ]]; then
      run_task "SDK: System image ARM64 (API 34)" \
        sdkmanager "system-images;android-34;google_apis;arm64-v8a" || true
      run_task "SDK: System image ARM64 (API 33)" \
        sdkmanager "system-images;android-33;google_apis;arm64-v8a" || true
    else
      run_task "SDK: System image x86_64 (API 34)" \
        sdkmanager "system-images;android-34;google_apis;x86_64" || true
      run_task "SDK: System image x86_64 (API 33)" \
        sdkmanager "system-images;android-33;google_apis;x86_64" || true
    fi

    # Google Play services
    run_task "SDK: extras Google Play" \
      sdkmanager "extras;google;google_play_services" || true

    # Android Auto Desktop Head Unit
    # sdkmanager "extras;google;auto" || true

    track_ok "SDK components instalados"
  else
    track_fail "sdkmanager no disponible — instala Android Studio manualmente"
    ui_info "Android Studio incluye el SDK completo en: ~/Library/Android/sdk"
  fi

  # ── 5. Platform Tools directos (adb, fastboot) ───────────────
  ui_step "Android Platform Tools (adb, fastboot)..."
  # android-platform-tools cask: instala adb y fastboot directamente
  brew_cask_install "android-platform-tools" "Android Platform Tools (adb, fastboot)"

  # Verificar adb
  if has_cmd adb; then
    track_ok "adb: $(adb version 2>/dev/null | head -1)"
  fi

  # ── 6. Build System: Gradle & Kotlin ─────────────────────────
  ui_step "Build tools (Gradle, Kotlin)..."
  brew_install "gradle"         "Gradle (build system)"
  brew_install "kotlin"         "Kotlin"
  brew_install "ktlint"         "ktlint (Kotlin linter + formatter)"

  # Gradle wrapper global (útil para proyectos sin wrapper)
  if has_cmd gradle; then
    track_ok "Gradle: $(gradle --version 2>/dev/null | grep Gradle | head -1)"
  fi

  # ── 7. Kotlin & Android Linting ───────────────────────────────
  ui_step "Linting y análisis estático..."

  # ktlint — linter y formatter oficial para Kotlin
  brew_install "ktlint"         "ktlint"

  # Detekt — análisis estático avanzado para Kotlin (via compilación)
  # Mejor instalarlo via Gradle en cada proyecto
  ui_info "Detekt — añade al build.gradle.kts de tu proyecto:"
  ui_info "  id(\"io.gitlab.arturbosch.detekt\") version \"1.23.x\""

  # Android Lint — ya viene con el SDK
  if has_cmd lint; then
    track_ok "Android Lint disponible"
  fi

  # SonarQube Scanner
  brew_install "sonar-scanner"  "SonarQube Scanner" || true

  # ── 8. Android Virtual Devices (AVDs / Emuladores) ───────────
  ui_step "Configurando AVDs (Android Virtual Devices)..."

  if has_cmd avdmanager && has_cmd sdkmanager; then
    # Crear AVD estándar para testing
    local avd_arch="arm64-v8a"
    [[ "$IS_INTEL" == true ]] && avd_arch="x86_64"

    local avd_name="DevForge_API34_${avd_arch}"
    if ! avdmanager list avd 2>/dev/null | grep -q "${avd_name}"; then
      run_task "Creando AVD: ${avd_name}" \
        avdmanager create avd \
          --name "${avd_name}" \
          --package "system-images;android-34;google_apis;${avd_arch}" \
          --device "pixel_7" \
          --force 2>/dev/null || true
    else
      track_skip "AVD ${avd_name} (ya existe)"
    fi

    # AVD adicional con API 33
    local avd_name_33="DevForge_API33_${avd_arch}"
    if ! avdmanager list avd 2>/dev/null | grep -q "${avd_name_33}"; then
      run_task "Creando AVD: ${avd_name_33}" \
        avdmanager create avd \
          --name "${avd_name_33}" \
          --package "system-images;android-33;google_apis;${avd_arch}" \
          --device "pixel_6" \
          --force 2>/dev/null || true
    else
      track_skip "AVD ${avd_name_33} (ya existe)"
    fi

    track_ok "AVDs configurados (ejecuta: emulator -list-avds)"
  else
    track_skip "avdmanager no disponible — crea AVDs desde Android Studio"
  fi

  # Genymotion — emulador más rápido y flexible (alternativa)
  brew_cask_install "genymotion" "Genymotion (emulador alternativo)"

  # ── 9. Comunicación con dispositivos físicos ──────────────────
  ui_step "Device communication (adb, scrcpy, file transfer)..."

  # scrcpy — mirror y control de pantalla Android desde el Mac
  brew_install "scrcpy"              "scrcpy (mirror pantalla Android)"

  # Android File Transfer — transferir archivos via MTP
  brew_cask_install "android-file-transfer" "Android File Transfer"

  # adbcontrol — no disponible en Homebrew (alternativa: scrcpy o Android Studio)

  # Herramienta de logs mejorada
  brew_install "pidcat"              "pidcat (logcat con colores por proceso)"

  ui_info "Comandos adb esenciales:"
  ui_info "  adb devices                    — listar dispositivos conectados"
  ui_info "  adb install app.apk            — instalar APK"
  ui_info "  adb shell                      — shell en el dispositivo"
  ui_info "  adb logcat | pidcat            — logs con colores"
  ui_info "  adb pull /sdcard/archivo local — copiar archivo del device"
  ui_info "  adb push local /sdcard/        — enviar archivo al device"
  ui_info "  adb screencap /sdcard/scr.png  — captura de pantalla"
  ui_info "  adb screenrecord /sdcard/v.mp4 — grabar pantalla"
  ui_info "  scrcpy                         — mirror pantalla en Mac"

  # ── 10. Análisis de APK y AAB ─────────────────────────────────
  ui_step "APK/AAB analysis tools (bundletool, apktool, jadx)..."

  # bundletool — herramienta oficial de Google para AABs
  brew_install "bundletool"          "bundletool (Google — analizar/desplegar AABs)"

  # apktool — decompile y recompile APKs
  brew_install "apktool"             "apktool (decompile APKs)"

  # jadx — decompilador Java/Kotlin a partir de APKs
  brew_install "jadx"                "jadx (decompilador APK a Java/Kotlin)"

  # aapt2 — Android Asset Packaging Tool (incluido en SDK)
  if [[ -f "${ANDROID_HOME_DIR}/build-tools/34.0.0/aapt2" ]]; then
    track_ok "aapt2 disponible en SDK"
  fi

  # dexdump — analizar .dex files (incluido en SDK platform-tools)
  # baksmali/smali — no disponible en Homebrew (alternativa: apktool que ya está instalado)

  ui_info "Comandos bundletool:"
  ui_info "  bundletool build-apks --bundle=app.aab --output=app.apks"
  ui_info "  bundletool install-apks --apks=app.apks"
  ui_info "  bundletool get-size total --apks=app.apks"

  # ── 11. Firma de APKs ─────────────────────────────────────────
  ui_step "APK signing tools..."

  # apksigner — ya incluido en build-tools del SDK
  # keytool — incluido en Java
  # jarsigner — incluido en Java

  if has_cmd keytool; then
    track_ok "keytool disponible (para generar keystores)"
    ui_info "Generar keystore de desarrollo:"
    ui_info "  keytool -genkey -v -keystore ~/dev-keystore.jks \\"
    ui_info "    -keyalg RSA -keysize 2048 -validity 10000 \\"
    ui_info "    -alias dev-key"
  fi

  # zipalign — optimización de APKs (en SDK build-tools)
  if [[ -f "${ANDROID_HOME_DIR}/build-tools/34.0.0/zipalign" ]]; then
    track_ok "zipalign disponible en SDK"
  fi

  # Crear keystore de desarrollo si no existe
  local dev_keystore="${HOME}/.android/dev-keystore.jks"
  if [[ ! -f "${dev_keystore}" ]] && has_cmd keytool; then
    ensure_dir "${HOME}/.android"
    keytool -genkey -v \
      -keystore "${dev_keystore}" \
      -keyalg RSA -keysize 2048 -validity 10000 \
      -alias devforge-key \
      -dname "CN=DevForge Dev, OU=Development, O=DevForge, L=Unknown, ST=Unknown, C=US" \
      -storepass devforge -keypass devforge \
      >> "${LOG_FILE}" 2>&1 && \
      track_ok "Keystore de desarrollo creado: ${dev_keystore}" || true
    ui_info "⚠️  Keystore en ~/.android/dev-keystore.jks (solo para desarrollo)"
    ui_info "   NUNCA uses este keystore en producción"
  fi

  # ── 12. Testing Frameworks ────────────────────────────────────
  ui_step "Testing frameworks..."

  # Maestro — UI testing moderno y cross-platform
  if ! has_cmd maestro; then
    ui_info "Instalando Maestro (UI testing framework para Android)..."
    if curl -fsSL "https://get.maestro.mobile.dev" 2>>"${LOG_FILE}" \
         | bash >> "${LOG_FILE}" 2>&1; then
      track_ok "Maestro"
    else
      track_fail "Maestro — ver: maestro.mobile.dev"
    fi
  else
    track_skip "Maestro (ya instalado)"
  fi

  # Appium — automatización de apps móviles (iOS + Android)
  npm_global_install "appium"              "Appium (automatización móvil cross-platform)"
  npm_global_install "@appium/doctor"      "Appium Doctor (diagnóstico)"

  # Drivers de Appium para Android
  if has_cmd appium; then
    appium driver install uiautomator2 >> "${LOG_FILE}" 2>&1 && \
      track_ok "Appium UIAutomator2 driver" || true
    appium driver install espresso >> "${LOG_FILE}" 2>&1 && \
      track_ok "Appium Espresso driver" || true
  fi

  # Detox — E2E testing para React Native Android
  npm_global_install "detox-cli"           "Detox CLI (RN E2E testing)"

  # WebDriverAgent (Appium dependency)
  npm_global_install "wd"                  "WebDriver client para Node"

  ui_info "Testing frameworks vía Gradle (añade a build.gradle):"
  ui_info "  Espresso      — com.android.support.test.espresso:espresso-core"
  ui_info "  UI Automator  — com.android.support.test.uiautomator:uiautomator"
  ui_info "  Robolectric   — org.robolectric:robolectric (tests JVM locales)"
  ui_info "  MockK         — io.mockk:mockk (mocking para Kotlin)"
  ui_info "  Truth         — com.google.truth:truth (assertions legibles)"
  ui_info "  Turbine       — app.cash.turbine:turbine (testing Kotlin Flow)"

  # ── 13. FASTLANE para Android ─────────────────────────────────
  ui_step "Fastlane (automatización Android — Play Store, Firebase)..."
  brew_install "fastlane"            "Fastlane"

  if has_cmd gem; then
    # supply — subir a Google Play Store
    gem install supply         --no-document >> "${LOG_FILE}" 2>&1 || true
    # screengrab — capturas automáticas en emulador
    gem install screengrab     --no-document >> "${LOG_FILE}" 2>&1 || true
    track_ok "Fastlane gems Android (supply, screengrab)"
  fi

  _write_android_fastfile_template

  # ── 14. Firebase App Distribution ────────────────────────────
  ui_step "Firebase (distribución y testing)..."
  npm_global_install "firebase-tools"      "Firebase CLI"

  ui_info "Firebase App Distribution:"
  ui_info "  firebase appdistribution:distribute app.apk \\"
  ui_info "    --app <APP_ID> --groups testers"

  # ── 15. CI/CD ─────────────────────────────────────────────────
  ui_step "CI/CD tools..."
  brew_install "bitrise"             "Bitrise CLI"
  npm_global_install "appcenter-cli" "AppCenter CLI (MS)"

  # act — ejecutar GitHub Actions localmente (ya en frameworks)
  # Soporte nativo para Android en GHA con macos-14 runners

  ui_info "CI/CD para Android:"
  ui_info "  GitHub Actions: uses: actions/setup-java + gradle build"
  ui_info "  Bitrise:        bitrise run primary"
  ui_info "  Firebase:       firebase appdistribution:distribute"
  ui_info "  Fastlane:       fastlane android beta"

  # ── 16. Debugging & Profiling ─────────────────────────────────
  ui_step "Debugging & profiling tools..."

  # Flipper — debugging para React Native y apps nativas
  brew_cask_install "flipper"        "Flipper (debugging para Android)"

  # Proxyman (ya en apps.sh) — interceptar tráfico HTTPS
  # Charles  (ya en apps.sh)

  # Android GPU Inspector (AGI) — profiling GPU
  brew_cask_install "android-gpu-inspector" "Android GPU Inspector" || true

  # Perfetto — sistema de tracing avanzado
  ui_info "Perfetto (profiling avanzado): https://ui.perfetto.dev"
  ui_info "  adb shell perfetto -c /dev/stdin --txt -o /data/misc/perfetto-traces/trace \\"
  ui_info "    <<EOF"
  ui_info "  buffers { size_kb: 8960 } ..."
  ui_info "  EOF"

  ui_info "Android Profiler (en Android Studio):"
  ui_info "  CPU, Memory, Network, Battery profilers integrados"

  # ── 17. Performance & Leak Detection ─────────────────────────
  ui_step "Performance tools..."

  # LeakCanary — detección de memory leaks (via Gradle)
  ui_info "LeakCanary (detección de leaks — añade al build.gradle):"
  ui_info "  debugImplementation 'com.squareup.leakcanary:leakcanary-android:2.x'"

  # Benchmark library (vía Gradle/Jetpack)
  ui_info "Jetpack Benchmark (microbenchmarks):"
  ui_info "  implementation 'androidx.benchmark:benchmark-junit4:1.x'"

  # Systrace / Perfetto
  if [[ -f "${ANDROID_HOME_DIR}/platform-tools/systrace/systrace.py" ]]; then
    track_ok "systrace disponible"
  fi

  # ── 18. Seguridad ─────────────────────────────────────────────
  ui_step "Security & reverse engineering tools..."

  # MobSF — Mobile Security Framework (análisis estático + dinámico, via Docker)
  # Mostrar instrucciones Docker si el cask no está disponible (brew_cask_install siempre devuelve 0)
  if ! brew list --cask mobsf &>/dev/null 2>&1 && ! has_cmd mobsf 2>/dev/null; then
    ui_info "MobSF — instala via Docker:"
    ui_info "  docker pull opensecurity/mobile-security-framework-mobsf"
    ui_info "  docker run -it -p 8000:8000 opensecurity/mobile-security-framework-mobsf"
  fi

  # apktool — ya instalado arriba
  # jadx — ya instalado arriba

  # Frida — dynamic instrumentation toolkit
  pip3 install --break-system-packages frida-tools >> "${LOG_FILE}" 2>&1 && \
    track_ok "Frida (dynamic instrumentation)" || true

  # objection — runtime mobile exploration (basado en Frida)
  pip3 install --break-system-packages objection >> "${LOG_FILE}" 2>&1 && \
    track_ok "Objection (mobile exploration)" || true

  # ── 19. Google Play & Distribución ────────────────────────────
  ui_step "Google Play Store distribution..."

  ui_info "Publicar en Google Play con Fastlane Supply:"
  ui_info "  1. Crea Service Account en Google Cloud Console"
  ui_info "  2. Habilita Google Play Android Developer API"
  ui_info "  3. Descarga el JSON de credenciales"
  ui_info "  4. fastlane supply init  (primer setup)"
  ui_info "  5. fastlane supply       (subir metadata/screenshots)"
  ui_info "  fastlane supply --apk app-release.apk  (subir APK)"

  # Configurar directorio de credenciales de Google Play
  ensure_dir "${HOME}/.android"
  ensure_dir "${HOME}/.config/gcloud"

  ui_info ""
  ui_info "Google Play API — pasos:"
  ui_info "  1. console.cloud.google.com → crear Service Account"
  ui_info "  2. Permisos: \"Versioner\" en Google Play Console"
  ui_info "  3. Guarda el JSON en ~/.android/google-play-key.json"

  # ── 20. Configuración del entorno ─────────────────────────────
  ui_step "Configurando variables de entorno Android..."

  # Añadir al .zshrc
  if ! grep -q "# Android Development" "${HOME}/.zshrc" 2>/dev/null; then
    cat >> "${HOME}/.zshrc" << ANDROID_ENV

# Android Development
export ANDROID_HOME="\${HOME}/Library/Android/sdk"
export ANDROID_SDK_ROOT="\${ANDROID_HOME}"
export PATH="\${ANDROID_HOME}/cmdline-tools/latest/bin:\${PATH}"
export PATH="\${ANDROID_HOME}/platform-tools:\${PATH}"
export PATH="\${ANDROID_HOME}/emulator:\${PATH}"
export PATH="\${ANDROID_HOME}/build-tools/34.0.0:\${PATH}"

# Java para Android (OpenJDK 17)
export JAVA_HOME="\$(${HOMEBREW_PREFIX}/opt/openjdk@17/bin/java_home 2>/dev/null || echo '${HOMEBREW_PREFIX}/opt/openjdk@17')"
export PATH="\${JAVA_HOME}/bin:\${PATH}"

# Gradle
export GRADLE_OPTS="-Dorg.gradle.daemon=true -Dorg.gradle.parallel=true -Xmx4g"
ANDROID_ENV
    track_ok "Variables de entorno Android añadidas a .zshrc"
  else
    track_skip "Variables de entorno Android (ya configuradas)"
  fi

  # Añadir aliases Android a .zsh_aliases
  _write_android_aliases

  # Crear estructura de proyecto de referencia
  ensure_dir "${HOME}/Developer/Android"

  # Crear guía de inicio rápido
  _write_android_quickstart

  ui_success "Android Platform Development configurado ✓"
  ui_info "Guía de inicio: ~/.devforge/ANDROID_QUICKSTART.md"
  ui_info "Recuerda: source ~/.zshrc  o reinicia la terminal"
}

# ════════════════════════════════════════════════════════════════
#  FASTFILE ANDROID TEMPLATE
# ════════════════════════════════════════════════════════════════
_write_android_fastfile_template() {
  ensure_dir "${HOME}/.fastlane/android"
  cat > "${HOME}/.fastlane/android/Fastfile.template" << 'FASTFILE'
# fastlane/Fastfile — Template Android — DevForge
default_platform(:android)

platform :android do

  # ── Testing ───────────────────────────────────────────────────
  desc "Ejecutar unit tests"
  lane :test do
    gradle(
      task: "test",
      build_type: "Debug"
    )
  end

  desc "Ejecutar tests instrumentados en emulador"
  lane :instrumented_tests do
    gradle(
      task: "connectedAndroidTest",
      build_type: "Debug"
    )
  end

  # ── Build ─────────────────────────────────────────────────────
  desc "Build APK de debug"
  lane :build_debug do
    gradle(
      task: "assemble",
      build_type: "Debug"
    )
  end

  desc "Build AAB de release (para Play Store)"
  lane :build_release do
    # Incrementar version code
    increment_version_code(
      gradle_file_path: "app/build.gradle.kts"
    )
    gradle(
      task: "bundle",
      build_type: "Release",
      properties: {
        "android.injected.signing.store.file"     => ENV["KEYSTORE_PATH"],
        "android.injected.signing.store.password" => ENV["KEYSTORE_PASSWORD"],
        "android.injected.signing.key.alias"      => ENV["KEY_ALIAS"],
        "android.injected.signing.key.password"   => ENV["KEY_PASSWORD"],
      }
    )
  end

  # ── Distribución interna ──────────────────────────────────────
  desc "Subir a Firebase App Distribution (testing interno)"
  lane :distribute_firebase do
    build_debug
    firebase_app_distribution(
      app:             ENV["FIREBASE_APP_ID"],
      groups:          "testers",
      release_notes:   "Build automático desde Fastlane",
      firebase_cli_token: ENV["FIREBASE_TOKEN"]
    )
  end

  desc "Subir a Microsoft AppCenter"
  lane :distribute_appcenter do
    build_debug
    appcenter_upload(
      api_token:    ENV["APPCENTER_API_TOKEN"],
      owner_name:   ENV["APPCENTER_OWNER"],
      app_name:     ENV["APPCENTER_APP_NAME"],
      file:         "app/build/outputs/apk/debug/app-debug.apk",
      destinations: "Collaborators"
    )
  end

  # ── Google Play Store ─────────────────────────────────────────
  desc "Subir a Google Play (track: internal)"
  lane :play_internal do
    build_release
    upload_to_play_store(
      track:            "internal",
      aab:              "app/build/outputs/bundle/release/app-release.aab",
      json_key:         ENV["GOOGLE_PLAY_JSON_KEY"],
      skip_upload_apk:  true,
    )
  end

  desc "Subir a Google Play (track: production)"
  lane :play_release do
    build_release
    upload_to_play_store(
      track:               "production",
      aab:                 "app/build/outputs/bundle/release/app-release.aab",
      json_key:            ENV["GOOGLE_PLAY_JSON_KEY"],
      skip_upload_apk:     true,
      rollout:             "0.1",   # 10% rollout inicial
    )
  end

  desc "Capturas de pantalla automáticas"
  lane :screenshots do
    screengrab(
      locales:              ["en-US", "es-ES"],
      clear_previous_screenshots: true,
      app_package_name:     "com.empresa.miapp",
      tests_package_name:   "com.empresa.miapp.test"
    )
  end

  # ── Deploy completo ───────────────────────────────────────────
  desc "Build, test y subir a Play Store internal"
  lane :ci do
    test
    play_internal
  end

end
FASTFILE
  track_ok "Fastfile Android template escrito"
}

# ════════════════════════════════════════════════════════════════
#  ANDROID ALIASES
# ════════════════════════════════════════════════════════════════
_write_android_aliases() {
  local aliases_file="${HOME}/.zsh_aliases"
  touch "${aliases_file}"

  if ! grep -q "# Android aliases" "${aliases_file}" 2>/dev/null; then
    cat >> "${aliases_file}" << 'ANDROID_ALIASES'

# ── Android ───────────────────────────────────────────────────
# ADB
alias adb-devices='adb devices -l'
alias adb-wifi='adb tcpip 5555 && adb connect'
alias adb-restart='adb kill-server && adb start-server'
alias adb-log='adb logcat -c && adb logcat'
alias adb-logpid='adb logcat | pidcat'
alias adb-scr='adb shell screencap /sdcard/screen.png && adb pull /sdcard/screen.png'
alias adb-rec='adb shell screenrecord /sdcard/video.mp4'
alias adb-install='adb install -r'
alias adb-uninstall='adb uninstall'
alias adb-shell='adb shell'
alias adb-wifi-connect='adb connect'
alias adb-clear='adb shell pm clear'
alias adb-monkey='adb shell monkey -p'
alias adb-battery='adb shell dumpsys battery'
alias adb-net='adb shell dumpsys netstats'
alias adb-mem='adb shell dumpsys meminfo'
alias adb-crash='adb logcat -b crash'
alias adb-activity='adb shell dumpsys activity activities | head -30'

# Emulador
alias avd-list='emulator -list-avds'
alias avd-run='emulator -avd'
alias avd-wipe='emulator -avd'

# Gradle
alias gw='./gradlew'
alias gwb='./gradlew build'
alias gwt='./gradlew test'
alias gwi='./gradlew installDebug'
alias gwc='./gradlew clean'
alias gwbt='./gradlew build && ./gradlew test'
alias gw-dep='./gradlew dependencies'
alias gw-tasks='./gradlew tasks --all'

# APK/AAB
alias apk-info='aapt2 dump badging'
alias apk-perms='aapt2 dump permissions'
alias apk-size='bundletool get-size total --apks'
alias apk-decompile='jadx -d output'

# Fastlane
alias fl='fastlane'
alias fl-test='fastlane android test'
alias fl-debug='fastlane android build_debug'
alias fl-release='fastlane android build_release'
alias fl-beta='fastlane android distribute_firebase'
ANDROID_ALIASES
    track_ok "Aliases Android añadidos a .zsh_aliases"
  fi
}

# ════════════════════════════════════════════════════════════════
#  ANDROID QUICKSTART GUIDE
# ════════════════════════════════════════════════════════════════
_write_android_quickstart() {
  ensure_dir "${HOME}/.devforge"
  cat > "${HOME}/.devforge/ANDROID_QUICKSTART.md" << 'GUIDE'
# Android Development — Guía de inicio rápido
## DevForge v3.4

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## CONFIGURACIÓN INICIAL

### Variables de entorno (ya en .zshrc)
```bash
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$ANDROID_HOME/platform-tools:$PATH"
export PATH="$ANDROID_HOME/emulator:$PATH"
export PATH="$ANDROID_HOME/build-tools/34.0.0:$PATH"
```

### Verificar instalación
```bash
adb version              # Android Debug Bridge
sdkmanager --list        # paquetes SDK disponibles
avdmanager list avd      # emuladores creados
emulator -list-avds      # emuladores disponibles
java -version            # Java 17
gradle --version         # Gradle
```

---

## SDK MANAGEMENT

### Listar e instalar componentes
```bash
# Ver todo lo disponible
sdkmanager --list

# Instalar componentes específicos
sdkmanager "platforms;android-34"
sdkmanager "build-tools;34.0.0"
sdkmanager "system-images;android-34;google_apis;arm64-v8a"
sdkmanager "ndk;25.2.9519653"        # NDK para código nativo
sdkmanager "cmake;3.22.1"            # CMake para NDK

# Actualizar todo
sdkmanager --update

# Aceptar licencias
yes | sdkmanager --licenses
```

---

## EMULADORES (AVD)

### Crear y lanzar emuladores
```bash
# Crear AVD con Pixel 7 (API 34)
avdmanager create avd \
  --name "Pixel7_API34" \
  --package "system-images;android-34;google_apis;arm64-v8a" \
  --device "pixel_7"

# Listar AVDs
avdmanager list avd
emulator -list-avds

# Lanzar emulador
emulator -avd Pixel7_API34

# Opciones útiles del emulador
emulator -avd Pixel7_API34 -no-audio -no-window  # headless (CI)
emulator -avd Pixel7_API34 -wipe-data            # reset completo
emulator -avd Pixel7_API34 -gpu host             # GPU acelerada

# Con Genymotion (más rápido)
open -a Genymotion
```

---

## ADB — DISPOSITIVOS

### Conectar dispositivos
```bash
adb devices -l            # listar todos (físicos + emuladores)

# WiFi debugging (Android 11+)
# En el teléfono: Ajustes → Developer Options → Wireless debugging
adb tcpip 5555
adb connect 192.168.x.x:5555

# Android 11+ vía pairing
adb pair 192.168.x.x:PORT  # código de 6 dígitos del teléfono

# Verificar conexión
adb -s <device-serial> shell echo "ok"
```

### Instalar y gestionar apps
```bash
# Instalar APK
adb install app-debug.apk
adb install -r app-debug.apk   # reinstalar (mantiene datos)
adb install -t app-debug.apk   # permite apps de test

# Instalar AAB (requiere bundletool)
bundletool build-apks \
  --bundle=app.aab \
  --output=app.apks \
  --ks=keystore.jks \
  --ks-pass=pass:password \
  --ks-key-alias=key \
  --key-pass=pass:password
bundletool install-apks --apks=app.apks

# Desinstalar
adb uninstall com.empresa.miapp

# Limpiar datos
adb shell pm clear com.empresa.miapp

# Lanzar Activity
adb shell am start -n com.empresa.miapp/.MainActivity

# Enviar Intent
adb shell am broadcast -a com.empresa.ACTION
```

### Logs y depuración
```bash
# Logcat básico
adb logcat

# Filtrar por tag
adb logcat -s MyApp:D

# Filtrar por paquete (con pidcat)
adb logcat | pidcat com.empresa.miapp

# Solo crashes
adb logcat -b crash

# Logs del sistema
adb logcat -b system

# Limpiar logs
adb logcat -c

# Ver actividades en ejecución
adb shell dumpsys activity activities

# Memoria de una app
adb shell dumpsys meminfo com.empresa.miapp

# Batería
adb shell dumpsys battery

# Red
adb shell dumpsys connectivity
```

### Captura y grabación
```bash
# Screenshot
adb shell screencap /sdcard/screen.png
adb pull /sdcard/screen.png ./

# Grabar pantalla (máx. 3 min por defecto)
adb shell screenrecord /sdcard/video.mp4
# Ctrl+C para detener
adb pull /sdcard/video.mp4 ./

# Mirror con scrcpy (más cómodo)
scrcpy                          # mirror básico
scrcpy --max-fps 60             # 60 FPS
scrcpy --bit-rate 8M            # bitrate alto
scrcpy --record file.mp4        # grabar mientras haces mirror
scrcpy --no-display --record f.mp4  # solo grabar, sin ventana
```

### Transferencia de archivos
```bash
# Copiar del dispositivo al Mac
adb pull /sdcard/Download/archivo.pdf ./

# Copiar del Mac al dispositivo
adb push archivo.txt /sdcard/

# Shell interactivo
adb shell

# Ejecutar comando
adb shell ls /sdcard/
adb shell cat /proc/cpuinfo
```

---

## BUILD CON GRADLE

```bash
# Compilar debug
./gradlew assembleDebug

# Compilar release
./gradlew assembleRelease

# Generar AAB (Play Store)
./gradlew bundleRelease

# Tests unitarios
./gradlew test

# Tests instrumentados (requiere emulador/dispositivo)
./gradlew connectedAndroidTest

# Tests de un módulo específico
./gradlew :app:test

# Lint
./gradlew lint
./gradlew lintDebug

# Limpiar
./gradlew clean

# Ver dependencias
./gradlew dependencies
./gradlew :app:dependencies --configuration debugCompileClasspath

# Profiling de build
./gradlew --profile assembleDebug
# Abre build/reports/profile/profile-*.html
```

---

## FIRMA DE APKs

```bash
# Generar keystore (solo una vez por app)
keytool -genkey -v \
  -keystore mi-app-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias mi-app

# Firmar APK con apksigner
apksigner sign \
  --ks mi-app-release.jks \
  --ks-key-alias mi-app \
  app-release-unsigned.apk

# Verificar firma
apksigner verify --verbose app-release.apk

# Firmar con jarsigner (legacy)
jarsigner -verbose \
  -sigalg SHA256withRSA \
  -digestalg SHA-256 \
  -keystore mi-app-release.jks \
  app-release-unsigned.apk mi-app

# Optimizar con zipalign (ANTES de firmar)
zipalign -v 4 app-release-unsigned.apk app-release-aligned.apk
```

---

## TESTING

### Espresso (UI tests — en dispositivo/emulador)
```kotlin
// build.gradle.kts
androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
androidTestImplementation("androidx.test.ext:junit:1.1.5")

// Test básico
@Test fun clickButton() {
    onView(withId(R.id.button)).perform(click())
    onView(withId(R.id.result)).check(matches(withText("OK")))
}
```

### Maestro (UI testing cross-platform)
```yaml
# flow.yaml
appId: com.empresa.miapp
---
- launchApp
- tapOn:
    text: "Login"
- inputText: "usuario@email.com"
- tapOn:
    id: "login_button"
- assertVisible:
    text: "Bienvenido"
```
```bash
maestro test flow.yaml           # ejecutar flow
maestro studio                   # IDE visual para flows
maestro cloud flow.yaml          # ejecutar en cloud
```

### Appium
```bash
# Iniciar servidor Appium
appium

# Diagnóstico
appium-doctor --android

# Ejecutar tests Appium
# (configure en tu proyecto según el framework: WebdriverIO, etc.)
```

---

## DISTRIBUCIÓN Y DEPLOY

### Firebase App Distribution
```bash
# Setup
firebase login
firebase appdistribution:distribute app-debug.apk \
  --app 1:xxxx:android:xxxx \
  --groups testers \
  --release-notes "Fix: crash al abrir notificaciones"

# Con Fastlane
fastlane android distribute_firebase
```

### Google Play Store con Fastlane
```bash
# Setup inicial (solo una vez)
fastlane supply init

# Subir AAB a internal testing
fastlane android play_internal

# Subir a producción con 10% rollout
fastlane android play_release

# Solo actualizar metadata/screenshots
fastlane supply --skip_upload_aab
```

### AppCenter
```bash
# Login
appcenter login

# Listar apps
appcenter apps list

# Subir build
appcenter distribute release \
  --app "Owner/AppName" \
  --file app-debug.apk \
  --group Testers
```

---

## ANÁLISIS DE APK/AAB

```bash
# Información del APK
aapt2 dump badging app.apk
aapt2 dump permissions app.apk

# Tamaño por configuración
bundletool get-size total --apks=app.apks
bundletool get-size total --apks=app.apks --dimensions=ABI,LANGUAGE

# Descompilar APK
apktool d app.apk -o output/   # decompile
apktool b output/ -o app-mod.apk  # recompile

# Decompilación a Java/Kotlin
jadx -d output app.apk
jadx-gui app.apk   # con interfaz gráfica

# Analizar clases DEX
dexdump app.apk
```

---

## SEGURIDAD

```bash
# MobSF — análisis estático y dinámico
docker pull opensecurity/mobile-security-framework-mobsf
docker run -it -p 8000:8000 opensecurity/mobile-security-framework-mobsf
# Abre: http://localhost:8000 → sube el APK

# Frida — instrumentación dinámica
frida-ps -U                    # procesos en el dispositivo
frida -U -f com.empresa.miapp  # attach y instrumentar
frida -U -l script.js com.empresa.miapp

# Objection — exploración en runtime
objection -g com.empresa.miapp explore
```

---

## HERRAMIENTAS INSTALADAS

| Herramienta | Propósito | Comando |
|---|---|---|
| adb | Android Debug Bridge | `adb devices` |
| fastboot | Flash dispositivos | `fastboot devices` |
| sdkmanager | Gestionar SDK | `sdkmanager --list` |
| avdmanager | Gestionar AVDs | `avdmanager list avd` |
| emulator | Emulador Android | `emulator -avd <name>` |
| gradle | Build system | `./gradlew build` |
| kotlin | Compilador Kotlin | `kotlinc` |
| ktlint | Linter Kotlin | `ktlint` |
| scrcpy | Mirror pantalla | `scrcpy` |
| pidcat | Logs con colores | `adb logcat \| pidcat` |
| bundletool | Analizar AABs | `bundletool get-size` |
| apktool | Decompile APKs | `apktool d app.apk` |
| jadx | Decompile a Java | `jadx -d out app.apk` |
| fastlane | Automatización | `fastlane android beta` |
| firebase | Firebase CLI | `firebase deploy` |
| appium | Automatización UI | `appium` |
| maestro | UI testing | `maestro test flow.yaml` |
| detox-cli | RN E2E testing | `detox test` |
| bitrise | CI/CD local | `bitrise run` |
| appcenter-cli | MS App Center | `appcenter apps list` |
| frida-tools | Instrumentación | `frida-ps -U` |
| objection | Runtime explore | `objection explore` |

## RECURSOS
- Android Developers: https://developer.android.com
- Fastlane Android: https://docs.fastlane.tools/actions/supply/
- Maestro: https://maestro.mobile.dev
- Appium: https://appium.io
- Firebase: https://firebase.google.com/docs/app-distribution
- scrcpy: https://github.com/Genymobile/scrcpy
- MobSF: https://mobsf.github.io/docs
GUIDE
  track_ok "Guía Android creada en ~/.devforge/ANDROID_QUICKSTART.md"
}
