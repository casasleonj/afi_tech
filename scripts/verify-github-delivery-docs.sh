#!/usr/bin/env bash
# Verifies that the temporary bridge and final-integration gates are documented.
set -euo pipefail
root=$(git rev-parse --show-toplevel)
cd "$root"

files=(
  docs/design/GITHUB_DELIVERY_ARCHITECTURE.md
  docs/protocols/PROTO_GIT.md
  docs/evals/GITHUB_DELIVERY_E2E.md
  docs/runbooks/HERMES_GITHUB_RUNTIME.md
  scripts/probe-hermes-github-runtime.sh
)
for file in "${files[@]}"; do [[ -f "$file" ]] || { echo "Missing $file" >&2; exit 1; }; done

for clause in 'TEMPORARY_BRIDGE' 'replacement_required: true' 'NOT_READY' 'GitHub App' 'short-lived' 'github/github-mcp-server'; do
  grep -RFq -- "$clause" docs/design docs/evals docs/runbooks .context || {
    echo "Missing documented final-integration clause: $clause" >&2; exit 1;
  }
done

echo 'GitHub delivery documentation contract: OK'
