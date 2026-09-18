#!/usr/bin/env bash
# Verifies the exact least-privilege TEMPORARY_BRIDGE auto-PR policy.
set -euo pipefail

root=$(git rev-parse --show-toplevel)
cd "$root"
workflow=.github/workflows/auto-pr.yml
[[ -f "$workflow" ]] || { echo "Missing $workflow" >&2; exit 1; }

python3 - "$workflow" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
text = path.read_text()
expected_event = """on:
  push:
    branches:
      - 'agent/**'
      - 'feature/**'
      - 'fix/**'
      - 'docs/**'
      - 'chore/**'
"""
expected_permissions = """permissions:
  contents: read
  pull-requests: write
"""
expected_prefix = "name: temporary-bridge-auto-pr\n\n" + expected_event + "\n" + expected_permissions + "\nconcurrency:"
if not text.startswith(expected_prefix):
    raise SystemExit("Event trigger or permissions are not the exact bridge policy")
if text.count("permissions:") != 1:
    raise SystemExit("Bridge must declare exactly one permissions block")
if text.count("\non:") != 1:
    raise SystemExit("Bridge must declare exactly one event block")

required = [
    "GITHUB_TOKEN: ${{ github.token }}",
    "group: auto-pr-${{ github.ref }}",
    "cancel-in-progress: false",
    "gh pr list",
    "gh pr create",
    "--draft",
    "--base main",
    "created concurrently",
    "Review, CI, and merge remain explicit gates.",
]
for clause in required:
    if clause not in text:
        raise SystemExit(f"Missing required bridge clause: {clause}")

# The workflow may expose only its delivery metadata and the ephemeral token.
env_names = re.findall(r"(?m)^\s{6,}([A-Z][A-Z0-9_]*)\s*:", text)
allowed_env = {"GITHUB_TOKEN", "GH_REPO", "HEAD_BRANCH"}
extra_env = sorted(set(env_names) - allowed_env)
if extra_env:
    raise SystemExit(f"Unexpected workflow environment variables: {', '.join(extra_env)}")
if any(name.endswith("TOKEN") and name != "GITHUB_TOKEN" for name in env_names):
    raise SystemExit("Only GITHUB_TOKEN may carry GitHub authentication")

forbidden = [
    "${{ secrets.",
    "Authorization:",
    "ghp_",
    "github_pat_",
    "pull_request_target",
    "actions/checkout",
    "git push",
    "gh api",
    "gh pr merge",
    "gh pr review",
    "--approve",
    "actions: write",
    "contents: write",
    "issues: write",
    "id-token: write",
    "deployments: write",
    "workflow_dispatch",
    "repository_dispatch",
    "pull_request:",
    "'main'",
    "'dependabot/**'",
    "'feat/**'",
    "'refactor/**'",
    "'ci/**'",
    "'test/**'",
]
for clause in forbidden:
    if clause in text:
        raise SystemExit(f"Forbidden bridge capability or trigger: {clause}")

print("Auto-PR workflow exact policy: OK")
PY