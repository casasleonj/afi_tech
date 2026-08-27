# Handoff — Implementación de la arquitectura de contexto ligera (2026-08-27)

**Agente:** Claude Code (claude-sonnet-5)
**Fecha (UTC):** 2026-08-27
**Idioma:** cuerpo ES, claves de campo EN (CONVENTIONS.md, PROTOCOL.md §15)

## Task
Implementar la arquitectura de contexto acordada para afi_tech: dejar
funcionando un sistema simple y robusto de continuidad entre Hermes, Claude
Code, OpenCode y Codex. Restricciones: no crear TASKS.md/ADRs/MCP/locks/
worktrees/scripts de enforcement; no tocar código de aplicación; no instalar
dependencias; no hacer commit; no borrar evidencia de investigación.

## Result
Cambios aplicados (working tree, sin commit):
- `AGENTS.md` reescrito como bootstrap pequeño (~55 líneas): misión, roles +
  ownership, checklist de arranque, reglas no negociables, criterio de
  completitud. Todo el detalle metodológico que antes duplicaba se delega a
  `PROTOCOL.md`, que queda como única fuente.
- `.context/PROTOCOL.md`: se conserva la expansión previa §§1–20 (ya sin
  commit desde antes de esta sesión). Añadidos: nota en §1 de que es referencia
  por sección, no lectura obligatoria completa; §15 reescrito al modelo
  "handoff = archivo dated inmutable, `latest.md` = puntero"; referencias a
  `.context/decisions/` sustituidas por `DECISIONS.md` / handoff dated (§15,
  §18), ya que no habrá directorio de ADRs.
- `.context/STATE.md`: separado estado durable de efímero. Eliminados los
  hechos runtime no verificables ("Codex rate-limited", "OpenCode/Claude Code
  operational", "GitHub SSH verified", "main pushed"). Añadida sección "Out of
  scope for this file" que prohíbe esos hechos aquí y los manda al handoff.
- `.context/CONVENTIONS.md`: añadidas convenciones mínimas de idioma (claves EN
  / cuerpo ES), nombres de handoff (`YYYY-MM-DD_<agent>-<slug>.md`,
  inmutables), rol de `latest.md` como puntero, y ownership (Hermes = snapshot
  mutable; workers = archivos inmutables nuevos).
- `.context/DECISIONS.md`: añadida entrada "Lightweight context architecture
  (2026-08-27)" con alcance y lista explícita de lo rechazado por ahora
  (TASKS.md plural, ADRs, MCP, locks, worktrees, enforcement), con enlace al
  research.
- `.context/TASK.md`: añadida sección "Status" (estructura en pie, validación
  multi-agente pendiente).
- `.context/handoffs/latest.md`: reconstruido como puntero válido al handoff
  más reciente + lista de handoffs recientes.
- `.context/handoffs/2026-08-27_claude-context-architecture.md`: este archivo.
- `.gitignore` (nuevo, mínimo): secretos/env locales, temporales de OS/editor,
  `.obsidian/`.
- `CLAUDE.md`: symlink a `AGENTS.md` (symlinks soportados en este entorno
  Linux; git `core.symlinks` por defecto = true).
- Eliminado el directorio vacío `.context/decisions/` (no rastreado, sin
  contenido) para quitar la ambigüedad `DECISIONS.md` archivo vs. directorio.

No se tocó código de aplicación (no hay), no se instalaron dependencias, no se
hizo commit. `.context/research/` y el handoff histórico de OpenCode intactos.

## Decisions
- Ver `DECISIONS.md` → "Lightweight context architecture (2026-08-27)".
- `latest.md` como puntero (no como copia del handoff): evita el fallo
  "stale but trusted" observado cuando OpenCode no pudo tocarlo. Alternativa
  symlink descartada por fragilidad multiplataforma; un puntero de texto es
  legible por cualquier agente y genera conflictos triviales.
- `CLAUDE.md` como symlink (lo pedido explícitamente "si es seguro"): verificado
  que el entorno es Linux con symlinks funcionales. Alternativa portable si
  algún día se checkoutea en Windows: reemplazar por un archivo de una línea
  `Ver AGENTS.md`.
- La expansión sin commit de `PROTOCOL.md` se trata como intencional (diff
  coherente que añade §§3–20; el research de OpenCode y el de Claude así lo
  infieren) y se conserva; no se revierte.
- No se promovió la investigación a `knowledge/` ni se creó índice de research:
  fuera del alcance acordado (evitar sobrearquitectura).

## Files changed
Modificados: `AGENTS.md`, `.context/PROTOCOL.md`, `.context/STATE.md`,
`.context/CONVENTIONS.md`, `.context/DECISIONS.md`, `.context/TASK.md`,
`.context/handoffs/latest.md`.
Nuevos: `.gitignore`, `CLAUDE.md` (symlink → `AGENTS.md`),
`.context/handoffs/2026-08-27_claude-context-architecture.md`.
Eliminado: `.context/decisions/` (directorio vacío no rastreado).
Intactos: `.context/research/context-layer-architecture-claude.md`,
`.context/handoffs/2026-08-27_opencode-prueba-comunicacion.md`, `README.md`.

## Verification
Hechos verificados (observación directa 2026-08-27):
- Lectura previa completa de `AGENTS.md`, `.context/PROTOCOL.md` (versión
  working, 396→~404 líneas), `STATE.md`, `TASK.md`, `DECISIONS.md`,
  `CONVENTIONS.md`, ambos handoffs y el research completo antes de editar.
- `git status` inicial: `M .context/PROTOCOL.md`, `?? handoffs/2026-08-27_
  opencode-...`, `?? .context/research/`. HEAD `02e0970`.
- Soporte de symlink comprobado creando un symlink de prueba en el scratchpad
  (`ln -s` → `lrwxrwxrwx`); `git config core.symlinks` sin valor explícito
  (default true en Linux).
- Grep de `decisions/` en `PROTOCOL.md`: 2 referencias, ambas corregidas.
- Post-edición: `git status`, `git diff` y `git diff --staged` revisados;
  `git check-ignore` probado contra `.env`, `foo.tmp`, `.obsidian/x`;
  `ls -la CLAUDE.md` confirma symlink a `AGENTS.md` y `cat CLAUDE.md` resuelve
  al contenido de `AGENTS.md`; `git ls-files --others` confirma que `CLAUDE.md`
  se registraría como symlink (modo 120000).

Revisión crítica (PROTOCOL §11) — hallazgos corregidos:
1. Primer borrador de `AGENTS.md` perdía la jerarquía de fuente de verdad →
   reincorporada como lista de 6.
2. `STATE.md` seguía nombrando "MCP: future integration layer" → eliminado por
   coherencia con lo rechazado en `DECISIONS.md`.
3. `PROTOCOL.md §15` contradecía el modelo de puntero → reescrito.
4. Referencias colgantes a `.context/decisions/` tras borrar el directorio →
   sustituidas.

Inferencias / no verificado:
- *Inferencia:* la expansión de `PROTOCOL.md` es intencional, no corrupción.
- *No verificado:* qué archivo auto-carga cada CLI (Claude Code, OpenCode,
  Codex) al arrancar. `CLAUDE.md` cubre Claude Code; OpenCode/Codex sin
  confirmar. Requiere verificación del usuario por herramienta y versión.
- *No verificado:* naturaleza exacta de "Hermes" (humano / agente / script) y
  el flujo git real de los workers (clones, worktrees, ramas).

## Risks/problems
- **Sin enforcement:** por decisión, no hay lint/hook. La consistencia
  AGENTS.md ↔ PROTOCOL.md y el cumplimiento de §15 dependen de la disciplina de
  cada agente. Aceptado como trade-off para no sobrearquitectar.
- **Divergencia repo ↔ contexto:** tras estos cambios el working tree diverge
  aún más de `origin/main`. `latest.md` lo declara explícitamente. Hasta que
  Hermes commitee, un agente que arranque debe hacer `git status` (regla ya en
  AGENTS.md / PROTOCOL §3).
- **Symlink `CLAUDE.md`:** seguro en este entorno; se romper­ía en un checkout
  Windows sin `core.symlinks`. Mitigación documentada arriba.
- **Auto-carga por herramienta no verificada** (ver Inferencias): si OpenCode o
  Codex no leen `AGENTS.md` por defecto, el contrato no está activo para ellos.
- **`.gitignore` `*.local` y `.env.*`:** amplios a propósito; `!.env.example`
  preserva plantillas. Si aparece un archivo legítimo con esos patrones habrá
  que exceptuarlo.

## Remaining work
- Hermes: revisar `git diff` / `git status` y commitear (sugerido separar:
  `docs: complete protocol §§3-20` para la expansión pre-existente de
  PROTOCOL.md, y `docs: adopt lightweight context architecture` para el resto)
  o pedir ajustes.
- Verificar, por CLI y versión, qué ruta de contexto auto-carga cada agente;
  añadir shims equivalentes a `CLAUDE.md` si hace falta (o convertir el symlink
  en stub de una línea si se busca portabilidad Windows).
- Ejecutar un ciclo real de handoff multi-agente para validar la estructura
  antes de considerar Obsidian u otra capa.
- Confirmar la naturaleza de "Hermes" y el flujo git de los workers; ajustar la
  sección Ownership de `CONVENTIONS.md` si el modelo real difiere.

## Recommended next step
Hermes revisa el diff completo (`git diff && git status && ls -la CLAUDE.md`),
decide el commit (o ajustes), y luego coordina una tarea pequeña real que pase
por OpenCode y Codex para ejercitar el bootstrap y el ciclo de handoff.
