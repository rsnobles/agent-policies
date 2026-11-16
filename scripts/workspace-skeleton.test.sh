#!/usr/bin/env bash
# shellcheck disable=SC2016,SC2034,SC2329  # test bodies are eval-ed strings
# Tests for workspace-skeleton.sh. Runs against a temp root via WORKSPACE_ROOT; never touches /workspace.
# Usage: bash workspace-skeleton.test.sh
set -uo pipefail
S="$(cd "$(dirname "$0")" && pwd)/workspace-skeleton.sh"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
export WORKSPACE_ROOT="$T"
DIRS=(bots src srv etc run shared tmp var/lib var/log var/metrics var/spool var/archive)
pass=0; fail=0
ok(){ if eval "$2"; then echo "ok   $1"; ((pass++)); else echo "FAIL $1"; ((fail++)); fi; }

out=$(bash "$S" --dry-run)
ok "dry-run lists ${#DIRS[@]} dirs"        '[[ $(wc -l <<<"$out") -eq ${#DIRS[@]} ]]'
ok "dry-run creates nothing"               '[[ -z $(ls -A "$T") ]]'

echo keep > "$T/sentinel"
bash "$S"
for d in "${DIRS[@]}"; do ok "creates $d" '[[ -d "$T/$d" ]]'; done
ok "registry is valid JSON"                'python3 -m json.tool "$T/etc/registry.json" >/dev/null'
ok "registry has version/bots/services"    'python3 -c "import json,sys;d=json.load(open(sys.argv[1]));assert d==dict(version=1,bots={},services={})" "$T/etc/registry.json"'
ok "no temp files left in etc/"            '[[ -z $(ls -A "$T/etc" | grep "^\.registry") ]]'
ok "existing files untouched"              '[[ $(cat "$T/sentinel") == keep ]]'

echo '{"version":1,"bots":{"x":{}},"services":{}}' > "$T/etc/registry.json"
before=$(find "$T" | sort | md5sum)
bash "$S"
ok "second run is idempotent"              '[[ $(find "$T" | sort | md5sum) == "$before" ]]'
ok "existing registry not overwritten"     'grep -q "\"x\"" "$T/etc/registry.json"'

echo "$pass passed, $fail failed"; exit $((fail>0))
