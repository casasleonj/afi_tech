#!/usr/bin/env bash
# Regression fixtures for the exact TEMPORARY_BRIDGE policy verifier.
set -euo pipefail

root=$(git rev-parse --show-toplevel)
fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT
mkdir -p "$fixture/.github/workflows" "$fixture/scripts"
git -C "$fixture" init -q
cp "$root/scripts/verify-auto-pr.sh" "$fixture/scripts/verify-auto-pr.sh"
base=$(cat "$root/.github/workflows/auto-pr.yml")

reject_fixture() {
  local label=$1 mutation=$2
  printf '%s' "$base" > "$fixture/.github/workflows/auto-pr.yml"
  python3 - "$fixture/.github/workflows/auto-pr.yml" "$mutation" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1])
kind=sys.argv[2]
s=p.read_text()
if kind == 'permission':
    s=s.replace('  pull-requests: write\n', '  pull-requests: write\n  id-token: write\n')
elif kind == 'nested-permission':
    s=s.replace('  create:\n    runs-on:', '  create:\n    permissions:\n      contents: read\n      pull-requests: write\n      id-token: write\n    runs-on:')
elif kind == 'token':
    s=s.replace('      GITHUB_TOKEN: ${{ github.token }}\n', '      GITHUB_TOKEN: ${{ github.token }}\n      GH_ENTERPRISE_TOKEN: ${{ github.token }}\n')
elif kind == 'api-write':
    s=s.replace('          if [[ "$open_count" == "0" ]]; then\n', '          gh api --method POST /repos/example/example/issues\n          if [[ "$open_count" == "0" ]]; then\n')
else:
    raise SystemExit(kind)
p.write_text(s)
PY
  if (cd "$fixture" && bash scripts/verify-auto-pr.sh >/dev/null 2>&1); then
    echo "Verifier accepted forbidden fixture: $label" >&2
    exit 1
  fi
}

reject_fixture extra-permission permission
reject_fixture nested-permission nested-permission
reject_fixture extra-token token
reject_fixture api-write api-write
echo 'Auto-PR policy negative fixtures: OK'
