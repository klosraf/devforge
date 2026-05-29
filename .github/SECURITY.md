# Security Policy / Política de Seguridad

> 🇪🇸 [Versión en Español](#política-de-seguridad) below

---

## Security Policy

### Supported Versions

| Version | Supported |
|---|---|
| Latest (`main`) | ✅ Active |
| Previous minor | ⚠️ Critical fixes only |

### Reporting a Vulnerability

**Do NOT open a public GitHub issue for security vulnerabilities.**

DevForge installs software and modifies system configuration. A vulnerability could lead to unintended software installation, privilege escalation, or data exposure on users' machines.

#### How to report

1. Go to [Security Advisories](https://github.com/klosraf/devforge/security/advisories/new)
2. Click **"Report a vulnerability"**
3. Include: description, affected module/function, reproduction steps, potential impact

Or email **sr.klosraf@gmail.com** with subject `[SECURITY] devforge — <brief description>`.

#### Our commitment

- Acknowledge within **48 hours**
- Confirm validity within **7 days**
- Release a fix within **30 days** for critical, **90 days** for others

### Security considerations for users

- **Always review `install.sh`** before piping to bash
- **Prefer cloning** over `curl | bash` for production machines
- DevForge installs software from Homebrew, npm, cargo — verify these sources
- API keys and secrets are managed by `age`/`sops` — never stored in plain text

---
---

## Política de Seguridad

### Versiones soportadas

| Versión | Soportada |
|---|---|
| Última (`main`) | ✅ Activa |
| Minor anterior | ⚠️ Solo correcciones críticas |

### Reportar una vulnerabilidad

**No abras un issue público de GitHub para vulnerabilidades de seguridad.**

Envía un email a **sr.klosraf@gmail.com** con el asunto `[SECURITY] devforge — <descripción breve>` o usa los [Avisos de Seguridad](https://github.com/klosraf/devforge/security/advisories/new) de GitHub.

### Consideraciones de seguridad para usuarios

- **Siempre revisa `install.sh`** antes de hacer pipe a bash
- **Prefiere clonar** en lugar de `curl | bash` en máquinas de producción
- DevForge instala software de Homebrew, npm, cargo — verifica estas fuentes
