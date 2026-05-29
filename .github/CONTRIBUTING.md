# Contributing to DevForge

> 🇪🇸 [Versión en Español](#-contribuyendo-a-devforge) below

---

## 🤝 Contributing to DevForge

### How to Contribute

1. **Report bugs** → [Bug report](https://github.com/klosraf/devforge/issues/new?template=bug_report.yml)
2. **Request features** → [Feature request](https://github.com/klosraf/devforge/issues/new?template=feature_request.yml)
3. **Request a new module** → [Module request](https://github.com/klosraf/devforge/issues/new?template=module_request.yml)
4. **Add a tool** → [Tool request](https://github.com/klosraf/devforge/issues/new?template=tool_request.yml)
5. **Browse issues** → [Open issues](https://github.com/klosraf/devforge/issues)

Issues labeled `good first issue` are great starting points.

### Development Setup

```bash
git clone https://github.com/YOUR_USERNAME/devforge.git
cd devforge

# Validate shell scripts
shellcheck modules/*.sh lib/*.sh install.sh

# Test a specific module (dry-run)
./install.sh --modules core --dry-run
```

### Branching Strategy

| Branch | Purpose |
|---|---|
| `main` | Stable, release-ready |
| `develop` | Integration branch |
| `feat/*` | New module/tool additions |
| `fix/*` | Bug fixes |
| `docs/*` | Documentation only |
| `chore/*` | CI, refactoring, deps |

### Commit Convention

```
feat(module): add tool-name to module
fix(core): handle macOS 15 Sequoia brew path
docs(readme): update ai module table
chore(ci): add shellcheck to workflow
```

**Types:** `feat` · `fix` · `docs` · `refactor` · `test` · `chore`
**Scopes:** `core` · `languages` · `frameworks` · `editors` · `terminal` · `macos` · `apps` · `ai` · `dotfiles` · `ios` · `android` · `ci`

### Adding a Tool to an Existing Module

1. Find the relevant module in `modules/`
2. Add using `brew_install`, `npm_global_install`, or `cargo_install`
3. Follow the existing style (version check + idempotency guard)
4. Run `shellcheck` on the modified file
5. Test: `./install.sh --modules <module_name>`

```bash
# Example: adding a brew tool to core.sh
brew_install "dust" "dust"          # brew formula, display name
brew_install "bottom" "btm"         # formula name can differ from command

# npm global tool
npm_global_install "tool-name"

# cargo tool
cargo_install "tool-name"
```

### Adding a New Module

1. Create `modules/my_module.sh` following the existing pattern
2. Add module to `install.sh` module list
3. Add module description to `lib/lang.sh` (EN + ES)
4. Test: `./install.sh --modules my_module`
5. Update README module table

### Code Style

- Use `brew_install` / `run_task` helpers — never raw `brew install`
- Add version/existence checks: `command -v tool &>/dev/null`
- Keep modules idempotent: always check before installing
- No hardcoded paths: use `$HOME`, `$HOMEBREW_PREFIX`
- Validate with `shellcheck` — zero warnings

### Pull Request Process

1. Branch off `develop`
2. Run `shellcheck` — no errors
3. Test the modified module(s) on a real macOS/Linux system
4. Fill out the PR template completely
5. Link the related issue (`Closes #123`)

---
---

## 🤝 Contribuyendo a DevForge

### Cómo contribuir

1. **Reportar bugs** → [Reporte de bug](https://github.com/klosraf/devforge/issues/new?template=bug_report.yml)
2. **Solicitar funciones** → [Solicitud de función](https://github.com/klosraf/devforge/issues/new?template=feature_request.yml)
3. **Solicitar un nuevo módulo** → [Solicitud de módulo](https://github.com/klosraf/devforge/issues/new?template=module_request.yml)
4. **Añadir una herramienta** → [Solicitud de herramienta](https://github.com/klosraf/devforge/issues/new?template=tool_request.yml)
5. **Explorar issues** → [Issues abiertos](https://github.com/klosraf/devforge/issues)

### Configuración de desarrollo

```bash
git clone https://github.com/TU_USUARIO/devforge.git
cd devforge

# Validar scripts de shell
shellcheck modules/*.sh lib/*.sh install.sh

# Probar un módulo específico (dry-run)
./install.sh --modules core --dry-run
```

### Convención de commits

```
feat(módulo): añadir nombre-herramienta al módulo
fix(core): manejar ruta brew de macOS 15 Sequoia
docs(readme): actualizar tabla del módulo ai
chore(ci): añadir shellcheck al workflow
```

### Añadir una herramienta a un módulo existente

1. Encuentra el módulo relevante en `modules/`
2. Añade usando `brew_install`, `npm_global_install` o `cargo_install`
3. Sigue el estilo existente (comprobación de versión + guardia de idempotencia)
4. Ejecuta `shellcheck` en el archivo modificado
5. Prueba: `./install.sh --modules <nombre_módulo>`

### Estilo de código

- Usa los helpers `brew_install` / `run_task` — nunca `brew install` directo
- Añade comprobaciones de versión/existencia: `command -v tool &>/dev/null`
- Mantén los módulos idempotentes: siempre comprueba antes de instalar
- Sin rutas hardcodeadas: usa `$HOME`, `$HOMEBREW_PREFIX`
- Valida con `shellcheck` — cero advertencias
