# Arquitectura de contexto por capas — afi_tech

**Fecha:** 2026-08-27
**Alcance:** análisis y diseño. No se modificó ningún archivo. No se leyeron análisis de otros agentes (`.context/research/` no fue abierto; el handoff de prueba de OpenCode se leyó porque es contexto operativo, no un análisis de esta misma tarea).
**Método:** lectura directa de `AGENTS.md`, `.context/PROTOCOL.md`, `.context/STATE.md`, `.context/TASK.md`, `.context/DECISIONS.md`, `.context/CONVENTIONS.md`, `.context/handoffs/latest.md`, `.context/handoffs/2026-08-27_opencode-prueba-comunicacion.md`, `README.md`.

Clasificación usada en todo el documento:
- **[HECHO]** — observado directamente en esta sesión.
- **[INFERENCIA]** — deducción a partir de hechos, no verificada.
- **[RECOMENDACIÓN]** — propuesta de diseño.
- **[INCERTIDUMBRE]** — no verificable en este entorno; requiere acción externa o del usuario.

---

## 1. Estado verificado del sistema actual

### 1.1 Inventario

**[HECHO]** Estructura existente:

| Archivo | Rol declarado | Tamaño aprox. | Volatilidad real |
|---|---|---|---|
| `AGENTS.md` (raíz) | Contrato de agente | ~3.9 KB / 85 líneas | Baja |
| `.context/PROTOCOL.md` | Metodología detallada | ~15.6 KB / 396 líneas | Baja (pero **modificado sin commit**) |
| `.context/STATE.md` | Estado actual | ~0.8 KB | **Alta** (mezcla durable + runtime) |
| `.context/TASK.md` | Tarea activa (singular) | ~0.8 KB | Alta |
| `.context/DECISIONS.md` | Decisiones (archivo único mutable) | ~0.75 KB | Media, crece |
| `.context/CONVENTIONS.md` | Convenciones | ~0.5 KB | Baja |
| `.context/handoffs/latest.md` | Último handoff (archivo único mutable) | ~0.47 KB | Alta |
| `.context/handoffs/2026-08-27_opencode-...md` | Handoff de prueba (untracked) | — | Inmutable |
| `.context/research/` | Investigación/evidencia | untracked, contenido no inspeccionado | — |

**[HECHO]** `git status`: `M .context/PROTOCOL.md`, `?? .context/handoffs/2026-08-27_opencode-prueba-comunicacion.md`, `?? .context/research/`. Rama `main`, 2 commits (`02e0970`, `e9ba9b5`). No hay `.gitignore` en la raíz.

**[HECHO]** No hay código de aplicación en el repo (solo `README.md` de 3 líneas). **[INFERENCIA]** El proyecto está en fase "meta": se está construyendo el propio sistema de colaboración antes que el producto.

**[INFERENCIA]** "Hermes" es el orquestador; Claude Code / OpenCode / Codex son workers CLI. `AGENTS.md:10` confirma **[HECHO]** que los agentes no heredan la conversación de otro salvo que se les entregue explícitamente.

### 1.2 Contradicciones y fallos detectados en el diseño actual

**C1 — Duplicación `AGENTS.md` ↔ `PROTOCOL.md`. [HECHO]**
`AGENTS.md` reexpresa de forma comprimida ~8 de los 20 apartados de `PROTOCOL.md` (verdad/evidencia, verificación técnica, investigación, iteración crítica, convergencia, trazabilidad, handoffs, seguridad). Son dos documentos con las mismas reglas.
- Riesgo: divergencia silenciosa al editar uno y no el otro.
- Ambigüedad no resuelta: en caso de conflicto, ¿cuál manda? No está escrito.

**C2 — ¿`PROTOCOL.md` se lee siempre o es referencia? [HECHO] Contradicción.**
`PROTOCOL.md §16` enumera el bootstrap obligatorio: `STATE / TASK / DECISIONS / CONVENTIONS / handoffs/latest.md` — **no incluye `PROTOCOL.md`**. Pero `AGENTS.md` §Context dice "Use `.context/PROTOCOL.md` for the detailed collaboration and verification method", y §11/§20 exigen la metodología para "trabajo significativo". Resultado: cada agente decide si carga 15.6 KB (~4K tokens) o no. Si no lo hace, no sigue el protocolo; si lo hace siempre, es el mayor gasto fijo del sistema.

**C3 — `handoffs/latest.md`: archivo único mutable. [HECHO]**
- La prueba de OpenCode creó un archivo aparte y **no** tocó `latest.md` (por la restricción "no modificar"). Ahora `latest.md` está **obsoleto**: sigue describiendo el establecimiento inicial del protocolo, no la actividad más reciente. Es exactamente el fallo "stale but trusted" que `PROTOCOL §16` declara "más dañino que el contexto ausente".
- `latest.md` cumple **5 de 8** campos de `PROTOCOL §15` (faltan Decisions, Files changed, Risks/problems). **El propio dato semilla viola el protocolo.**
- Un archivo mutable de un solo escritor no soporta concurrencia ni escenarios de solo-lectura.

**C4 — `STATE.md` mezcla durable con runtime. [HECHO]**
`STATE.md` contiene tanto arquitectura estable ("AGENTS.md: concise contract", fases) como hechos volátiles y no verificables por un lector ("Codex authenticated but currently rate-limited", "OpenCode operational"). Esos hechos caducan en horas y ningún agente que lea el archivo puede verificarlos. Contamina la confianza en todo el archivo y fuerza reescrituras frecuentes de contenido que debería ser estable.

**C5 — Divergencia repo ↔ contexto ya presente hoy. [HECHO]**
`STATE.md` afirma "Repository initialized and **main pushed**", pero `PROTOCOL.md` está modificado sin commit. Un agente que confíe en `STATE.md` asumirá que el árbol de trabajo coincide con `origin/main`. Es el caso de fallo que `PROTOCOL §3` pide detectar, pero no hay metadato que lo haga barato de detectar.

**C6 — Sin modelo de ownership ni concurrencia. [HECHO]**
Ni `AGENTS.md` ni `PROTOCOL.md` mencionan concurrencia, locks, propiedad de archivos, o "reclamar una tarea". Cuatro agentes pueden editar `STATE.md` / `DECISIONS.md` / `latest.md` en paralelo con git como único mecanismo de merge. `DECISIONS.md` y `STATE.md` son de estilo "append/rewrite en archivo único" → conflicto garantizado en trabajo paralelo, con riesgo de decisión perdida en una resolución de conflicto descuidada.

**C7 — `TASK.md` es singular. [HECHO]**
"Active Task" (una). Cuatro agentes, un archivo. No representa workstreams paralelos ni asignación por agente. **[INFERENCIA]** implica serialización por Hermes, pero esa restricción no está declarada.

**C8 — `.context/decisions/` vs `DECISIONS.md`: ¿archivo o directorio? [HECHO] Contradicción.**
`PROTOCOL §14` y §15 dicen "Record ... in DECISIONS.md" y "Link to `.context/research/` or `.context/decisions/`". Se implican ambos patrones (archivo único mutable y directorio de registros). No está resuelto. `[INCERTIDUMBRE]` no pude confirmar si `.context/decisions/` existe.

**C9 — `research/` sin índice ni esquema. [HECHO]**
`PROTOCOL §17` dice "no copiar investigación al prompt; referenciarla". Pero no hay `research/INDEX.md`, ni convención de nombres, ni frontmatter. Un agente no sabe qué hay en `research/` sin listar y abrir archivos → coste de tokens no acotado, o se salta la carpeta y pierde evidencia. Escala mal.

**C10 — Independencia (§12) vs. mecanismo compartido. [HECHO] Tensión estructural.**
El directorio que habilita la convergencia (`research/` compartido) es también el vector de contaminación de la independencia. No hay convención que separe "borrador independiente — no leer todavía" de "convergido — citable". El layout de directorios no codifica el estado de ciclo de vida de un análisis. Esta misma tarea depende de que el humano no me pase los análisis de otros — no de ningún control del sistema.

**C11 — Capa Obsidian / MCP nombrada sin interfaz. [HECHO]**
`STATE.md` y `DECISIONS.md` listan Obsidian ("future durable knowledge layer") y MCP ("future integration layer") sin definir qué problema resuelve cada uno ni su frontera con `.context/research/`. Nombrar un componente futuro sin frontera invita acoplamiento prematuro y triple almacenamiento (research/ + vault + git).

**C12 — Protocolo largo, prescriptivo, sin ninguna aplicación automática. [HECHO]**
`PROTOCOL §1` reconoce que no es un control de seguridad. Pero tampoco hay lint, plantilla, hook ni CI. Depender de 4 agentes LLM heterogéneos para aplicar consistentemente una metodología de 396 líneas de memoria, cada sesión, es de alta varianza. La evidencia semilla (C3, C5) ya lo demuestra con 2 commits.

**C13 — Idioma de los handoffs no decidido. [HECHO]**
El handoff de OpenCode mantuvo los títulos de campo §15 en EN y el cuerpo en ES "por trazabilidad", y lo anota como ambigüedad. Sin decisión registrada, cada agente lo re-decide.

**C14 — `AGENTS.md` "read the minimum" vs §16 "lee estos 5 siempre". [HECHO]** Tensión menor: para una tarea trivial, leer los 5 no es el mínimo.

**C15 — Sin política de retención / GC. [HECHO]** `handoffs/` y `research/` crecen sin límite. `PROTOCOL §18` menciona "mover material" pero sin disparador, calendario ni responsable.

---

## 2. Incertidumbres que condicionan el diseño

**[INCERTIDUMBRE] U1 — Auto-carga por herramienta.** Qué archivo carga automáticamente cada agente al arrancar (`AGENTS.md`, `CLAUDE.md`, ninguno) no es verificable en este entorno (sin acceso web, sin poder ejecutar esos CLIs). Es *load-bearing* para "bootstrap mínimo": si un agente no auto-carga `AGENTS.md`, el contrato no está activo para él. **Acción requerida:** el usuario debe confirmar, para cada CLI y su versión instalada, qué ruta(s) de contexto lee por defecto.

**[INCERTIDUMBRE] U2 — Qué es "Hermes".** ¿Humano, agente, o script de orquestación? Determina el modelo de ownership (¿puede Hermes hacer commits y merges? ¿es un cuello de botella fiable?).

**[INCERTIDUMBRE] U3 — Flujo git real de los workers.** ¿Clonan el mismo working tree, worktrees separados, ramas por agente? El comportamiento de merge de `.context/` depende de esto.

**[INCERTIDUMBRE] U4 — Contenido de `.context/research/`.** No inspeccionado (directorio; y la tarea prohíbe usar análisis de otros). Se asume que puede estar vacío o a punto de recibir este archivo.

**[INCERTIDUMBRE] U5 — Conteos de tokens.** Todas las cifras de tokens son inferencia desde bytes (~3.5–4 caracteres/token para Markdown en inglés; el ES y el código varían). No medidas.

**[INCERTIDUMBRE] U6 — Precedentes de industria.** En este entorno no hay búsqueda web ni acceso a documentación actual. Los precedentes citados en §5 provienen de conocimiento de entrenamiento y **no** se re-verificaron contra documentación vigente en esta sesión. Trátense como "patrón comúnmente reportado", no como "verificado hoy". Esto es una limitación respecto a `AGENTS.md` §Research y `PROTOCOL §9`.

---

## 3. Arquitectura propuesta — capas por frecuencia de lectura y volatilidad

Principio rector: **el coste de tokens lo domina lo que se lee cada sesión, no el número de archivos.** Muchos archivos pequeños que casi nunca se leen cuestan ~0. Por tanto: minimizar la lectura obligatoria, hacer todo lo demás carga bajo demanda, y acotar cada directorio con un índice para que "bajo demanda" nunca signifique "escanear todo".

Segundo principio: **inmutable + append-only para los workers; snapshots mutables solo para el orquestador o vía disciplina de "añade tu propia línea".** El fallo más caro identificado (C3, C5, C6) es el snapshot mutable multi-escritor.

### Capa 0 — Bootstrap (siempre en contexto, ~diminuto, casi inmutable)

**[RECOMENDACIÓN]**
- **Un solo archivo: `AGENTS.md` en la raíz.** Objetivo ≤ ~45 líneas / ~500 tokens.
- Contenido exclusivo:
  1. Misión (1 línea).
  2. Roster de agentes + quién orquesta + "no heredas conversaciones ajenas".
  3. **Checklist de arranque**: qué leer y *cuándo* profundizar (enumerado, ver Capa 1).
  4. Las **reglas no negociables** en forma de una línea cada una: no fabricar hechos/fuentes/APIs/resultados; verificar contra el repo el contexto *load-bearing*; jerarquía de fuente de verdad (6 bullets); nunca persistir secretos; no reescribir historia git.
  5. Puntero: "Metodología completa y obligatoria para trabajo significativo → `.context/PROTOCOL.md` (leer por sección, no entero)".
- **Todo lo demás de `AGENTS.md` actual se mueve a `PROTOCOL.md`.** Las líneas-resumen que queden en `AGENTS.md` se marcan como *derivadas de PROTOCOL.md*; **`PROTOCOL.md` es la única fuente**, `AGENTS.md` es resumen + mínimo activable. Elimina la pregunta "¿cuál manda?" (C1).
- **Shims por herramienta:** si un CLI no auto-carga `AGENTS.md` (U1), crear `CLAUDE.md` (u otro) de **una línea**: `Ver AGENTS.md y .context/`. Preferible a symlink por portabilidad. Verificar por herramienta.

Resuelve: C1, C2 (PROTOCOL pasa a ser referencia por sección explícitamente), C14.

### Capa 1 — Contexto operativo (se lee casi cada sesión, pequeño, volátil)

**[RECOMENDACIÓN]** Reemplazar el conjunto actual por:

| Archivo | Contenido | Quién escribe |
|---|---|---|
| `STATE.md` | **Solo durable**: forma del proyecto, arquitectura, fase, objetivo actual. Cambia rara vez. | Orquestador |
| `TASKS.md` | Lista de tareas (no singular). Cada entrada: `id, título, owner, estado, rama/worktree, iniciada, último-commit-tocado`. Si hoy Hermes serializa: regla explícita "máx. 1 en progreso". | Orquestador; worker actualiza su propia línea de estado |
| `CONVENTIONS.md` | Ampliado: convención de nombres de handoff, idioma (claves de campo EN, cuerpo ES), formato de ADR, formato de archivo de research, reglas de ownership, política de retención. | Orquestador |
| `handoffs/INDEX.md` | Log append-only, una línea por handoff (más reciente al final): `fecha · agente · slug · resumen 1 línea · próximo paso · commit`. | Cada agente añade su línea |

- **Hechos de runtime volátiles (disponibilidad de agente, rate limits): prohibidos en `STATE.md`.** Si hacen falta, van en el handoff (son point-in-time, con fecha), no en un archivo llamado "estado actual". Resuelve C4, C5.
- **Frontmatter obligatorio en cada archivo persistente** (todas las capas):
  ```
  ---
  updated_at_utc: 2026-08-27T14:30Z
  updated_by: claude-code
  repo_commit: 02e0970
  ---
  ```
  `repo_commit` = HEAD en el momento de escribir. Habilita el chequeo de obsolescencia barato (§4 de este doc).

Lectura obligatoria de arranque = `AGENTS.md` + `STATE.md` + `TASKS.md` + `CONVENTIONS.md` + cola de `handoffs/INDEX.md` + el/los handoff(s) más reciente(s) relevantes. **[INFERENCIA]** ~5–6 KB ≈ ~1.3–1.6K tokens (vs. ~7 KB / ~1.8K tokens hoy en tarea rutinaria; vs. ~22 KB / ~5.5K si hoy se añade PROTOCOL para trabajo significativo).

Resuelve: C4, C6 (parcial), C7, C13, C15 (define política).

### Capa 2 — Decisiones (registros inmutables, bajo demanda)

**[RECOMENDACIÓN]** Convertir `DECISIONS.md` (archivo único mutable) en **ADR** (Architecture Decision Records):
- `decisions/NNNN-titulo.md`, un archivo por decisión. Campos: `estado` (propuesta/aceptada/reemplazada-por-NNNN), fecha, deciden, contexto, **opciones consideradas**, decisión, consecuencias, enlaces a evidencia/research, **desacuerdo no resuelto** (preserva `PROTOCOL §14`).
- **Inmutable**: una ADR aceptada solo se edita para poner `estado: reemplazada por NNNN`. Trazabilidad muy superior a una lista mutable.
- `decisions/INDEX.md`: append-only, `id · título · estado · 1 línea`. Es lo que el agente lee primero; abre la ADR completa solo si es relevante.
- **Umbral** (evita el "consequential" ambiguo de `PROTOCOL §10`): se exige ADR si la decisión (a) cambia una interfaz/contrato, (b) es costosa de revertir, (c) fue disputada, o (d) un agente posterior podría razonablemente re-litigarla. Si no → una línea en `CONVENTIONS.md` o una nota en el handoff.

Resuelve: C8 (`decisions/` es directorio; `DECISIONS.md` desaparece), C6 (append-only, sin conflictos), traza.

### Capa 3 — Handoffs (log de eventos append-only; se lee el/los último(s))

**[RECOMENDACIÓN]**
- Handoffs **inmutables**, uno por unidad de trabajo significativa: `handoffs/YYYY-MM-DDThhmmZ_<agente>_<slug>.md`. Nunca se sobrescribe.
- **`latest` deja de ser un archivo con contenido.** Es la última línea de `handoffs/INDEX.md` (append-only). "Leer el último handoff" = leer la cola del INDEX + abrir el/los archivo(s) referenciado(s). Elimina el archivo mutable de un solo escritor y el problema de obsolescencia de C3.
- Por qué INDEX y no symlink: los symlinks son frágiles en algunos sistemas/herramientas/Windows; un INDEX append-only además genera conflictos triviales (dos adiciones → conservar ambas) en vez de reescrituras.
- Cada handoff: los 8 campos de `PROTOCOL §15` + `repo_commit` + **enlaces** (no copias) a `decisions/` y `research/`. Claves de campo en EN, cuerpo en ES (registrar en `CONVENTIONS.md`).
- **Retención distribuida**: quien escribe el handoff nº 21 mueve los nº 1–10 a `handoffs/archive/YYYY-QN/` y deja en INDEX una línea "ver archive". Sin calendario ni responsable central. Resuelve C15.
- El handoff es la **unidad de trazabilidad**: una conclusión debe reconstruirse desde él sin la conversación (`AGENTS.md` §Traceability — **[HECHO]** ya exigido).

Resuelve: C3, C6, C15.

### Capa 4 — Investigación y evidencia (bajo demanda, puede ser grande)

**[RECOMENDACIÓN]**
- `research/INDEX.md` **obligatorio**. Cada archivo registrado: `id · título · agente · fecha · estado · hallazgo 1 línea · repo_commit`.
- Nombres: `research/YYYY-MM-DD_<agente>_<slug>.md`.
- **`estado` en frontmatter codifica el ciclo de vida** (clave para C10):
  - `estado: borrador-independiente` + `contaminacion: no-leer-antes-de-converger` → los demás agentes **no deben** leerlo mientras hacen su propio pase independiente sobre la misma pregunta.
  - `estado: convergido` / `publicado` → citable con seguridad.
- `question_id` en frontmatter agrupa los análisis independientes de la misma pregunta, para que un pase de convergencia los encuentre.
- **Evidencia voluminosa** (logs, transcripciones, salidas de benchmark): en `research/evidence/<id>/`, enlazada, **nunca** inline en contexto operativo. Si puede contener datos sensibles de runtime → `research/evidence/` en `.gitignore` o scrubbing previo.
- Las citas de fuentes llevan la clasificación de `PROTOCOL §5`.

Resuelve: C9, C10 (parcial — ver limitación abajo).

### Capa 5 — Conocimiento durable / Obsidian (rara vez leído por agentes; humano)

**[RECOMENDACIÓN]** Decisión pendiente que hay que tomar: **¿Obsidian = vault separado o vista sobre el repo?**
- **Recomendado: vista sobre el repo.** Obsidian abre la carpeta del repo como vault (Obsidian es Markdown + `[[wikilinks]]` + grafo). Evita un segundo almacén y su problema de sincronización. Los `[[wikilinks]]` son texto plano inocuo para agentes no-Obsidian.
- **[INCERTIDUMBRE]** Si el usuario quiere un vault curado aparte (sync propio, plugins), es válido, pero entonces hay que definir qué se copia, en qué dirección, y quién es la fuente de verdad. Por defecto: no.
- **Frontera anti-duplicación (regla dura): cada hecho vive en exactamente una capa.**
  - `.context/` = operativo + decisiones + handoffs + research (para agentes, terso, alta rotación).
  - `knowledge/` (o `docs/`) = explicación destilada, durable, para humanos, organizada por Diátaxis (tutorial / how-to / referencia / explicación). Se escribe *después* de que la investigación converge; **cita** la ADR/research de origen, no repite su razonamiento.
  - Historia git = autoritativa para eventos de código/repo; nunca se duplica en prosa.
  - Capas inferiores **enlazan hacia arriba**; superiores **enlazan hacia abajo**. Cuando un research se destila en `knowledge/`, el research se marca `estado: reemplazado-por knowledge/x` pero se conserva como evidencia.

Resuelve: C11 (define frontera), duplicación triple.

---

## 4. Temas transversales

### 4.1 Ownership y concurrencia

**Alternativas [RECOMENDACIÓN + trade-offs]:**

| Opción | Pro | Contra |
|---|---|---|
| **A. Serialización por orquestador** — solo Hermes escribe snapshots mutables (`STATE`, `TASKS`, todos los `INDEX`); los workers solo proponen en su handoff | Cero conflictos, un escritor | Hermes es cuello de botella y SPOF; los handoffs deben ser ricos para que Hermes actúe |
| **B. Ownership por archivo (CODEOWNERS + convención)** — cada archivo/dir tiene rol dueño; los workers solo **crean archivos inmutables nuevos** (handoffs, research, borradores de ADR) | Los workers son append-only → casi sin conflictos; usa mecanismo git nativo | Requiere disciplina; no impide edición accidental sin hooks |
| **C. Worktree/rama por agente** — cada agente en su worktree; contexto y código se fusionan vía PR | Aislamiento fuerte, auditoría real, git nativo | Latencia de merge; `.context/` sigue necesitando política de merge |
| **D. Locks/leases** — `.context/locks/<archivo>.lock` con id de agente + TTL | Explícito | Los agentes LLM olvidan liberar; necesita TTL + robo tras expiración; frágil |

**Recomendación: combinar A + B + C.**
- Por defecto los workers son **append-only** (crean archivos inmutables → conflicto ~nulo).
- Los snapshots mutables (`STATE.md`, `TASKS.md`, `*/INDEX.md`) los edita el **orquestador**, o se actualizan con disciplina estricta de "añade tu propia línea" (nunca reescribir/reordenar el archivo entero → un conflicto es "dos adiciones" → resoluble conservando ambas).
- El trabajo de **código** va en **worktree/rama por agente**, fusionado vía PR (que también revisa los cambios de `.context/`).
- Materializar con un `CODEOWNERS` real + reglas en `CONVENTIONS.md`.

**Regla de estructura para todos los INDEX:** append-only, una línea por entrada, más reciente al final. Prohibido cualquier patrón que exija reescribir el archivo entero (re-ordenar, contador en cabecera).

Resuelve C6, C7.

### 4.2 Contexto obsoleto / detección de staleness

**[RECOMENDACIÓN]**
- Frontmatter con `repo_commit` en todo archivo persistente (§Capa 1).
- **Chequeo de integridad de arranque, versión barata** (concreta `PROTOCOL §3` que hoy es aspiracional):
  1. Por cada archivo de Capa 1, comparar su `repo_commit` con HEAD actual.
  2. Si iguales → confiar.
  3. Si distintos → `git diff --stat <repo_commit>..HEAD` acotado a rutas relevantes; verificación profunda **solo** si cambiaron archivos relevantes.
- **"Superseded" siempre explícito:** las ADR cambian de estado; los research reciben `reemplazado-por`; los handoffs nunca se reemplazan (log inmutable) pero el INDEX marca la cabeza actual.
- **Protocolo `⚠ STALE`:** si un agente halla una contradicción que no puede resolver, debe (a) no actuar sobre lo contradicho, (b) añadir una nota `⚠ STALE` con evidencia al archivo, (c) registrarlo en su handoff. Nunca arreglar en silencio ni seguir en silencio.
- **Remediación inmediata de la deuda actual** (backlog, no arquitectura):
  - Commitear o descartar `.context/PROTOCOL.md` para eliminar la divergencia `M` (C5).
  - Reconstruir `handoffs/latest.md` (→ `INDEX.md`) con la actividad real reciente, incluyendo la prueba de OpenCode (C3).
  - Decidir si `.context/research/` se versiona y con qué `.gitignore`.

Resuelve C5, C4, y hace verificable C6.

### 4.3 Eficiencia de tokens — presupuesto y honestidad

**[INFERENCIA]** (cifras derivadas de bytes, U5):

| Escenario | Hoy | Propuesto |
|---|---|---|
| Arranque tarea rutinaria | `AGENTS.md`(3.9K) + 5 archivos(≈3.4K) ≈ **7.3 KB ≈ ~1.8K tok** | `AGENTS.md` slim(1K) + `STATE`(0.8K) + `TASKS`(0.6K) + `CONVENTIONS`(1.2K) + cola INDEX(0.5K) + último handoff(1.5K) ≈ **5.6 KB ≈ ~1.4K tok** |
| Arranque trabajo significativo | + `PROTOCOL.md` entero(15.6K) ≈ **~5.5K tok** | + secciones puntuales de `PROTOCOL.md` bajo demanda ≈ **~2–3K tok** |
| Revisar investigación previa | escanear `research/` sin índice → **no acotado** | `research/INDEX.md`(pequeño) + abrir 1–2 archivos → **acotado** |

**Honestidad sobre el ahorro:** el ahorro en el *arranque rutinario* es modesto (~20–25%). Las ganancias grandes están en:
1. No re-leer `PROTOCOL.md` entero en cada trabajo significativo.
2. Acotar `research/` y `handoffs/` con un índice → "bajo demanda" nunca es "escanea todo".
3. El chequeo de obsolescencia barato evita re-verificar todo desde cero.
4. **Menos ciclos de re-trabajo por conflictos de merge y por contexto obsoleto** — el re-trabajo es el mayor coste oculto de tokens (`PROTOCOL §17`: "una respuesta barata y equivocada no es eficiente").

**Contra-argumento a mi propia propuesta:** más archivos = más superficie de drift y más navegación; un agente puede saltarse un archivo que necesitaba. **Mitigación:** el checklist de arranque en `AGENTS.md` enumera explícitamente los archivos y *cuándo* profundizar. Aun así, es un riesgo real que hay que aceptar y vigilar.

### 4.4 Comunicación entre agentes

**[RECOMENDACIÓN]**
- **Asíncrona, mediada por archivos, append-only.** Ningún agente lee la conversación de otro (**[HECHO]** ya en `AGENTS.md:10`).
- **El handoff es el mensaje.** Para asignación dirigida (Hermes → worker), usar la entrada de `TASKS.md` (campo `owner`). Un `.context/inbox/<agente>.md` append-only solo si aparece necesidad de mensajería dirigida de alto volumen — añade un almacén, así que por defecto no.
- **Independencia para convergencia:** frontmatter `estado` + `contaminacion` + no leer pares con el mismo `question_id` hasta converger.
  - **Limitación honesta:** esto es una convención, no un control. La única aplicación real es que el humano/orquestador no inyecte análisis de pares en el prompt (que es lo que hace esta tarea manualmente). Reduce la contaminación accidental; **no garantiza** independencia.
- **Salida de convergencia:** un nuevo research `estado: convergido` que cita cada entrada independiente por `id`, registra acuerdo, **preserva el desacuerdo** (`PROTOCOL §13/§14`) y la incertidumbre no resuelta. Opcionalmente una ADR.

### 4.5 Continuidad entre sesiones

**[RECOMENDACIÓN]**
- Arranque = checklist de `AGENTS.md` → Capa 1 + último handoff. Suficiente para continuar sin la conversación previa.
- **No asumir que la incertidumbre o el desacuerdo no resuelto de una sesión previa se resolvió por el paso del tiempo** (**[HECHO]** ya en `PROTOCOL §16`): comprobar `decisions/INDEX.md` y los handoffs buscando una resolución explícita.
- Un handoff con `repo_commit` permite a la siguiente sesión saber exactamente sobre qué estado se construyó.

### 4.6 Verificación y trazabilidad

**[RECOMENDACIÓN]**
- Cadena: handoff → enlaza ADR(s) + research → research enlaza `evidence/` + fuentes externas (clasificadas). Cualquier conclusión reconstruible sin la conversación.
- `repo_commit` en cada registro fija cada afirmación a un estado del repo.
- El campo "Verification" de los handoffs lista los **comandos realmente ejecutados** (el handoff de OpenCode lo hace bien — buena plantilla).
- **Adición de mayor apalancamiento: un lint mínimo in-repo** `scripts/check-context.sh` (es un script, no "instalar nada"):
  - frontmatter presente en archivos persistentes;
  - toda entrada de INDEX apunta a un archivo existente;
  - handoff tiene los 8 campos §15;
  - patrones de secreto ausentes;
  - líneas-resumen de `AGENTS.md` coinciden con sus secciones de `PROTOCOL.md` (anti-drift C1).
  - Ejecutable en pre-commit y/o CI. **Convierte una metodología aspiracional de 396 líneas en estructura parcialmente aplicada.** Sin esto, la propuesta depende de la disciplina de 4 agentes heterogéneos — que la evidencia semilla (C3, C5) ya muestra que falla.

Resuelve C12 (parcial — aplicación real, no solo prosa).

---

## 5. Precedentes de industria (conocimiento de entrenamiento; **no** re-verificado en esta sesión — U6)

- **Estándar `AGENTS.md`** (agents.md): un único archivo raíz, adoptado por varias herramientas de agentes. Apoya la Capa 0 de archivo único.
- **`CLAUDE.md` + imports jerárquicos** de Claude Code (memoria proyecto/usuario). Sugiere que `AGENTS.md` debe ser corto y componible, no un monolito.
- **Patrón "memory bank" / "context bank"** (comunidad Cline/Roo): archivos tipo `STATE/TASK/DECISIONS/progress`. **Modo de fallo conocido:** los archivos derivan del código; coste de tokens alto. Es exactamente el sistema actual, con sus fallos conocidos → refuerza C4, C9, C12.
- **ADR (Michael Nygard):** un archivo por decisión, inmutable, numerado, con campo de estado. Claramente mejor que un `DECISIONS.md` mutable para trazabilidad → apoya Capa 2.
- **`CODEOWNERS`** (git/GitHub): mecanismo nativo de propiedad → apoya §4.1.B.
- **Worktree/rama por agente:** usado en orquestación multi-agente para evitar colisiones → apoya §4.1.C.
- **Log append-only + snapshot derivado** (CQRS/event sourcing): el snapshot debe ser reconstruible desde el log → apoya "handoffs = log, STATE = snapshot".
- **Diátaxis:** marco para conocimiento durable → apoya Capa 5.
- **Sistemas distribuidos:** last-writer-wins es un peligro; leases con TTL son frágiles con actores que olvidan liberar → apoya rechazar la opción D y preferir append-only.

Aplicación de `PROTOCOL §9`: cada precedente es un dato, no autoridad. El patrón "memory bank" es el más comparable (mismo problema, mismos actores tipo LLM) y su valor principal aquí es **negativo**: muestra los modos de fallo que este diseño debe evitar.

---

## 6. Alternativas de arquitectura de alto nivel y trade-offs

| Alternativa | Pro | Contra | Veredicto |
|---|---|---|---|
| **A. Todo en git** (ramas, descripciones de PR, mensajes de commit, ADR) y eliminar casi todo `.context/` | Un almacén, herramienta nativa, inmutable, gran traza | Los agentes pierden el snapshot barato de "estado actual"; asume que cada agente puede hacer push; el handoff sin conversación sigue necesitando un hogar | **Adoptar los primitivos** (inmutabilidad, append-only, revisión por PR de cambios en `.context/`) pero conservar una capa fina de snapshot para arranque barato |
| **B. Base de datos / issue tracker** (GitHub Issues, Linear) como capa de coordinación | Control de concurrencia real, asignación, estado, comentarios, API | Dependencia externa, fuera del repo, coste de tokens al consultar, auth | **Evolución natural** si crece el nº de agentes o el paralelismo. Posiblemente el propósito de la "capa MCP" mencionada en `STATE.md`. Ahora: archivos, menor fricción |
| **C. `CONTEXT.md` monolítico** | Una lectura, sin navegación | Cada escritura lo toca → máxima superficie de conflicto; no aísla volatilidad; crece sin límite; sin inmutabilidad por registro | **Rechazar** |
| **D. Directorios de contexto por agente** (`.context/agents/claude/…`) | Cero conflictos de escritura | Fragmenta la verdad compartida; la convergencia se vuelve un diff N-way; "estado actual" tiene N versiones | **Rechazar para estado compartido**; usar solo para scratch/inbox |
| **E. Capas por frecuencia+volatilidad (esta propuesta)** | Lectura obligatoria mínima; todo lo demás lazy y acotado por índice; append-only elimina la mayoría de conflictos; traza por registro inmutable | Más archivos → más superficie de drift y riesgo de omisión; requiere lint para ser real | **Recomendada**, condicionada a §7 |
| **F. Capa MCP que sirve slices de `.context/`** | El servidor devuelve solo el trozo necesario → posible ahorro de tokens | Añade un componente; el servidor puede quedar obsoleto respecto al repo; auth | **Diferir**; camino de evolución junto con B |

---

## 7. Revisión crítica de esta propuesta e iteración

**Iteración 1 → hallazgos del pase escéptico:**

1. **"Añado archivos mientras critico que el protocolo es grande — ¿me contradigo?"**
   Resolución: el coste de tokens lo domina *lo que se lee cada sesión*, no el nº de archivos. La propuesta reduce la lectura obligatoria ~20–25% en rutina y mucho más en trabajo significativo, y acota los directorios grandes. Archivos que no se leen ≈ 0 tokens. **Pero** el riesgo de navegación/omisión es real → mitigado con checklist explícito, y hay que declararlo, no esconderlo. *(Incorporado en §4.3.)*

2. **Sobreventa del mecanismo de independencia.**
   El frontmatter `contaminacion` es convención; el control real es que el humano no inyecte análisis de pares. Degradado a "reduce contaminación accidental; no garantiza independencia". *(Incorporado en §4.4.)*

3. **`repo_commit` en frontmatter tiene el mismo problema de aplicación que el resto.**
   Solo un lint/hook lo hace real. Por tanto el `scripts/check-context.sh` **no es opcional**: es el componente que convierte la propuesta de aspiracional en parcialmente aplicada. *(Promovido a recomendación central, §4.6.)*

4. **"Consequential" para ADR es terminología ambigua (lo que `PROTOCOL §10` prohíbe).**
   Añadido umbral concreto de 4 criterios. *(Incorporado en §Capa 2.)*

5. **Obsidian-como-vista: asumí que Obsidian solo abre la carpeta.**
   Cierto desde conocimiento general, pero la intención del usuario puede ser un vault curado aparte. Presentadas ambas, recomendada la vista in-repo salvo razón específica. *(Incorporado en §Capa 5.)*

6. **¿`PROTOCOL.md` se lee cada sesión? No lo respondí de frente.**
   Respuesta explícita: **NO**. `AGENTS.md` lleva las ~10 reglas siempre activas; `PROTOCOL.md` se consulta por sección al hacer trabajo significativo (su propio disparador §11) o ante duda. Resuelve C2. *(Incorporado en §Capa 0.)*

7. **¿Quién manda si `AGENTS.md` y `PROTOCOL.md` chocan?**
   Resuelto eliminando la elección: `PROTOCOL.md` es la única fuente; las líneas de `AGENTS.md` son resumen derivado y marcado como tal; el lint verifica que sean subconjunto. *(Incorporado en §Capa 0 y §4.6.)*

8. **`TASKS.md`: ¿múltiple o singular? Vacilé.**
   Decisión: soportar múltiples entradas (barato, a prueba de futuro) pero declarar el modelo vigente ("máx. 1 en progreso" si Hermes serializa hoy). *(Incorporado en §Capa 1.)*

**Iteración 2 → segundo pase:**

9. **Coste del propio chequeo de obsolescencia.** `git diff --stat A..HEAD` es un comando barato. Decidir "¿es esta ruta relevante?" es juicio del agente — aceptable. Sin cambio material.

10. **La capa MCP mencionada en `STATE.md`.** Encaja como camino de evolución F (servir slices) o B (tracker). Añadido a §6 en lugar de ignorarlo. *(Incorporado.)*

11. **La prueba de OpenCode necesita promoción/limpieza.** Es backlog concreto, no arquitectura → separado en §4.2 "remediación inmediata". *(Incorporado.)*

12. **Nombres de campo bilingües.** Decididos: claves EN (estables, alineadas con `PROTOCOL`, lint-ables), cuerpo ES. Registrar en `CONVENTIONS.md`. *(Incorporado en §Capa 3.)*

**Iteración 3:** sin mejora relevante. Las incertidumbres restantes (§2: U1 auto-carga por herramienta, U2 naturaleza de Hermes, U3 flujo git, U5 tokens, U6 precedentes) son **ambientales**: requieren verificación externa o decisión del usuario, no más diseño. **Condición de parada alcanzada: "no se encontró mejora relevante tras revisión crítica deliberada"** — lo que no significa certeza.

---

## 8. Tabla de modos de fallo (actual → mitigación propuesta)

| Modo de fallo | Presente hoy | Mitigación |
|---|---|---|
| Dos agentes escriben `DECISIONS.md` en paralelo → conflicto / decisión perdida | Sí (C6) | ADR: un archivo inmutable por decisión |
| `latest.md` sobrescrito, próximo-paso previo perdido | Sí (C3) | INDEX append-only + handoffs inmutables |
| Agente confía en "Codex rate-limited" horas obsoleto y salta a Codex | Sí (C4) | Prohibir hechos volátiles en archivos de estado |
| Agente en análisis independiente lee el borrador de un par → falsa convergencia | Sí (C10) | Frontmatter `contaminacion` + `question_id` + disciplina del orquestador (residual: no garantizado) |
| `research/` crece a 200 archivos, el agente no puede escanear | Sí (C9) | `INDEX.md` + filtros por estado + archive |
| `PROTOCOL.md` actualizado, `AGENTS.md` no → reglas divergentes | Sí (C1) | Fuente única + lint anti-drift |
| Handoff dice "hecho", código no commiteado (divergencia `STATE` vs git) | **Sí, ahora mismo** (C5) | Campo `repo_commit` + chequeo de obsolescencia + lint |
| Agente en Windows no puede seguir `latest.md` symlink | Riesgo latente | `INDEX.md`, no symlink |
| Secreto pegado en un bloque de evidencia de handoff | Riesgo latente | Escaneo de secretos en pre-commit; `evidence/` en `.gitignore` si puede contener datos sensibles |
| `TASK.md` singular no representa 2 workstreams paralelos | Sí (C7) | `TASKS.md` con entradas múltiples + `owner` |
| Handoffs/research sin límite de crecimiento | Sí (C15) | Retención distribuida (quien escribe el nº 21 archiva 1–10) |

---

## 9. Resumen ejecutivo

**Hechos clave verificados:**
- El sistema actual duplica reglas entre `AGENTS.md` y `PROTOCOL.md` (C1), usa snapshots mutables de un solo escritor para estado, decisiones y handoffs (C3, C6), mezcla estado durable con runtime volátil (C4), y **ya presenta una divergencia repo↔contexto sin commitear** (C5). El dato semilla incumple el propio `PROTOCOL §15` (C3). No hay modelo de concurrencia, índice de investigación, política de retención ni aplicación automática (C6, C9, C12, C15).

**Inferencias principales:**
- El proyecto está en fase meta (sin código de producto). El coste de tokens del sistema está dominado por la lectura obligatoria de arranque y por escaneos no acotados, no por el número de archivos.

**Recomendación central:**
Arquitectura en 6 capas por frecuencia de lectura y volatilidad (Capa 0 bootstrap mínimo → Capa 5 conocimiento durable), con tres cambios estructurales:
1. **Workers append-only; snapshots mutables solo del orquestador** (o disciplina "añade tu línea").
2. **Registros inmutables + índices append-only** para decisiones (ADR), handoffs y research; `latest` deja de ser un archivo.
3. **`scripts/check-context.sh`** (lint in-repo, no instala nada) como condición para que la metodología sea aplicada y no solo aspiracional.
Más: frontmatter con `repo_commit` para detección barata de obsolescencia; `CODEOWNERS`; retención distribuida; frontera anti-duplicación de una-capa-por-hecho; Obsidian como vista in-repo.

**Trade-off aceptado:** más archivos → más superficie de drift y riesgo de omisión, mitigado con un checklist de arranque explícito y el lint. El ahorro de tokens en arranque rutinario es modesto (~20–25%); las ganancias grandes son evitar re-lecturas de `PROTOCOL.md` entero, acotar directorios grandes, y **reducir el re-trabajo por conflictos y contexto obsoleto**.

**Incertidumbres sin resolver (requieren al usuario):**
- U1: qué archivo de contexto auto-carga cada CLI (load-bearing para "bootstrap mínimo").
- U2: si "Hermes" es humano, agente o script (determina el modelo de ownership).
- U3: flujo git real de los workers (determina la política de merge de `.context/`).
- U6: los precedentes de industria citados no se re-verificaron contra documentación vigente en esta sesión.

**Desacuerdo material:** ninguno registrado — este es un análisis independiente único; la convergencia con otros análisis queda pendiente y **no debe manufacturarse**.
