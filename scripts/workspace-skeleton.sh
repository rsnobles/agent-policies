#!/usr/bin/env bash
# /workspace layout skeleton (proposed Oct 30, 2026). Idempotent: mkdir -p only, never deletes or moves.
# Usage: bash workspace-skeleton.sh [--dry-run]
set -euo pipefail
W="${WORKSPACE_ROOT:-/workspace}"   # override for tests
DIRS=(bots src srv etc run shared tmp var/lib var/log var/metrics var/spool var/archive)
for d in "${DIRS[@]}"; do
  if [[ "${1:-}" == --dry-run ]]; then echo "mkdir -p $W/$d"; else mkdir -p "$W/$d"; fi
done
REG="$W/etc/registry.json"
if [[ "${1:-}" != --dry-run && ! -e "$REG" ]]; then
  tmp=$(mktemp "$W/etc/.registry.XXXX")
  printf '{\n  "version": 1,\n  "bots": {},\n  "services": {}\n}\n' > "$tmp"
  mv "$tmp" "$REG"   # atomic rename, per ATOM-1
fi
