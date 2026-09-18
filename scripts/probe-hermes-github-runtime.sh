#!/usr/bin/env bash
# Read-only, secret-safe inventory for the real Hermes runtime.
set -euo pipefail

if ! command -v hermes >/dev/null 2>&1; then
  echo 'STATUS=NOT_REAL_HERMES_RUNTIME: hermes CLI is unavailable here'
  exit 3
fi

printf 'hermes_version='; hermes --version
printf 'config_path='; hermes config path
for probe in 'hermes status --all' 'hermes profile list' 'hermes mcp list' 'hermes skills list'; do
  if eval "$probe" >/dev/null 2>&1; then
    printf '%s=available\n' "${probe#hermes }"
  else
    printf '%s=unavailable_or_failed\n' "${probe#hermes }"
  fi
done
printf '%s\n' '--- Git ---'; git --version
printf '%s\n' '--- GitHub CLI auth presence ---'
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  echo 'gh_auth=present'
else
  echo 'gh_auth=absent_or_not_installed'
fi
printf '%s\n' 'NOTE: provider/auth details require Hermes status/config commands; do not print config files or env values.'
