#!/usr/bin/env bash
# Validates the lightweight context contract without external dependencies.
set -euo pipefail

root=$(git rev-parse --show-toplevel)
cd "$root"

if (( $# == 0 )); then
  diff_args=(--cached)
elif (( $# == 2 )); then
  diff_args=("$1" "$2")
else
  echo "Usage: $0 [<base> <head>]" >&2
  exit 2
fi

required=(
  AGENTS.md
  README.md
  .context/STATE.md
  .context/TASK.md
  .context/DECISIONS.md
  .context/CONVENTIONS.md
  .context/PROTOCOL.md
  .context/handoffs/latest.md
  docs/architecture/HERMES_CONTEXTO_MAESTRO_v3.0.md
  docs/architecture/HERMES_INSTRUCCION_MAESTRA_AUTONOMA_v2.0.md
)
for path in "${required[@]}"; do
  [[ -f "$path" ]] || { printf 'Missing required file: %s\n' "$path" >&2; exit 1; }
done

latest=$(sed -n 's/^- \*\*Newest handoff:\*\* `\([^`]*\)`$/\1/p' .context/handoffs/latest.md)
[[ -n "$latest" ]] || { echo 'latest.md has no valid newest-handoff pointer' >&2; exit 1; }
[[ -f "$latest" ]] || { printf 'Newest handoff does not exist: %s\n' "$latest" >&2; exit 1; }

fields=(Task Result Decisions 'Files changed' Verification 'Risks/problems' 'Remaining work' 'Recommended next step')
for field in "${fields[@]}"; do
  grep -Fq "## $field" "$latest" || {
    printf 'Handoff missing field %q: %s\n' "$field" "$latest" >&2
    exit 1
  }
done

if grep -Eq '^- \*\*Written against:\*\*.*HEAD' .context/handoffs/latest.md; then
  echo 'latest.md must not claim a mutable exact HEAD' >&2
  exit 1
fi

if git diff --check "${diff_args[@]}" -- . ':(exclude)docs/architecture/**' | grep -q .; then
  echo 'Whitespace errors in staged changes' >&2
  exit 1
fi

echo 'Context contract: OK'
