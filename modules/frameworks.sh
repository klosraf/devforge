#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────
#  Module: frameworks — DevForge macOS Setup v3.3
#  Frameworks, bibliotecas, DevOps, BBDs, seguridad
#
#  CORRECCIONES v3.3:
#  - npm: eliminados paquetes obsoletos/inexistentes
#  - brew: nombres corregidos y verificados
#  - docker: usando colima en lugar de Docker Desktop cuando posible
#  - Todos los loops usan || true correctamente
# ─────────────────────────────────────────────────────────────────

source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

module_frameworks() {
  ui_section "FRAMEWORKS & LIBRARIES" "◈"

  # ── JS/TS: Herramientas de build y scaffolding ────────────────
  ui_step "JavaScript / TypeScript — build tools..."
  local js_build=(
    "vite"              # build tool moderno
    "create-vite"       # scaffolding para Vite
    "turbo"             # monorepo turborepo
    "nx"                # monorepo Nx
    "esbuild"           # bundler ultra-rápido en Go
    "rollup"            # bundler para librerías
    "webpack-cli"       # bundler clásico
    "@swc/cli"          # compilador TypeScript/JS en Rust
    "parcel"            # bundler zero-config
  )
  for pkg in "${js_build[@]}"; do
    npm_global_install "${pkg}" "${pkg}"
  done

  # ── JS/TS: Frameworks ─────────────────────────────────────────
  ui_step "JavaScript / TypeScript — frameworks..."
  local js_frameworks=(
    "create-next-app"           # Next.js
    "create-vue"                # Vue 3 (reemplaza @vue/cli)
    "nuxi"                      # Nuxt 3
    "create-svelte"             # SvelteKit
    "@angular/cli"              # Angular
    "create-astro"              # Astro
    "@solidjs/start"            # SolidStart
    "create-remix"              # Remix (no @remix-run/dev)
    "create-qwik"               # Qwik
    "@nestjs/cli"               # NestJS
    "fastify-cli"               # Fastify
  )
  for pkg in "${js_frameworks[@]}"; do
    npm_global_install "${pkg}" "${pkg}"
  done

  # ── JS/TS: Testing ────────────────────────────────────────────
  ui_step "JavaScript / TypeScript — testing..."
  local js_testing=(
    "vitest"                    # test runner moderno (mejor que jest)
    "jest"                      # test runner clásico
    "@playwright/test"          # E2E testing
    "cypress"                   # E2E testing alternativo
  )
  for pkg in "${js_testing[@]}"; do
    npm_global_install "${pkg}" "${pkg}"
  done

  # ── JS/TS: Linting y formato ──────────────────────────────────
  ui_step "JavaScript / TypeScript — linting/format..."
  local js_lint=(
    "eslint"                    # linter JS/TS
    "prettier"                  # formatter
    "@biomejs/biome"            # lint+format todo en uno (Rust)
  )
  for pkg in "${js_lint[@]}"; do
    npm_global_install "${pkg}" "${pkg}"
  done

  # ── JS/TS: Dev utilities ──────────────────────────────────────
  ui_step "JavaScript / TypeScript — dev utilities..."
  local js_utils=(
    "nodemon"                   # file watcher para Node
    "ts-node"                   # TypeScript REPL
    "tsx"                       # ts-node mejorado
    "concurrently"              # ejecutar múltiples comandos
    "cross-env"                 # variables de entorno cross-platform
    "dotenv-cli"                # cargar .env desde CLI
    "zx"                        # scripting con JS
    "degit"                     # clonar repos sin git
    "np"                        # publicar npm packages
    "bumpp"                     # bump de versiones (mejor que np)
    "serve"                     # servidor HTTP estático
    "http-server"               # servidor HTTP simple
    "json-server"               # REST API mock
    "localtunnel"               # tunnel local (alternativa ngrok)
    "@antfu/ni"                 # npm/yarn/pnpm unified interface
    "taze"                      # actualizar dependencias
    "depcheck"                  # encontrar dependencias no usadas
    "npm-check-updates"         # actualizar package.json
    "prisma"                    # ORM para TypeScript
    "drizzle-kit"               # ORM alternativo
    "wrangler"                  # Cloudflare Workers CLI
    "vercel"                    # Vercel CLI (no 'vercel-cli')
    "netlify-cli"               # Netlify CLI (nombre correcto en npm)
  )
  for pkg in "${js_utils[@]}"; do
    npm_global_install "${pkg}" "${pkg}"
  done

  # ── Python: Frameworks web ────────────────────────────────────
  ui_step "Python — frameworks web..."
  # Instalar en el Python del sistema con --break-system-packages
  local py_web=("fastapi" "uvicorn[standard]" "gunicorn"
                 "flask" "django" "starlette" "httpx" "aiohttp"
                 "requests" "pydantic" "pydantic-settings")
  for pkg in "${py_web[@]}"; do
    pip3 install --quiet --break-system-packages "${pkg}" >> "${LOG_FILE}" 2>&1 || true
  done
  track_ok "Python web frameworks"

  # ── Python: Data / ML (solo esenciales — torch es enorme) ────
  ui_step "Python — data science essentials..."
  local py_data=("numpy" "pandas" "polars" "matplotlib" "scikit-learn"
                 "jupyter" "ipython" "rich" "typer" "click")
  for pkg in "${py_data[@]}"; do
    pip3 install --quiet --break-system-packages "${pkg}" >> "${LOG_FILE}" 2>&1 || true
  done
  track_ok "Python data essentials"

  # ── Python: AI/LLM ────────────────────────────────────────────
  ui_step "Python — AI/LLM libraries..."
  local py_ai=("openai" "anthropic" "langchain" "langchain-core"
               "litellm" "instructor" "tiktoken" "sentence-transformers")
  for pkg in "${py_ai[@]}"; do
    pip3 install --quiet --break-system-packages "${pkg}" >> "${LOG_FILE}" 2>&1 || true
  done
  track_ok "Python AI/LLM libraries"

  # ── Python: Dev tools ─────────────────────────────────────────
  ui_step "Python — dev tools..."
  local py_dev=("black" "ruff" "mypy" "pylint" "isort"
                "pytest" "pytest-asyncio" "pytest-cov"
                "pre-commit" "bandit" "safety" "python-dotenv")
  for pkg in "${py_dev[@]}"; do
    pip3 install --quiet --break-system-packages "${pkg}" >> "${LOG_FILE}" 2>&1 || true
  done
  track_ok "Python dev tools"

  # ── Rust: Cargo tools ─────────────────────────────────────────
  ui_step "Rust — cargo tools..."
  if has_cmd cargo; then
    # cargo-watch fue archivado en crates.io — usar watchexec (instalado via brew)
    local cargo_tools=(
      "cargo-nextest"
      "cargo-edit"
      "cargo-expand"
      "cargo-audit"
      "cargo-deny"
      "cargo-bloat"
      "wasm-pack"
      "sqlx-cli"
    )
    for crate in "${cargo_tools[@]}"; do
      cargo install "${crate}" >> "${LOG_FILE}" 2>&1 || true
    done
    track_ok "Rust cargo tools"
  else
    track_skip "Rust cargo tools (cargo no disponible)"
  fi

  # ── DevOps: Contenedores ──────────────────────────────────────
  ui_step "DevOps — contenedores..."
  # OrbStack es la mejor alternativa a Docker Desktop en macOS
  brew_cask_install "orbstack"  "OrbStack (Docker + VM, más ligero)"
  # Docker CLI solo (sin Docker Desktop)
  brew_install "docker"         "Docker CLI"
  brew_install "docker-compose" "Docker Compose"
  brew_install "docker-credential-helper" "Docker Credential Helper"
  brew_install "colima"         "Colima (Docker runtime alternativo)"
  brew_install "lazydocker"     "LazyDocker (TUI para Docker)"
  brew_install "ctop"           "ctop (top para contenedores)"
  brew_install "dive"           "dive (explorar capas de imágenes Docker)"

  # ── DevOps: Kubernetes ────────────────────────────────────────
  ui_step "DevOps — Kubernetes..."
  brew_install "kubectl"         "kubectl"
  brew_install "kubectx"         "kubectx + kubens"
  brew_install "helm"            "Helm (package manager K8s)"
  brew_install "k9s"             "k9s (TUI para K8s)"
  brew_install "k3d"             "k3d (K3s en Docker)"
  brew_install "kind"            "kind (K8s en Docker)"
  brew_install "minikube"        "Minikube"
  brew_install "kustomize"       "Kustomize"
  brew_install "flux"            "Flux (GitOps)"
  brew_install "argocd"          "ArgoCD CLI"
  brew_install "skaffold"        "Skaffold"
  brew_install "tilt"            "Tilt (dev con K8s)"
  brew_install "stern"           "Stern (multi-pod log tailer)"
  brew_install "kubecolor"       "kubecolor (kubectl con colores)"

  # ── DevOps: IaC ───────────────────────────────────────────────
  ui_step "DevOps — Infrastructure as Code..."
  # Terraform: desde Aug 2023 (licencia BSL) requiere el tap oficial HashiCorp
  brew tap "hashicorp/tap" >> "${LOG_FILE}" 2>&1 || true
  brew_install "hashicorp/tap/terraform"  "Terraform"

  brew_install "terragrunt"               "Terragrunt"

  # OpenTofu: fork OSS de Terraform (licencia MPL, compatible con brew-core)
  brew tap "opentofu/tap" >> "${LOG_FILE}" 2>&1 || true
  brew_install "opentofu/tap/opentofu"    "OpenTofu (fork OSS de Terraform)"
  brew_install "pulumi"          "Pulumi"
  brew_install "ansible"         "Ansible"
  brew_install "packer"          "Packer"

  # ── DevOps: Cloud CLIs ────────────────────────────────────────
  ui_step "DevOps — Cloud CLIs..."
  brew_install "awscli"          "AWS CLI"
  brew_install "azure-cli"       "Azure CLI"
  brew_install "google-cloud-sdk" "Google Cloud SDK"
  brew_install "doctl"           "DigitalOcean CLI"
  brew_install "flyctl"          "Fly.io CLI"
  npm_global_install "vercel"    "Vercel CLI"
  npm_global_install "netlify-cli"  "Netlify CLI"
  npm_global_install "wrangler"  "Cloudflare Wrangler"

  # ── DevOps: Monitoreo y observabilidad ───────────────────────
  ui_step "DevOps — observabilidad..."
  brew_install "prometheus"      "Prometheus"
  brew_install "grafana"         "Grafana"
  brew_install "vector"          "Vector (pipeline de logs)"
  brew_install "loki"            "Loki" 2>/dev/null || true

  # ── Bases de datos ────────────────────────────────────────────
  ui_step "Databases..."
  brew tap "mongodb/brew"        >> "${LOG_FILE}" 2>&1 || true

  brew_install "postgresql@16"   "PostgreSQL 16"
  brew_install "mysql"           "MySQL"
  brew_install "redis"           "Redis"
  brew_install "sqlite"          "SQLite"
  brew_install "mongodb-community" "MongoDB Community"
  brew_install "mongosh"         "MongoDB Shell"
  brew_install "influxdb"        "InfluxDB"

  # ── Message queues ────────────────────────────────────────────
  ui_step "Message queues..."
  brew_install "kafka"           "Apache Kafka"
  brew_install "rabbitmq"        "RabbitMQ"
  brew_install "nats-server"     "NATS Server"

  # ── API: gRPC / GraphQL / REST ────────────────────────────────
  ui_step "API tools (gRPC, GraphQL, REST)..."
  brew_install "grpc"            "gRPC"
  brew_install "protobuf"        "Protocol Buffers"
  brew_install "buf"             "Buf (protobuf toolchain)"
  brew_install "grpcurl"         "grpcurl (curl para gRPC)"
  brew_install "evans"           "Evans (gRPC REPL)"

  # ── Seguridad ─────────────────────────────────────────────────
  ui_step "Security tools..."
  brew_install "nmap"            "nmap"
  brew_install "trivy"           "Trivy (scanner de vulnerabilidades)"
  brew_install "grype"           "Grype (scanner de CVEs)"
  brew_install "syft"            "Syft (SBOM generator)"
  brew_install "trufflehog"      "TruffleHog (detección de secretos)"
  brew_install "gitleaks"        "Gitleaks (secretos en git)"
  brew_install "semgrep"         "Semgrep (análisis estático)"
  brew_install "nuclei"          "Nuclei (scanner de vulnerabilidades web)"
  brew_install "sqlmap"          "sqlmap (SQL injection)" 2>/dev/null || true

  # ── Load testing ──────────────────────────────────────────────
  ui_step "Load testing..."
  brew_install "k6"              "k6"
  brew_install "vegeta"          "Vegeta"
  brew_install "wrk"             "wrk"
  npm_global_install "autocannon" "autocannon"

  # ── CI/CD local ───────────────────────────────────────────────
  ui_step "CI/CD local tools..."
  brew_install "act"             "act (GitHub Actions local)"
  brew_install "circleci"        "CircleCI CLI"
  npm_global_install "concurrently" "concurrently"

  ui_success "Frameworks & DevOps listos ✓"
}
