## Summary / Resumen

<!-- EN: What does this PR do? One or two sentences.
     ES: ¿Qué hace este PR? Una o dos oraciones. -->

## Type of change / Tipo de cambio

- [ ] New tool added to existing module / Nueva herramienta añadida a módulo existente
- [ ] New module / Nuevo módulo
- [ ] Bug fix / Corrección de bug
- [ ] Refactor / cleanup
- [ ] Linux/platform support / Soporte de Linux/plataforma
- [ ] Documentation / Documentación
- [ ] CI / infrastructure

## Module(s) affected / Módulo(s) afectado(s)

<!-- e.g. modules/ai.sh, modules/core.sh -->

## Related issues / Issues relacionados

Closes #

## Changes / Cambios

-
-

## Checklist / Lista de verificación

- [ ] `shellcheck modules/*.sh lib/*.sh install.sh` — zero errors / sin errores
- [ ] Tool is idempotent — checks before installing / La herramienta es idempotente — comprueba antes de instalar
- [ ] Tested on macOS / Probado en macOS
- [ ] Tested on Linux (if applicable) / Probado en Linux (si aplica)
- [ ] README updated (if new tool/module) / README actualizado (si es herramienta/módulo nuevo)
- [ ] Follows `brew_install` / `run_task` helpers pattern
- [ ] No hardcoded paths — uses `$HOME`, `$HOMEBREW_PREFIX`
