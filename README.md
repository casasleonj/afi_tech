# afi_tech

afi_tech es el repositorio canónico y activo del proyecto. Conserva la
intención, arquitectura, protocolos, estado, decisiones, scripts,
configuración reproducible y evidencia del entorno multiagente.

El entorno actual se construye progresivamente y debe evolucionar sincronizado
con este repositorio. No se crea un segundo repositorio sin necesidad
demostrada.

## Autoridad

- Arquitectura: `docs/architecture/HERMES_CONTEXTO_MAESTRO_v3.0.md`.
- Ejecución: `docs/architecture/HERMES_INSTRUCCION_MAESTRA_AUTONOMA_v2.0.md`.
- Estado operativo y decisiones: `.context/`.
- Evidencia de inspecciones: `docs/audits/`.

## Ciclo de avance

`inspect environment → implement/configure → test → measure → persist in
afi_tech → Git/PR/CI → continue`

`TEMPORARY_BRIDGE`: las ramas de trabajo con prefijos `agent/`, `feature/`,
`fix/`, `docs/` o `chore/` crean un PR *draft* automáticamente mediante GitHub
Actions.
El contrato CI corre contra el push de la rama; una ejecución `pull_request`
creada por el token de GitHub puede requerir aprobación humana. La revisión y
merge siguen siendo gates explícitos.

Este bridge debe retirarse cuando el runtime real de Hermes tenga una
integración GitHub segura, validada y de mínimo privilegio que pueda crear y
consultar PRs, leer checks/CI y reviews/comentarios. Antes de retirarlo se
comparan ambas alternativas y se elimina la Action si no añade valor.

## Continuidad

- Lee `AGENTS.md` antes de actuar.
- Consulta `.context/STATE.md`, `.context/TASK.md`, `.context/DECISIONS.md` y
  `.context/CONVENTIONS.md` para el estado operativo.
- Abre `.context/handoffs/latest.md` y el handoff que indique para continuar
  desde la evidencia más reciente.
- Verifica el estado de Git antes y después de cada tarea.
- Ejecuta `bash scripts/verify-context.sh` antes de proponer un cambio de
  contexto o documentación.
