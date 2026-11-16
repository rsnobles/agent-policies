#!/usr/bin/env bash
# Drift check: render into a temp dir and diff against the committed dist/.
# Exit 0 = dist/ matches policy; exit 1 = drift (run `make render` and commit).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
"${PYTHON:-python3}" "$ROOT/scripts/render.py" "$T/dist" >/dev/null
if diff -r "$ROOT/dist" "$T/dist"; then
  echo "check: dist/ matches policy.yaml ($(cat "$ROOT/dist/VERSION"))"
else
  echo "check: DRIFT between dist/ and policy.yaml; run 'make render' and commit" >&2
  exit 1
fi
