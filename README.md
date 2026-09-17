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

## Continuidad

- Lee `AGENTS.md` antes de actuar.
- Consulta `.context/STATE.md`, `.context/TASK.md`, `.context/DECISIONS.md` y
  `.context/CONVENTIONS.md` para el estado operativo.
- Abre `.context/handoffs/latest.md` y el handoff que indique para continuar
  desde la evidencia más reciente.
- Verifica el estado de Git antes y después de cada tarea.
- Ejecuta `bash scripts/verify-context.sh` antes de proponer un cambio de
  contexto o documentación.
