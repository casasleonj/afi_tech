# CONTEXTO MAESTRO — HERMES / SISTEMA MULTIAGENTE CON GRAPHIFY

**Versión:** 3.0  
**Fecha:** 2026-09-17  
**Estado:** Diseño consolidado e integrado con protocolos Git/CI, Worktrees, Vector Retrieval, GraphDB, Feature Flags, seguridad, incidentes y evaluación; parcialmente implementado y pendiente de auditoría final del VPS.  
**Propósito:** permitir que cualquier LLM reconstruya con alta fidelidad el sistema, sus objetivos, arquitectura, decisiones, restricciones, criterios de éxito, estado conocido y próximos pasos, sin depender de la conversación original.

---

## 0. Resumen ejecutivo

Este proyecto busca construir una **infraestructura multiagente persistente sobre un VPS de Hostinger**, orientada no solo a programación sino al **desarrollo iterativo de ideas, productos y decisiones**, manteniendo intención, trazabilidad, contexto y conocimiento a largo plazo.

La arquitectura acordada tiene como núcleo:

- **Hermes** como coordinador/orquestador.
- Un **LLM principal de OpenAI** como rol de ideación, razonamiento y desarrollo conceptual.
- **OpenCode** como implementador principal de código.
- **Claude Code** como revisor crítico, analista y agente fuerte en documentación.
- **Telegram** como interfaz cotidiana con Hermes.
- **Git/GitHub** como fuente de verdad de código e historia.
- `.context/` como memoria operativa y continuidad entre agentes.
- **Graphify** como grafo técnico/semántico del sistema.
- Un **Knowledge Vault basado en Markdown** como memoria deliberada de decisiones, requisitos, hipótesis y provenance.
- **Obsidian** como interfaz humana para explorar y editar ese Knowledge Vault.
- **Hermes Memory/Skills** para hechos de acceso frecuente y procedimientos reutilizables.
- **Human-in-the-loop** para decisiones sensibles, ambiguas o de alto impacto.
- Un **Git Delivery Protocol** obligatorio para ramas, PR, CI, review, merge, smoke post-merge, soak programado, cuarentena de tests y rollback.
- Tres protocolos operativos mínimos adicionales: **Security & Secrets**, **Incident & Recovery** y **Evaluation & Release Gates**.

La filosofía central es:

> **Determinístico primero, conocimiento estructurado después, LLM donde agrega valor, humano cuando la decisión realmente lo exige.**

---

# 1. Objetivo global

Construir un sistema donde el usuario pueda desarrollar ideas mediante conversación iterativa y luego convertirlas en trabajo ejecutable, revisable y trazable, sin perder contexto ni intención.

Ciclo objetivo:

```text
idea inicial
→ conversación
→ cuestionamiento
→ investigación
→ variantes
→ decisiones
→ requisitos
→ implementación
→ revisión
→ detección de ambigüedad
→ resolución
→ nueva iteración
```

El objetivo no es simplemente “automatizar programación”, sino **preservar la evolución conceptual del proyecto mientras agentes especializados ejecutan trabajo técnico**.

---

# 2. Principios rectores

## 2.1 La intención humana es la autoridad final

Los modelos ayudan a analizar, proponer, comparar, detectar riesgos y desarrollar alternativas. Las decisiones empresariales o estratégicas importantes siguen perteneciendo al usuario.

## 2.2 No resolver silenciosamente ambigüedades

Si un agente encuentra una decisión de negocio, intención, UX, sesgo o requisito ambiguo:

1. no debe inventar una interpretación;
2. debe buscar primero si existe una decisión previa;
3. si no existe, debe escalar.

## 2.3 Cada capa tiene una función clara

```text
Hermes Memory
= hechos siempre necesarios

Skills
= procedimientos reutilizables

.context/
= estado operativo actual

Git + main
= fuente canónica de código e historial verificable

Git Worktrees
= aislamiento temporal para trabajo concurrente; nunca fuente canónica

Graphify
= extractor/generador del grafo técnico desde fuentes canónicas

Knowledge Vault Markdown
= fuente canónica de decisiones, requisitos, rationale y provenance

Vector Retrieval / VectorDB
= índice semántico derivado y reconstruible; nunca fuente de verdad

GraphDB
= proyección relacional derivada para consultas multi-hop/GraphRAG; nunca reemplaza las fuentes canónicas

Feature Flag control plane
= autoridad runtime del estado de flags; definiciones/lifecycle quedan trazados en Git/Vault

Obsidian
= interfaz humana del Knowledge Vault
```

## 2.4 Context engineering > enviar toda la conversación

Cada agente debe recibir solo el contexto necesario.

## 2.5 Multiagente solo cuando agrega valor

No usar múltiples agentes para tareas triviales.

## 2.6 Evidencia antes que inferencia

Siempre distinguir hechos, inferencias, decisiones, hipótesis y ambigüedades.

---

# 3. Arquitectura objetivo

```text
                                    USUARIO
                                       │
                            Telegram / CLI / SSH
                                       │
                                       ▼
                                  ┌──────────┐
                                  │  HERMES  │
                                  │ router + │
                                  │ contexto │
                                  └────┬─────┘
                                       │
                           LLM principal de ideación
                              / razonamiento
                                       │
             ┌─────────────────────────┼─────────────────────────┐
             │                         │                         │
             ▼                         ▼                         ▼
         OpenCode                  Claude Code                Tools
        implementación            review/docs              investigación
             │                         │
             └──────────────┬──────────┘
                            ▼
                          Hermes
                            │
       ┌────────────────────┼──────────────────────────────┐
       │                    │                              │
       ▼                    ▼                              ▼
 Git main / CI         Knowledge Vault                 Graphify
 fuente canónica       fuente conceptual            grafo técnico derivado
       │                    │                              │
       │                    ├──────────────┐               │
       │                    │              │               │
       ▼                    ▼              ▼               ▼
 Worktrees            Vector Index      Obsidian        GraphDB
 temporales           derivado           UI humana      proyección derivada
       │                    │                              │
       └─────────────── preview scopes / indexes ─────────┘

 Runtime de producto:
 Git/CI → deploy → Feature Flags/OpenFeature provider → rollout/kill switch
```

---

# 4. Roles

## 4.1 Hermes

Hermes es la **capa coordinadora**.

Responsabilidades:

- recibir instrucciones;
- recuperar contexto;
- clasificar tareas;
- decidir qué agente usar;
- controlar flujo;
- gestionar escalaciones;
- consolidar resultados;
- mantener provenance;
- coordinar memoria;
- limitar loops;
- aplicar approvals;
- evitar trabajo redundante.

Hermes no es “otro cerebro separado”; usa un LLM principal para razonar.

## 4.2 LLM principal de ideación

Rol:

- desarrollar ideas con el usuario;
- explorar variantes;
- cuestionar supuestos;
- analizar negocio;
- resolver ambigüedades conceptuales;
- mantener coherencia con intención;
- recibir escalaciones de Claude;
- producir decisiones o propuestas con contexto.

Debe distinguirse:

```text
ChatGPT app ≠ modelo dentro de Hermes
```

La experiencia puede ser similar, pero el contexto debe almacenarse explícitamente.

## 4.3 OpenCode

Rol principal: **implementación de código**.

Responsabilidades:

- features;
- bugs;
- refactors;
- tests;
- cambios técnicos;
- documentación directamente asociada;
- validación local;
- uso de Git;
- handoffs.

No debe tomar decisiones de negocio importantes por defecto.

## 4.4 Claude Code

Rol principal: **revisión crítica, análisis y documentación**.

Responsabilidades:

- revisar independientemente;
- buscar contradicciones;
- detectar bugs;
- identificar riesgos;
- comprobar supuestos;
- validar requisitos;
- revisar documentación;
- detectar ambigüedades;
- proponer mejoras.

### Regla especial de Claude

Si detecta decisión de negocio, ambigüedad, sesgo, conflicto de intención, UX no definida, regla funcional contradictoria o requisito incompleto:

```text
1. buscar decisión previa;
2. si existe → usarla;
3. si no existe → escalar a Hermes;
4. Hermes remite al rol de ideación;
5. si sigue requiriendo criterio humano → usuario.
```

---

# 5. Routing semántico

Hermes debe clasificar por **tipo de problema**, no solo por agente disponible.

```text
CODE
→ OpenCode

DOCS
→ Claude

ANALYSIS
→ Claude

RESEARCH
→ Hermes / herramienta adecuada

BUSINESS
→ LLM ideación

AMBIGUITY
→ recuperar conocimiento → ideación si falta

BIAS
→ ideación / usuario si afecta decisión

INTENT
→ ideación / usuario

MIXED
→ dividir en tracks
```

Ejemplo:

```text
Claude detecta:
- bug técnico;
- significado ambiguo de “completado”.

Hermes:
track técnico → OpenCode
track negocio → ideación
bloquea implementación si el bug depende de esa definición.
```

---

# 6. Graphify — rol de primera clase

Graphify se incorpora como componente central.

## 6.1 Función

Graphify debe actuar como **grafo técnico/semántico generado a partir del sistema real**.

Debe representar, cuando corresponda:

- archivos;
- funciones;
- clases;
- módulos;
- schemas;
- dependencias;
- llamadas;
- relaciones;
- documentación;
- infraestructura;
- conceptos técnicos;
- referencias cruzadas.

## 6.2 Problema que resuelve

Evita que los agentes tengan que releer todo el repo constantemente.

Ejemplos:

```text
¿Qué depende de esta tabla?
¿Qué función llama a este servicio?
¿Qué módulos toca este cambio?
¿Dónde está implementado este concepto?
¿Qué puede romperse?
```

## 6.3 Regla de evidencia

Graphify debe distinguir, siempre que la herramienta lo permita, entre relaciones extraídas, inferidas o ambiguas. La inferencia nunca debe presentarse como hecho.

---

# 7. Graphify vs Knowledge Vault vs Obsidian

Esta distinción es crítica.

## 7.1 Graphify

```text
= realidad técnica
```

Contiene estructura del repo, dependencias, relaciones de código, componentes y arquitectura técnica extraída o inferida.

## 7.2 Knowledge Vault

```text
= conocimiento deliberado
```

Contiene decisiones, rationale, requisitos, hipótesis, investigación, riesgos, ambigüedades, provenance y estado de decisiones.

## 7.3 Obsidian

```text
= interfaz humana
```

Sirve para navegar, editar, visualizar, relacionar y explorar el Knowledge Vault.

**Obsidian no debe ser el backend crítico del sistema.**

---

# 8. Relación entre Graphify y Knowledge Vault

No deben mezclarse automáticamente.

Estructura recomendada:

```text
/knowledge/
  decisions/
  requirements/
  research/
  assumptions/
  projects/

/graphify-out/
  graph.json
  graph.html
  reports/
```

Cruces mediante referencias explícitas:

```yaml
decision_id: DEC-014
title: Estado "completado"

technical_refs:
  graphify_nodes:
    - OrderState
    - PaymentStatus

business_refs:
  - REQ-022
  - RULE-003
```

Esto habilita detección de **drift**:

```text
decisión aprobada
≠
implementación actual
```

---

# 9. Provenance

Cada decisión importante debe conservar quién tenía autoridad, quién la originó, quién detectó el problema, quién la resolvió y qué evidencia se utilizó.

Ejemplo:

```yaml
decision_id: DEC-042

authority:
  type: business
  owner: user

origin:
  role: ideation
  provider: openai
  model: <modelo>

detected_by:
  agent: claude

resolved_by:
  role: ideation

context_refs:
  - REQ-008
  - IDEA-002
  - graphify:OrderState

status: resolved
```

La autoridad no debe depender de que “el mismo modelo exacto” siga disponible.

La autoridad real es:

```text
intención
+
historial
+
decisiones
+
contexto
+
provenance
```

---

# 10. Capas de memoria

## Nivel 1 — Hermes Memory
Hechos pequeños, durables y siempre necesarios.

## Nivel 2 — Skills
Procedimientos reutilizables.

## Nivel 3 — `.context/`
Estado operativo: tarea actual, decisiones recientes, handoff, riesgos y siguiente paso.

## Nivel 4 — Knowledge Vault
Conocimiento de largo plazo.

## Nivel 5 — Graphify
Mapa técnico generado.

## Nivel 6 — Git
Código e historial verificable.

---

# 11. Telegram

Telegram será la interfaz cotidiana.

Debe permitir:

- conversar;
- enviar instrucciones;
- consultar estado;
- recibir resultados;
- recibir escalaciones;
- aprobar/rechazar;
- recibir alertas.

Pero:

```text
Telegram ≠ administración irrestricta del VPS
```

Seguridad mínima:

- allowlist;
- perfil limitado;
- approvals;
- secretos fuera de chat;
- acciones destructivas requieren confirmación.

---

# 12. `.context/` y Git

Estructura validada:

```text
AGENTS.md
CLAUDE.md -> AGENTS.md

.context/
├── PROTOCOL.md
├── STATE.md
├── TASK.md
├── DECISIONS.md
├── CONVENTIONS.md
├── handoffs/
│   ├── latest.md
│   └── YYYY-MM-DD_<agent>-<slug>.md
└── research/
```

Git es la fuente de verdad para código, historia, cambios y contexto operativo versionado.

---

# 13. Estado histórico validado

Repo:

```text
/workspace/afi_tech
```

Remote:

```text
git@github.com:casasleonj/afi_tech.git
```

Branch:

```text
main
```

Commits relevantes observados:

```text
e9ba9b5
02e0970
f6c35c2
d1e6e2a
97620e7
fdb9ea7
01e4103
```

Último estado explícitamente verificado en la conversación:

```text
HEAD        = 01e410394498fa558b219dc4c3fb2a26e72e640d
origin/main = 01e410394498fa558b219dc4c3fb2a26e72e640d
working tree limpio
```

Este dato es histórico. Siempre verificar antes de actuar.

---

# 14. OpenCode — estado conocido

Versión observada:

```text
1.18.23
```

Problema encontrado:

```text
/tmp → noexec
```

Solución probada:

```bash
TMPDIR=/workspace/.tmp opencode
```

Comando probado:

```bash
docker exec -it a59605ba1b7a sh -lc '
cd /workspace/afi_tech &&
TMPDIR=/workspace/.tmp opencode
'
```

Funcionó correctamente.

---

# 15. Claude Code — estado conocido

Versión observada:

```text
2.1.247
```

`CLAUDE.md`:

```text
symlink → AGENTS.md
```

Claude reconstruyó correctamente contexto desde repo/handoff sin conversación.

---

# 16. Handoffs

Campos requeridos:

1. Task
2. Result
3. Decisions
4. Files changed
5. Verification
6. Risks/problems
7. Remaining work
8. Recommended next step

Los handoffs fechados son inmutables. `latest.md` es puntero mutable.

---

# 17. Problema conocido de `latest.md`

Se detectó una debilidad autorreferencial:

```text
Written against HEAD X
```

queda stale después del commit que modifica `latest.md`.

Recomendación conceptual:

```text
latest.md = puntero puro
```

y Git se consulta dinámicamente.

No implementar sin revisión.

---

# 18. Requerimientos funcionales

- **RF-01** Ideación persistente.
- **RF-02** Routing semántico.
- **RF-03** Escalación conceptual.
- **RF-04** Implementación separada.
- **RF-05** Revisión independiente.
- **RF-06** Documentación gestionada por Claude cuando corresponda.
- **RF-07** Telegram operativo.
- **RF-08** Knowledge Vault durable.
- **RF-09** Graphify operativo.
- **RF-10** Git como verdad.
- **RF-11** Handoffs.
- **RF-12** Provenance.
- **RF-13** Human-in-the-loop.
- **RF-14** Recuperación contextual.
- **RF-15** Detección de drift entre decisiones e implementación.
- **RF-16** Contexto mínimo por agente.

---

# 19. Requerimientos no funcionales

- **RNF-01** Trazabilidad.
- **RNF-02** Recuperabilidad.
- **RNF-03** Bajo acoplamiento.
- **RNF-04** Seguridad.
- **RNF-05** Eficiencia de tokens.
- **RNF-06** Independencia de revisión.
- **RNF-07** Incrementalismo.
- **RNF-08** Evidencia sobre inferencia.
- **RNF-09** Observabilidad.
- **RNF-10** Convergencia controlada.

---

# 20. Elicitation

Antes de preguntar al usuario:

```text
1. consultar .context
2. consultar Knowledge Vault
3. consultar decisiones
4. consultar Graphify
5. consultar Git
6. consultar research
7. solo entonces preguntar
```

Formato recomendado:

```text
ESCALATION_TYPE: business_decision
ISSUE:
EVIDENCE:
KNOWN_DECISIONS:
GRAPHIFY_REFS:
QUESTION:
OPTIONS:
RISK_OF_ASSUMPTION:
STATUS:
```

---

# 21. Criterios de éxito

- **CE-01 — Reconstrucción:** un agente nuevo reconstruye el proyecto sin conversación original.
- **CE-02 — Telegram:** Telegram ↔ Hermes funciona.
- **CE-03 — OpenCode:** OpenCode implementa correctamente.
- **CE-04 — Claude:** Claude revisa independientemente.
- **CE-05 — Graphify:** Hermes/Claude/OpenCode consultan el grafo técnico.
- **CE-06 — Knowledge Vault:** las decisiones importantes persisten.
- **CE-07 — Provenance:** se sabe quién originó/detectó/resolvió.
- **CE-08 — Escalación:** ambigüedad de negocio no se implementa silenciosamente.
- **CE-09 — Drift detection:** el sistema puede detectar diferencias entre decisión y código.
- **CE-10 — Seguridad:** Telegram no puede saltarse approvals.
- **CE-11 — Reinicio:** el contexto sobrevive.
- **CE-12 — Token efficiency:** no se reinyecta contexto completo innecesariamente.
- **CE-13 — Convergencia:** no existen loops infinitos.

---

# 22. Restricciones

1. VPS de Hostinger.
2. Hermes como coordinador.
3. OpenAI como rol principal de ideación, sujeto a verificación real.
4. OpenCode como coding worker.
5. Claude como reviewer/análisis/docs.
6. Telegram como interfaz.
7. GitHub como fuente de verdad.
8. Graphify como grafo técnico.
9. Knowledge Vault Markdown como memoria deliberada.
10. Obsidian como interfaz humana.
11. No depender de Codex.
12. No sobrearquitectar.
13. No exponer secretos.
14. No cambios destructivos sin aprobación.
15. No decisiones de negocio silenciosas.
16. No contexto completo para todos.
17. No múltiples writers sin control.
18. No nested agents profundos inicialmente.
19. No review pesado para tareas triviales.
20. No asumir el estado del VPS.

---

# 23. Eficiencia de tokens

Principio:

```text
contexto mínimo
+
agente especializado
+
salida resumida
```

No:

```text
repo completo
+ chat completo
+ vault completo
```

## OpenCode recibe

```text
task
acceptance criteria
relevant files
relevant decisions
graphify refs
```

## Claude recibe

```text
task
diff
requirements
decisions
review criteria
graphify refs
```

## Ideation recibe

```text
question
business context
alternatives
provenance
```

---

# 24. Multiagente basado en riesgo

```text
typo
→ directo

doc menor
→ Claude o worker

bug localizado
→ OpenCode + tests

feature normal
→ OpenCode + Claude

feature crítica
→ OpenCode + Claude + revisión adicional si aplica

decisión de negocio
→ ideation + usuario si necesario
```

---

# 25. Concurrencia

La concurrencia se controla explícitamente mediante **PROTO-WT**.

Regla:

```text
flujo secuencial
→ un working tree puede ser suficiente

dos o más agentes escribiendo código en paralelo
→ un worktree + branch único por tarea/agente

alto solapamiento de archivos o dependencias
→ serializar aunque existan worktrees
```

Los worktrees aíslan archivos; **no resuelven conflictos semánticos**. Antes de paralelizar, Hermes debe usar alcance, Graphify y/o análisis de dependencias para estimar colisiones.

El `main worktree` se reserva como integración/coordinación. Los workers no deben modificar simultáneamente los snapshots mutables de `.context/`.

---

# 26. Lo que NO debe construirse inicialmente

Los protocolos existen desde el inicio, pero **no obligan a desplegar cada componente físico desde el día uno**.

Evitar:

```text
❌ bot Telegram propio si la integración oficial cubre el caso
❌ framework multiagente propio
❌ instalar simultáneamente varios VectorDB sin evaluación
❌ instalar una GraphDB si Graphify/JSON cubre las consultas reales
❌ usar VectorDB o GraphDB como fuente canónica
❌ MCP para todo
❌ ACP como requisito
❌ varios orchestrators
❌ nested agents profundos
❌ review pesado de todo
❌ worktrees cuando no existe escritura paralela
❌ feature flags para secretos/configuración estática
❌ flags temporales sin owner/expiry/cleanup
❌ chat completo por agente
❌ Obsidian como backend crítico
```

La política correcta es:

```text
PROTOCOLO SIEMPRE DEFINIDO
+
COMPONENTE ACTIVADO SOLO CUANDO EL GATE LO JUSTIFICA
```

---

# 27. Lo que realmente debemos construir/configurar

## A. Routing policy

```text
CODE
DOCS
ANALYSIS
BUSINESS
AMBIGUITY
BIAS
INTENT
MIXED
```

## B. Escalation policy

```text
known?
→ reuse

unknown technical?
→ investigate

unknown business?
→ ideation / user
```

## C. Provenance

Registrar origen, autoridad, contexto, detector, resolutor y estado.

## D. Knowledge lifecycle

```text
capture
→ normalize
→ link
→ retrieve
→ supersede
→ archive
```

## E. Graphify integration

```text
repo
→ graphify
→ technical graph
→ agents query graph
```

## F. Drift detection

```text
knowledge decision
↔ graphify technical reality
```

---

# 28. Pruebas conceptuales

## Caso 1 — Idea nueva

```text
User → Hermes → ideation → Knowledge Vault
```

**PASS conceptual.**

## Caso 2 — Implementación

```text
approved idea → OpenCode → tests → Claude if risk requires
```

**PASS conceptual.**

## Caso 3 — Bug técnico

```text
Claude → Hermes → OpenCode
```

**PASS conceptual.**

## Caso 4 — Ambigüedad de negocio

```text
Claude → retrieve → no answer → ideation → user if required → decision
```

**PASS conceptual.**

## Caso 5 — Cambio contradice decisión

```text
Graphify → technical state
Knowledge Vault → approved state
difference → drift alert
```

**PASS conceptual.**

## Caso 6 — Modelo cambia

```text
provenance survives
```

**PASS conceptual.**

## Caso 7 — Telegram comprometido

Sin approvals: **FAIL**.  
Con allowlist + limited profile + approvals: **PASS conceptual**.

## Caso 8 — Obsidian no disponible

Knowledge Vault sigue siendo Markdown.

**PASS.**

## Caso 9 — Graphify no disponible

Sistema degrada a Git/search.

**PASS con menor eficiencia.**

---

# 29. Orden de implementación optimizado

## Fase 0 — Auditoría VPS

Verificar:

- Hermes version;
- provider/model;
- services;
- Docker;
- skills;
- Telegram;
- Graphify;
- vault;
- auth type;
- existing configs.

## Fase 1 — Core policy

Definir routing, escalation, authority, provenance y review thresholds.

## Fase 2 — CLI E2E

```text
Hermes → OpenCode → Claude → Hermes
```

Sin Telegram ni Obsidian.

## Fase 3 — Graphify

- indexar repo;
- consultar grafo;
- validar utilidad;
- medir reducción de búsquedas.

## Fase 4 — Telegram

- configurar;
- allowlist;
- approvals;
- pruebas.

## Fase 5 — Knowledge Vault

- Markdown;
- schema;
- metadata;
- provenance.

## Fase 6 — Obsidian

Abrir Knowledge Vault como interfaz.

## Fase 7 — Cross-link Graphify ↔ Knowledge Vault

## Fase 8 — Drift detection

## Fase 9 — Token optimization

- caching;
- minimal context;
- cheap auxiliary models;
- thresholds.

## Fase 10 — Evals

Crear batería de escenarios canónicos.

---

# 30. Definition of Done

```text
[ ] Hermes conoce su rol
[ ] OpenCode implementa código
[ ] Claude revisa independientemente
[ ] Graphify indexa el repo
[ ] agentes consultan Graphify
[ ] Knowledge Vault persiste decisiones
[ ] Obsidian visualiza el vault
[ ] Telegram inicia flujos
[ ] approvals funcionan
[ ] negocio ambiguo se escala
[ ] decisiones se reutilizan
[ ] provenance funciona
[ ] drift puede detectarse
[ ] contexto sobrevive reinicios
[ ] Git reconstruye cambios
[ ] no hay secretos en repo/vault
[ ] tokens se miden
[ ] no hay loops infinitos
[ ] evals pasan
```

---

# 31. Hechos verificados vs diseño

## Verificado históricamente

- `/workspace/afi_tech`
- Git/context/handoffs
- OpenCode
- Claude
- flujo OpenCode → Claude
- recuperación sin conversación
- `TMPDIR=/workspace/.tmp`
- commit `01e4103` sincronizado en último chequeo explícito

## Diseño acordado

- Hermes coordinador
- LLM ideation
- OpenCode código
- Claude review
- Telegram
- Graphify
- Knowledge Vault
- Obsidian UI
- provenance
- routing
- escalation
- drift detection
- human-in-the-loop

## Pendiente de verificar

- modelo real de Hermes
- provider/auth
- Graphify instalado o no
- Telegram configurado o no
- vault existente o no
- Obsidian existente o no
- routing automatizado
- provenance automatizado
- E2E completo

---

# 32. Instrucciones para un LLM nuevo

Si recibes este archivo:

1. No asumas que el estado histórico sigue vigente.
2. Verifica Git.
3. Lee `AGENTS.md`.
4. Lee `.context/*`.
5. Abre handoff actual.
6. Verifica Hermes real.
7. Verifica Graphify.
8. Verifica Knowledge Vault.
9. Verifica Telegram.
10. Verifica Obsidian.
11. No muestres secretos.
12. No modifiques durante auditoría.
13. Diferencia hechos de inferencias.
14. No inventes requisitos.
15. Consulta Graphify antes de recorrer todo el repo cuando sea útil.
16. Consulta decisiones antes de preguntar.
17. Escala negocio si sigue ambiguo.
18. Código → OpenCode.
19. Revisión/docs → Claude.
20. Mantén provenance.

---

# 33. Mejora sustancial respecto a v1

La versión 2 corrige y simplifica varios puntos:

1. **Graphify pasa a ser componente de primera clase.**
2. **Obsidian deja de ser “el grafo” y pasa a ser la interfaz humana del Knowledge Vault.**
3. Se separan claramente **realidad técnica** y **realidad conceptual**.
4. Se introduce **drift detection** entre decisiones y código.
5. Se evita depender del “mismo modelo exacto” y se prioriza **provenance + contexto**.
6. Se reduce sobrearquitectura: Worktrees, VectorDB, GraphDB y Feature Flags tienen protocolo explícito, pero su activación física depende de gates y evals; ACP/MCP/nested agents siguen sin ser obligatorios.
7. Se incorpora routing basado en riesgo para ahorrar tokens.
8. Se explicita degradación segura si Graphify u Obsidian no están disponibles.
9. Se mejora el orden de implementación: primero core policy y CLI E2E, después interfaces.
10. Se convierte la validación en una batería objetiva de criterios y evals.

---

# 34. Principio final

El sistema debe preservar la intención humana y convertirla en ejecución verificable.

```text
intención
↓
conocimiento
↓
decisiones
↓
implementación
↓
realidad técnica
↓
verificación
↓
nueva decisión
```

**Graphify conecta la realidad técnica.**  
**Knowledge Vault conserva la realidad conceptual.**  
**Obsidian permite al humano navegar esa realidad conceptual.**  
**Hermes conecta ambas.**  
**OpenCode modifica la implementación.**  
**Claude detecta divergencias y revisa.**  
**El LLM de ideación ayuda a resolver intención y negocio.**  
**El usuario conserva la autoridad final.**

---

# 35. Conjunto integrado de protocolos obligatorios

Para operar de forma autónoma sin reglas contradictorias, el sistema adopta **ocho protocolos integrados** dentro de este mismo Contexto Maestro:

```text
PROTO-GIT    → ramas, PR, CI, merge, smoke y soak
PROTO-SEC    → acceso, secretos, privilegios y approvals
PROTO-INC    → incidentes, rollback y recuperación
PROTO-EVAL   → evals, gates y promoción de cambios
PROTO-WT     → aislamiento de trabajo concurrente con Git worktrees
PROTO-VEC    → indexación semántica / VectorDB y retrieval híbrido
PROTO-GRAPH  → Graphify + GraphDB / GraphRAG y relaciones trazables
PROTO-FLAG   → Feature Flags, progressive delivery y kill switches
```

No son ocho “sistemas independientes”. Comparten una sola jerarquía de autoridad:

```text
1. Usuario / decisiones aprobadas
2. Git main y Knowledge Vault como fuentes canónicas
3. Estado runtime explícito (por ejemplo Feature Flag provider)
4. Índices derivados: Graphify, VectorDB, GraphDB
5. Worktrees/previews como estados temporales no canónicos
```

Cuando dos protocolos parecen contradecirse, prevalece esta jerarquía y la regla más segura/reversible.

---

# 36. PROTO-GIT — Git Delivery & CI Protocol

## 36.1 Objetivo

Garantizar que cada cambio:

- nace de un `main` conocido;
- sea pequeño y conceptualmente coherente;
- pase validaciones locales;
- pase CI;
- sea revisado independientemente cuando el riesgo lo justifique;
- no introduzca regresiones silenciosas;
- pueda revertirse;
- deje `main` verde;
- produzca evidencia medible.

La regla de fondo es:

> **El trabajo no termina cuando se abre el PR ni cuando se hace merge. Termina cuando `main` queda verificado después del merge.**

---

## 36.2 Unidad de trabajo

Cada rama/PR debe representar, idealmente, **un cambio conceptual pequeño**.

Evitar:

```text
feature A
+ refactor global
+ cambio CI
+ nueva dependencia
+ feature B
```

en el mismo PR.

Preferir:

```text
PR A → comportamiento funcional
PR B → refactor
PR C → cambio de CI
```

Los tests directamente relacionados con el cambio sí deben viajar con el cambio.

---

## 36.3 Punto de partida

Antes de crear una rama:

```text
main debe estar verde
```

Secuencia conceptual:

```bash
git switch main
git fetch origin
git pull --ff-only origin main
```

Después ejecutar el smoke/check mínimo definido para `main`.

Crear la rama solo después:

```text
feature/<slug>
fix/<slug>
chore/<slug>
docs/<slug>
```

---

## 36.4 Implementación

Por defecto:

```text
Hermes
→ define alcance/criterios
→ OpenCode implementa
```

OpenCode debe:

- mantener el cambio dentro del alcance;
- escribir/actualizar tests;
- evitar refactors no necesarios;
- verificar los archivos realmente modificados;
- mantener trazabilidad.

---

## 36.5 Validación local canónica

Antes de sincronizar/abrir PR, ejecutar el conjunto canónico del proyecto.

Ejemplo para un stack TypeScript:

```text
typecheck / tsc
lint
unit tests
integration tests relevantes
build si aplica
E2E focalizado si aplica
```

Los comandos exactos deben residir en un único lugar versionado, para que humano, Hermes, OpenCode y CI ejecuten equivalentes.

No permitir que cada agente invente su propia “validación”.

---

## 36.6 Sincronización con `main`

### Baja concurrencia

Cuando hay pocos PR simultáneos:

```bash
git fetch origin
git rebase origin/main
```

Después del rebase:

```text
REVALIDAR
```

No asumir que un resultado previo sigue siendo válido.

Si una rama ya publicada necesita actualización forzada:

```bash
git push --force-with-lease
```

Nunca usar `--force` como rutina.

### Alta concurrencia

Cuando existan varios agentes/PR simultáneos y el repositorio/plan de GitHub lo soporte:

```text
preferir Merge Queue
```

La cola debe probar el cambio contra el estado reciente de `main`, reduciendo el ciclo de rebases repetidos.

Si se usa Merge Queue, los workflows requeridos deben soportar el evento:

```yaml
on:
  pull_request:
  merge_group:
```

---

## 36.7 Regla de resolución de conflictos

Nunca resolver automáticamente con:

```text
ours
theirs
```

sin comprender la semántica.

Un conflicto es una decisión sobre qué comportamiento debe sobrevivir.

Si el conflicto es puramente técnico:

```text
OpenCode / reviewer técnico
```

Si cambia comportamiento o intención:

```text
Hermes
→ recuperar decisiones
→ ideation/user si sigue ambiguo
```

---

## 36.8 Pull Request

El PR debe incluir al menos:

```text
WHAT
WHY
SCOPE
TESTS
RISK
ROLLBACK
DECISIONS/REQUIREMENTS RELEVANTES
```

Para cambios sustanciales, añadir referencias del Knowledge Vault y, cuando sea útil, nodos de Graphify.

---

## 36.9 GitHub ruleset / protección de `main`

No depender únicamente de instrucciones escritas.

`main` debe estar protegido técnicamente.

Baseline recomendado:

```text
Pull Request obligatorio
Required status checks
Conversation resolution
Bloquear force-push
Bloquear delete
Historia lineal
Bypass muy restringido
```

Cuando la concurrencia lo justifique y esté disponible:

```text
Merge Queue
```

El objetivo es convertir invariantes importantes en reglas de plataforma, no en “cosas que el agente debe recordar”.

---

## 36.10 CI siempre debe reportar

No omitir completamente un workflow requerido mediante filtros que puedan dejar un check requerido sin resultado.

Patrón recomendado:

```text
workflow CI SIEMPRE inicia
        ↓
detect-changes
        ↓
 ┌──────┴────────┐
docs-only      runtime/code
   ↓                ↓
quick gate       quick gate
                 + E2E según riesgo
```

Los jobs pesados pueden ser condicionales.

El workflow/gate requerido debe concluir explícitamente.

---

## 36.11 Política `docs-only`

La allowlist de documentación debe ser explícita y conservadora.

Ejemplo inicial:

```text
docs/**
AGENTS.md
*.md estrictamente documental
```

No clasificar como `docs-only`:

```text
package files
workflow YAML
config
migrations
schemas
scripts
infra
runtime code
```

si pueden cambiar comportamiento.

Ante duda:

```text
tratar como runtime change
```

---

## 36.12 E2E y shards

El número de shards es una **configuración medida**, no una regla religiosa.

Si actualmente se usan:

```text
8 shards
```

se conserva como baseline inicial.

Periódicamente comparar, por ejemplo:

```text
4 shards vs 8 shards
```

midiendo:

```text
wall time
runner minutes
coste
flakiness
balance de shards
feedback time
```

Playwright permite sharding por jobs y unión posterior de reportes; usar un reporte consolidado.

Si la suite permite paralelismo fino, balancear shards por tests y no solo por archivos cuando sea apropiado.

---

## 36.13 Retries y flaky tests

Retry es diagnóstico, no maquillaje.

Clasificación:

```text
PASS en primer intento → passed
FAIL y luego PASS → flaky
FAIL en todos → failed
```

No presentar `flaky` como un pass limpio.

---

## 36.14 Cuarentena de tests

No normalizar indefinidamente un `main` rojo mediante “baseline conocido”.

Un test conocido como problemático debe entrar en cuarentena explícita con:

```yaml
test:
reason:
issue:
owner:
since:
expires:
type:
```

Tipos posibles:

```text
flaky
bug
environment
dependency
stale
broken
investigating
```

Reglas:

- toda cuarentena tiene owner;
- toda cuarentena tiene issue;
- toda cuarentena tiene fecha de revisión/expiración;
- un test nuevo que falla no se convierte automáticamente en baseline;
- la cuarentena debe tender a cero.

---

## 36.15 CI obsoleto

En PRs con varios pushes, cancelar ejecuciones ya obsoletas.

Usar `concurrency` / `cancel-in-progress` cuando corresponda.

Objetivo:

```text
commit A → CI
commit B llega
→ cancelar CI de A
→ ejecutar B
```

Reduce tiempo, coste y ruido.

---

## 36.16 Claude review

Cuando el cambio amerite revisión independiente:

```text
OpenCode
→ CI
→ Claude
```

Claude no debe confiar únicamente en la descripción del PR.

Debe revisar evidencia:

```text
diff
tests
requirements
decisions
Graphify refs cuando aporte
```

Clasificación de hallazgos:

```text
CODE/BUG → OpenCode

DOCS → Claude puede corregir

BUSINESS/AMBIGUITY/INTENT/BIAS
→ Hermes
→ Knowledge Vault/context
→ ideation/user si sigue sin resolver
```

---

## 36.17 Merge gate

Un PR solo puede promoverse si:

```text
required checks = green
review requerido = satisfecho
conversaciones = resueltas
no regresiones nuevas
riesgos altos = mitigados/aceptados
rollback = conocido cuando aplique
```

Default:

```text
squash merge
```

porque mantiene:

```text
1 PR ≈ 1 cambio lógico en main
```

No es una ley universal; es la política inicial del sistema.

---

## 36.18 Verificación post-merge

Después del merge:

```text
main
→ smoke test inmediato
```

No esperar cuatro horas al cron para descubrir que `main` quedó roto.

Si el smoke falla:

```text
revert-first cuando sea la opción segura
→ restaurar main
→ investigar fuera del camino crítico
```

No acumular nuevos cambios encima de `main` rojo.

---

## 36.19 Siguiente rama

La siguiente fase siempre nace de:

```text
main actualizado
+ main verde
```

No encadenar:

```text
fase B sobre rama de fase A
fase C sobre B
```

salvo que se documente expresamente una dependencia excepcional.

---

## 36.20 Soak programado

Además del smoke post-merge:

```text
schedule → e2e-hub
```

Baseline inicial:

```text
cada ~4 horas
```

Evitar el minuto `00` si se usa GitHub Actions programado.

Ejemplo conceptual:

```cron
17 */4 * * *
```

La ventana:

```text
72 horas / 18 slots esperados
```

es un **criterio interno inicial**, no un estándar universal.

Registrar:

```text
expected slots
triggered
completed
green
red
flaky
infra failures
product failures
SHA
timestamp
```

Una ejecución no lanzada por el scheduler no debe contarse automáticamente como fallo de producto.

---

## 36.21 Seguridad de GitHub Actions

Aplicar mínimo privilegio.

Por defecto:

```yaml
permissions:
  contents: read
```

Dar permisos `write` solo al job que los requiera.

En workflows críticos, fijar actions de terceros a revisiones inmutables/commit SHA cuando sea viable.

No imprimir secretos.

No ejecutar código de fuentes no confiables con credenciales privilegiadas.

---

## 36.22 Pipeline conceptual completo

```text
IDEA / REQUIREMENT
        ↓
      Hermes
        ↓
plan / acceptance criteria
        ↓
short-lived branch from green main
        ↓
     OpenCode
code + tests
        ↓
local canonical validation
        ↓
sync with main
(rebase OR merge queue strategy)
        ↓
revalidation
        ↓
       PR
        ↓
CI gate always reports
        ↓
detect changes
  ┌─────┴─────┐
docs-only   runtime
   ↓           ↓
quick       quick + E2E
  └─────┬─────┘
        ↓
Claude review when risk requires
        ↓
findings routed by Hermes
        ↓
correction
        ↓
new CI / stale run cancelled
        ↓
merge gate
        ↓
squash / merge queue
        ↓
post-merge smoke on main
        ↓
green?
 ┌──────┴──────┐
yes            no
 ↓              ↓
next branch   revert/recover
```

En paralelo:

```text
main
 ├─ push/merge → smoke inmediato
 └─ schedule   → e2e-hub soak
```

---

## 36.23 Métricas de PROTO-GIT

Medir:

```text
PR lead time
time to green
rework rounds
merge conflicts
CI minutes
CI cost
flake rate
quarantine count
escaped defects
post-merge failures
revert rate
mean time to recovery
E2E duration
shard imbalance
```

El protocolo se optimiza a partir de estas métricas, no por intuición.

---

# 37. PROTO-SEC — Security, Secrets & Access Protocol

Este protocolo es estrictamente necesario porque Telegram, Hermes y agentes pueden alcanzar herramientas con capacidad real de modificar el VPS/repositorios.

Reglas mínimas:

1. **Least privilege** por defecto.
2. Tokens/secrets fuera de Git, Knowledge Vault y logs.
3. Telegram usa allowlist y perfil limitado.
4. Acciones destructivas requieren aprobación humana.
5. No abrir puertos ni cambiar firewall/SSH sin aprobación.
6. No deshabilitar controles de seguridad para resolver comodidad.
7. Credenciales con scope mínimo.
8. Rotación/revocación documentable.
9. Si la identidad/autorización es incierta: **fail closed**.
10. Toda acción privilegiada debe dejar trazabilidad.

Criterio de éxito:

```text
ningún agente puede convertir una instrucción de Telegram
en una operación irrestricta de root sin un control explícito.
```

---

# 38. PROTO-INC — Incident, Rollback & Recovery Protocol

Este protocolo es estrictamente necesario porque un sistema autónomo debe saber qué hacer cuando algo sale mal.

Clasificación inicial:

```text
SEV-1 → producción/seguridad/datos en riesgo inmediato
SEV-2 → función crítica degradada
SEV-3 → fallo no crítico / workaround disponible
```

Secuencia:

```text
DETECT
→ CONTAIN
→ RESTORE
→ VERIFY
→ INVESTIGATE
→ DOCUMENT
→ PREVENT RECURRENCE
```

Reglas:

- priorizar restaurar servicio antes de hacer una investigación extensa;
- si un merge rompe `main` y el revert es seguro, revertir primero;
- no borrar evidencia/logs necesarios;
- registrar SHA/version/config afectada;
- mantener backups de config crítica;
- probar recuperación periódicamente;
- crear postmortem para incidentes significativos;
- el postmortem describe causas y controles, no culpa.

Artefactos mínimos:

```text
DISASTER_RECOVERY.md
incident log
rollback instructions
backup/restore verification
```

---

# 39. PROTO-EVAL — Evaluation & Release Gates Protocol

Este protocolo es estrictamente necesario porque Hermes debe poder demostrar que una mejora realmente mejora el sistema.

Toda promoción relevante de:

```text
modelo
provider
routing
prompt
skill
Graphify config
CI strategy
agent policy
```

debe compararse contra una baseline.

Orden:

```text
deterministic checks
→ canonical evals
→ independent review/grader when needed
→ cost/latency comparison
→ regression analysis
→ promote / reject
```

No permitir:

```text
"el nuevo modelo parece mejor"
```

sin batería comparable.

Cada eval define:

```text
INPUT
EXPECTED_ROUTE
EXPECTED_RESULT
FAILURE_CONDITIONS
METRICS
```

Scores deben derivarse de numeradores/denominadores reales.

Ejemplo:

```text
routing correctness = 19/20 = 95%
```

No inventar porcentajes subjetivos.

Cambios de alto impacto requieren:

```text
baseline
candidate
same eval suite
quality delta
cost delta
latency delta
known regressions
rollback
```

---

# 40. PROTO-WT — Worktrees & Parallel Agent Isolation Protocol

## 40.1 Objetivo

Permitir que varios agentes trabajen en paralelo sin compartir un working directory ni mezclar cambios no relacionados.

Git worktree permite múltiples working trees vinculados al mismo repositorio, cada uno con su propio `HEAD` e índice, mientras comparte el objeto Git subyacente.

## 40.2 Cuándo se activa

```text
1 writer / trabajo secuencial
→ NO obligatorio

2+ writers concurrentes sobre código
→ Worktrees obligatorios salvo justificación

tareas con alto solapamiento
→ preferir serialización, no “más worktrees”
```

Worktree no es una solución a la coordinación semántica. Solo da aislamiento físico.

## 40.3 Roles

```text
main worktree
→ integración, auditoría, context snapshots, merge verification

worker worktree
→ exactamente una rama/tarea principal

preview worktree
→ experimentos o validaciones aisladas; descartable
```

No permitir que dos agentes escriban en la misma rama. Git ya rechaza por defecto checkout de una misma rama en más de un worktree; no saltarse esa protección rutinariamente con `--force`.

## 40.4 Convención

Ejemplo:

```text
/workspace/worktrees/<repo>/<task-id>-<agent>/
```

Rama:

```text
agent/<task-id>-<agent>-<slug>
```

Creación conceptual:

```bash
git fetch origin
git worktree add -b agent/<task>-<agent>-<slug> \
  /workspace/worktrees/<repo>/<task>-<agent> origin/main
```

## 40.5 Registro de leases

Hermes mantiene en `.context/STATE.md` una tabla de worktrees activos:

```text
task_id
agent
branch
path
base_sha
created_at
files/domains expected
status
```

Ese registro lo actualiza Hermes desde el worktree de integración; los workers no compiten editando snapshots mutables.

## 40.6 Colisión preventiva

Antes de paralelizar:

```text
task scopes
+ Graphify dependency map cuando sea útil
+ expected file/domain ownership
→ overlap estimate
```

Si dos tareas probablemente modifican el mismo contrato/schema/migration/archivo crítico:

```text
serializar
```

aunque Git permita dos worktrees.

## 40.7 `.context/` y handoffs

Para evitar conflictos:

- Hermes es dueño de snapshots mutables: `STATE.md`, `TASK.md`, `DECISIONS.md`, `CONVENTIONS.md`.
- Worker worktrees producen artefactos/handoffs con nombres únicos e inmutables.
- La consolidación de snapshots se hace después de integrar evidencia, no desde múltiples worktrees simultáneamente.

## 40.8 Índices y servicios desde worktrees

Un worktree NO debe actualizar índices productivos compartidos.

```text
worker branch
→ índice preview/namespace temporal, si realmente hace falta

main merge
→ pipeline canónico actualiza Graphify/VectorDB/GraphDB
```

Esto evita contaminar memoria/retrieval con código aún no aceptado.

## 40.9 Integración

Cada worktree sigue PROTO-GIT:

```text
local tests
→ sync/rebase o Merge Queue
→ PR
→ CI
→ review
→ merge
→ main smoke
```

No mergear directamente desde el worktree a `main`.

## 40.10 Cleanup

Después de merge/cancelación:

1. comprobar que el worktree está limpio;
2. guardar handoff/evidencia necesaria;
3. `git worktree remove <path>`;
4. eliminar branch si ya no corresponde;
5. `git worktree prune` para metadatos stale cuando sea necesario;
6. actualizar `.context/STATE.md`.

No usar `--force` para borrar trabajo no inspeccionado.

## 40.11 Métricas

```text
active worktrees
stale worktrees
merge conflicts
overlap incidents
parallel lead-time gain
rework caused by parallelism
```

Si paralelizar empeora conflictos/rework, reducir concurrencia.

---

# 41. PROTO-VEC — Vector Retrieval / VectorDB Protocol

## 41.1 Objetivo

Añadir búsqueda semántica cuando la recuperación exacta/lexical y el grafo técnico ya no sean suficientes, sin convertir embeddings en una segunda fuente de verdad.

Principio:

> **VectorDB es un índice derivado y reconstruible, no memoria canónica.**

## 41.2 Fuentes canónicas permitidas

Pueden indexarse:

```text
Knowledge Vault
documentación aprobada
research aprobado
código/docs desde Git main
salidas técnicas seleccionadas de Graphify
```

No indexar como producción:

```text
dirty worktree
chat crudo completo
secretos
datos sin scope/ACL
contenido superseded como si siguiera vigente
```

## 41.3 Gate de activación

No desplegar un VectorDB dedicado por moda.

Activar una capacidad vectorial cuando los evals demuestren al menos uno:

- demasiada lectura lineal para recuperar contexto;
- queries semánticas que keyword/exact lookup no resuelven;
- latencia/coste de retrieval actual inaceptable;
- corpus crece hasta hacer ineficiente el método simple;
- retrieval eval muestra mejora material.

## 41.4 Selección de backend

No instalar varios backends para la misma función.

Candidatos:

```text
PostgreSQL ya operativo
→ evaluar pgvector primero por simplicidad operacional

necesidad dedicada de dense+sparse/hybrid/multivector/scaling
→ evaluar Qdrant u otra VectorDB especializada

GraphDB seleccionada con vector index suficiente
→ evaluar si una sola base cubre ambos protocolos
```

La elección se decide mediante PROTO-EVAL, no preferencia subjetiva.

## 41.5 Modelo de datos mínimo

Cada chunk/vector debe conservar:

```yaml
record_id:
source_id:
source_type:
source_path:
source_commit_sha:
source_hash:
project:
security_scope:
status:
chunker_version:
embedding_model:
embedding_dimensions:
created_at:
updated_at:
```

Nunca perder el enlace a la fuente original.

## 41.6 Chunking

El chunker es parte versionada del sistema.

Reglas:

- preservar límites semánticos cuando sea posible;
- no cortar decisiones/requisitos arbitrariamente;
- código se segmenta con estructura/símbolos cuando sea posible;
- evitar duplicación excesiva por overlap;
- medir retrieval antes de optimizar tamaños.

Cambiar chunker/modelo de embeddings requiere reindex controlado.

## 41.7 Cambio de embedding model

No mezclar vectores incompatibles silenciosamente.

Usar:

```text
index_v1 → serving
index_v2 → rebuild/canary/eval
```

Después:

```text
same golden queries
→ compare
→ promote/reject
```

Registrar modelo/dimensiones en metadata.

## 41.8 Retrieval pipeline

Orden recomendado:

```text
1. scope/ACL/project filter
2. exact IDs / structured metadata si existen
3. lexical/BM25/full-text
4. dense semantic retrieval
5. fusion/hybrid ranking
6. optional GraphDB expansion
7. rerank
8. dedupe
9. evidence packaging
```

No usar vector similarity para una pregunta que tiene un ID/clave exacta conocida.

La búsqueda híbrida combina coincidencia semántica con lexical, evitando perder términos exactos.

## 41.9 Seguridad

ACL/tenant/project filtering ocurre **antes o durante retrieval**, no después de entregar chunks al LLM.

Nunca embedding/search debe permitir cross-project leakage.

## 41.10 Frescura y borrado

Cada resultado debe ser comprobable contra:

```text
source_hash
source_commit_sha
status
```

Al borrar/superseder una fuente:

- marcarla no servible inmediatamente;
- eliminar/reindexar de forma idempotente;
- mantener audit trail donde corresponda.

## 41.11 Escritura

Los agentes no escriben “hechos” directamente en VectorDB.

```text
agent proposes/updates canonical source
→ source accepted
→ indexer creates/updates embeddings
```

## 41.12 Evals

Golden query set con:

```text
Recall@K
Precision@K
MRR/nDCG cuando aporte
grounded-answer pass rate
latency p50/p95
tokens/context returned
index freshness
cost
```

No promover cambios de embeddings/chunking/retrieval sin comparación baseline/candidate.

---

# 42. PROTO-GRAPH — Graphify, GraphDB & GraphRAG Protocol

## 42.1 Objetivo

Representar relaciones técnicas y conceptuales de forma consultable y explicable sin crear una verdad paralela.

Separación:

```text
Graphify
= extractor/generador del grafo técnico

GraphDB
= persistencia/query opcional para grafos y GraphRAG

Knowledge Vault
= fuente canónica conceptual

Git main
= fuente canónica técnica
```

## 42.2 Gate de GraphDB

Graphify `graph.json`/report puede ser suficiente al principio.

Activar GraphDB cuando aparezca una necesidad demostrada:

- queries multi-hop frecuentes;
- relaciones entre múltiples proyectos;
- traversal/impact analysis complejo;
- GraphRAG;
- incremental graph updates a escala;
- necesidad de consultas estructuradas/auditables que JSON no cubre bien.

## 42.3 Backend

Si se activa GraphDB, **Neo4j es candidato preferente a evaluar**, no mandato absoluto, por su soporte maduro de knowledge graphs, Cypher y GraphRAG.

PROTO-EVAL decide backend.

Si un único backend (p. ej. GraphDB con vector index) cubre bien VEC + GRAPH, se permite consolidar y evitar dos servicios físicos.

> Los protocolos describen capacidades lógicas; no obligan a duplicar infraestructura.

## 42.4 Namespaces lógicos

Mantener separación:

```text
TECH graph
→ generado desde Git/Graphify

KNOWLEDGE graph
→ proyectado desde Knowledge Vault

CROSS-LINK graph
→ enlaces explícitos entre ambos
```

Ejemplo:

```text
DEC-014
  └─ IMPLEMENTED_BY → CodeEntity:OrderState

REQ-022
  └─ VALIDATED_BY → Test:order-payment-state
```

No fusionar inferencias técnicas con decisiones humanas sin metadata de origen.

## 42.5 Esquema inicial

Nodos posibles:

```text
Project
Requirement
Decision
Assumption
Risk
Research
CodeEntity
File
Module
Service
Schema
Test
Incident
FeatureFlag
Agent
Artifact
```

Relaciones:

```text
IMPLEMENTS
DEPENDS_ON
AFFECTS
REFERENCES
SUPERSEDES
EVIDENCED_BY
VALIDATED_BY
DECIDED_BY
OWNED_BY
DERIVED_FROM
CONTRADICTS
```

Todo edge/fact debe poder indicar origen/provenance/confidence.

## 42.6 Escritura

No permitir que el LLM mutile el grafo canónico directamente.

Flujo:

```text
Git/Vault changes
→ extraction/normalization
→ Graphify / graph sync
→ validation
→ GraphDB projection
```

Una inferencia del LLM entra con:

```text
status: inferred
confidence:
evidence:
```

y nunca reemplaza silenciosamente un hecho `extracted/approved`.

## 42.7 Drift detection

El uso diferencial más importante:

```text
Knowledge Vault:
DECISION / REQUIREMENT

↕ cross-links

GraphDB/Graphify:
REAL IMPLEMENTATION
```

Si divergen:

```text
detect
→ cite evidence
→ classify technical vs conceptual
→ escalate if needed
→ correct canonical source/code
→ rebuild derived graphs
```

## 42.8 GraphRAG

Cuando una pregunta depende de relaciones:

```text
semantic/vector seed
→ graph traversal
→ relevant nodes/paths
→ source documents/code
→ answer with provenance
```

Vector retrieval encuentra “por significado”; el grafo añade estructura/multi-hop.

## 42.9 Preview vs producción

Worktrees/PRs:

```text
preview graph namespace
```

Main:

```text
canonical serving graph
```

Nunca dejar que un PR no mergeado altere el graph serving de producción.

## 42.10 Frescura

Cada nodo derivado debe poder rastrear:

```text
source_commit_sha
source_hash / source_id
extractor_version
graphify_version
indexed_at
```

Si el grafo está stale respecto a `main`, Hermes debe:
- marcarlo stale;
- refrescar;
- o caer a Git/source directa para decisiones críticas.

## 42.11 Métricas

```text
path validity
provenance coverage
stale-edge rate
graph freshness
query latency
multi-hop answer accuracy
drift detections
false drift alerts
```

---

# 43. PROTO-FLAG — Feature Flags & Progressive Delivery Protocol

> “Future Flags” se interpreta aquí como **Feature Flags**.

## 43.1 Objetivo

Separar **deploy** de **release**, permitir rollout gradual, testing controlado en producción y apagado rápido de funcionalidad sin crear ramas largas.

## 43.2 Estándar de interfaz

Preferir una interfaz vendor-neutral basada en **OpenFeature** cuando el stack lo permita.

El proveedor/control plane se elige mediante PROTO-EVAL.

Unleash es un candidato self-hosted a evaluar; no se instala automáticamente si el proyecto aún no necesita flags runtime.

## 43.3 Qué es fuente de verdad

Separar:

```text
Git / Knowledge Vault
→ definición, owner, intención, lifecycle, default, removal task

Feature Flag provider/control plane
→ estado runtime actual, targeting, porcentaje, variantes

Observability
→ impacto real y métricas
```

No duplicar manualmente el estado live en archivos y esperar consistencia perfecta.

## 43.4 Tipos

Usar tipos explícitos:

```text
RELEASE
EXPERIMENT
OPERATIONAL
KILL_SWITCH
PERMISSION (solo si realmente modela entitlement)
SUNSET/MIGRATION
```

Un flag de feature **no sustituye autenticación/autorización real**.

## 43.5 Metadata obligatoria

```yaml
flag_key:
type:
owner:
project:
description:
default:
created_at:
expected_expiry:
removal_issue:
environments:
risk:
success_metrics:
rollback_condition:
related_requirement:
related_decision:
```

Nunca reutilizar una key antigua para un significado nuevo.

## 43.6 Defaults y failure mode

Cada flag define su fallback explícito.

No existe un default universal.

Ejemplos:

```text
release incompleto
→ default OFF

kill switch
→ default que preserve operación segura

permiso sensible
→ fail closed
```

Si el provider no responde, el SDK debe usar un comportamiento predefinido y observable.

## 43.7 Flag ≠ configuración

No usar feature flags para:

```text
API keys
DB passwords
ports
CORS base
URLs estáticas permanentes
secretos
```

Eso pertenece a config/secrets.

## 43.8 Desarrollo con flags

Feature Flags permiten integrar cambios pequeños a `main` sin exponer una feature incompleta.

Pero el código mergeado debe:

- compilar;
- pasar CI;
- mantener `main` verde;
- tener el path default seguro;
- incluir tests del flag OFF;
- incluir tests del flag ON cuando sea relevante.

Un flag no es excusa para mergear código roto.

## 43.9 Rollout progresivo

Patrón inicial, ajustable por riesgo:

```text
dev/test
→ internal users
→ beta/opt-in
→ small percentage
→ larger percentages
→ 100%
```

Cada escalón tiene bake time y métricas.

La asignación debe ser sticky/determinística por un identificador estable cuando una experiencia inconsistente sea peligrosa.

## 43.10 Gates automáticos

Promoción solo si:

```text
error rate <= threshold
latency <= threshold
critical business metric healthy
no new security signal
eval/smoke green
```

Si falla:

```text
pause / rollback percentage / kill switch
```

Umbrales exactos deben salir de baseline real, no inventarse.

## 43.11 Kill switches

Funciones de riesgo/terceros pueden tener kill switch duradero.

Debe:
- ser rápido;
- estar documentado;
- tener owner;
- probarse periódicamente;
- emitir audit/telemetry.

## 43.12 Migraciones

Para migraciones complejas, preferir patrones como:

```text
branch by abstraction
expand/contract
parallel run
dual-read / shadow-read
dual-write solo con reconciliación explícita
```

No esconder una migración irreversible detrás de un simple booleano sin plan de datos.

## 43.13 Lifecycle / deuda

Los release/experiment/operational flags son temporales.

Al crear el flag, crear también:

```text
removal issue
expiry
owner
```

Después de rollout estable al 100%:

```text
remove old path
remove flag checks
run tests
archive flag
```

La cantidad de stale flags es una métrica de deuda.

## 43.14 Observabilidad

Cada request/event relevante debe poder asociarse a:

```text
flag_key
variant/value
evaluation reason
environment
targeting context no sensible
```

OpenFeature hooks u mecanismo equivalente puede integrar telemetry.

No loggear PII innecesaria.

## 43.15 Seguridad

Targeting sensible:
- evaluar server-side;
- mínimo contexto;
- no exponer reglas privadas innecesariamente al cliente.

Cambios de flags de alto impacto requieren RBAC/audit y, cuando aplique, aprobación.

---

# 44. Reglas de interacción y precedencia entre protocolos

Esta sección evita conflictos.

## 44.1 Worktree + Git

```text
PROTO-WT aísla desarrollo
PROTO-GIT decide integración
```

Worktree nunca autoriza merge directo.

## 44.2 Worktree + Graph/Vector

```text
worktree/PR
→ preview index opcional y aislado

main
→ serving indexes canónicos
```

No contaminar producción con estado no mergeado.

## 44.3 Git + Feature Flags

Feature flags reducen necesidad de ramas largas.

```text
small PR
→ merge behind OFF flag
→ progressive release
```

Solo si ambos paths cumplen gates relevantes.

## 44.4 VectorDB + GraphDB

No compiten.

```text
Vector
→ similitud semántica / candidate retrieval

Graph
→ relaciones / traversal / explainability

Hybrid
→ vector seed + graph expansion + rerank
```

Si un solo backend cumple ambos casos con mejores métricas/coste, se permite consolidar físicamente.

## 44.5 Graphify + GraphDB

```text
Graphify = extraction
GraphDB = serving/query persistence opcional
```

Graphify puede funcionar sin GraphDB.

GraphDB no reemplaza Graphify automáticamente.

## 44.6 Knowledge Vault + Vector/Graph

```text
Vault = canonical
Vector/Graph = projections
```

Cambiar la proyección nunca cambia la decisión canónica.

## 44.7 Feature Flags + Knowledge Graph

Todo flag relevante se enlaza a:

```text
Requirement
Decision
Risk
Owner
Removal task
```

GraphDB puede modelar esas relaciones, pero el control plane mantiene el estado runtime.

## 44.8 PROTO-SEC prevalece

Si eficiencia/concurrencia/release entra en conflicto con seguridad:

```text
PROTO-SEC prevalece
```

## 44.9 PROTO-INC durante incidentes

Durante incidente activo:

```text
restaurar/contener
> optimizar
```

PROTO-INC puede pausar rollout, trabajo paralelo o indexing.

## 44.10 PROTO-EVAL para promoción

Cualquier cambio permanente de:

```text
VectorDB
embedding model
GraphDB
Graphify version
flag provider
worktree concurrency
routing
LLM
```

pasa por PROTO-EVAL.

---

# 45. Pipeline canónico de sincronización

## 45.1 Fuentes y derivados

```text
CANONICAL:
Git main
Knowledge Vault
Feature Flag runtime control plane (solo estado live de flags)

DERIVED:
Graphify
Vector index
GraphDB
Obsidian views
reports/caches

TEMPORARY:
worktrees
preview indexes
PR graphs
local caches
```

## 45.2 Después de merge a main

Orden recomendado:

```text
1. post-merge smoke
2. si falla → PROTO-INC / revert
3. si pasa:
   a. Graphify refresh
   b. canonical content normalization
   c. VectorDB incremental update
   d. GraphDB projection update
   e. cross-link validation
   f. freshness checks
   g. metrics
```

El indexing debe ser:

```text
idempotente
repetible
auditable
```

## 45.3 Consistency token

Cada derivado debe registrar el SHA/fuente que representa.

Ejemplo:

```yaml
main_sha: abc123
vault_revision: ...
graphify_version: ...
vector_index_version: ...
graph_projection_version: ...
```

Hermes no debe presentar una proyección stale como si fuera actualidad.

---

# 46. Actualización de Definition of Done

Además de los criterios anteriores:

```text
[ ] main protegido por ruleset
[ ] required checks definidos
[ ] CI requerido siempre reporta
[ ] merge_group soportado si hay Merge Queue
[ ] post-merge smoke funciona

[ ] concurrencia >1 writer usa worktrees o tiene excepción documentada
[ ] main worktree se usa como integración
[ ] worktrees stale se detectan/limpian

[ ] VectorDB, si está activo, es derivado y reconstruible
[ ] retrieval tiene golden evals
[ ] ACL/project scope se aplica antes/durante retrieval
[ ] embedding/chunker versions quedan registradas

[ ] Graphify tiene freshness/provenance
[ ] GraphDB, si está activo, no reemplaza Git/Vault
[ ] TECH y KNOWLEDGE namespaces no se confunden
[ ] cross-links tienen evidencia
[ ] drift detection tiene evals

[ ] Feature Flags tienen owner/type/default/expiry/removal
[ ] flags temporales tienen cleanup
[ ] paths ON/OFF relevantes se testean
[ ] kill switches críticos se prueban
[ ] provider failure tiene fallback explícito
[ ] flags no contienen secretos

[ ] preview indexes nunca contaminan serving indexes
[ ] derived stores reportan la revisión canónica que representan
[ ] PROTO-EVAL gobierna cambios de backend/modelo/policy
```

---

# 47. Precedentes y fundamentos verificados

El diseño fue contrastado con documentación/prácticas actuales:

## Git Worktrees
Git documenta múltiples working trees vinculados a un mismo repositorio y proporciona `add`, `list`, `remove`, `prune`, `lock` y `repair`. El diseño aprovecha esas garantías y evita saltarse las protecciones normales.

## Vector retrieval
Qdrant documenta hybrid search combinando semántica y lexical, así como consultas multi-stage. `pgvector` documenta búsqueda vectorial dentro de PostgreSQL y combinación con full-text search. Por eso el protocolo exige evaluar antes de crear infraestructura duplicada.

## Knowledge Graph / GraphRAG
Neo4j documenta GraphRAG combinando vector retrieval con traversals de relaciones, aportando contexto multi-hop y trazabilidad. El protocolo separa fuente canónica de proyección para no convertir el grafo en verdad no auditada.

## Graphify
Graphify genera un grafo consultable del proyecto desde código/documentación y soporta asistentes como Hermes, OpenCode y Claude Code. Se usa como extractor técnico, no como autoridad de negocio.

## Feature Flags
OpenFeature proporciona una API vendor-neutral para evaluación de flags y contexto. Unleash/LaunchDarkly documentan lifecycle, gradual rollout, kill switches, expiración y limpieza de flags. El protocolo adopta esos patrones sin acoplar el sistema a un proveedor antes de evaluarlo.

---

# 48. Regla final de complejidad

Tener un protocolo no significa instalar un servicio.

La secuencia correcta es:

```text
DEFINIR CAPACIDAD
→ GATE DE NECESIDAD
→ BASELINE
→ CANDIDATO
→ EVAL
→ INSTALAR/ACTIVAR SOLO SI APORTA
→ MEDIR
→ RETIRAR SI NO JUSTIFICA SU COSTE
```

Esto permite que Worktrees, VectorDB, GraphDB y Feature Flags estén diseñados desde el inicio **sin obligarnos a sobrearquitectar el VPS desde el inicio**.
